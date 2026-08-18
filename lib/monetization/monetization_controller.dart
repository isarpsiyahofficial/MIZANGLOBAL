import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ad_service.dart';
import 'local_promo_service.dart';
import 'monetization_config.dart';
import 'monetization_policy.dart';
import 'network_gate_service.dart';
import 'premium_entitlement_store.dart';
import 'purchase_service.dart';

class MonetizationController extends ChangeNotifier
    with WidgetsBindingObserver {
  factory MonetizationController({
    PremiumEntitlementStore? entitlementStore,
    NetworkGateService? networkGate,
    MizanAdService? adService,
    MizanPromoCodeService? promoService,
    MizanPurchaseService? purchaseService,
  }) {
    final resolvedStore = entitlementStore ?? PremiumEntitlementStore();
    return MonetizationController._(
      entitlementStore: resolvedStore,
      networkGate: networkGate ?? NetworkGateService(),
      adService: adService ?? MizanAdService(),
      promoService: promoService ?? MizanPromoCodeService(),
      purchaseService:
          purchaseService ??
          MizanPurchaseService(entitlementStore: resolvedStore),
    );
  }

  MonetizationController._({
    required PremiumEntitlementStore entitlementStore,
    required NetworkGateService networkGate,
    required MizanAdService adService,
    required MizanPromoCodeService promoService,
    required MizanPurchaseService purchaseService,
  }) : this._resolved(
         entitlementStore,
         networkGate,
         adService,
         promoService,
         purchaseService,
       );

  MonetizationController._resolved(
    this._entitlementStore,
    this._networkGate,
    this._adService,
    this._promoService,
    this._purchaseService,
  );

  final PremiumEntitlementStore _entitlementStore;
  final NetworkGateService _networkGate;
  final MizanAdService _adService;
  final MizanPromoCodeService _promoService;
  final MizanPurchaseService _purchaseService;

  PremiumSnapshot _snapshot = const PremiumSnapshot(
    permanent: false,
    temporaryUntilUtc: null,
    rewardDateUtc: '',
    rewardedViewsToday: 0,
    permanentPurchaseFingerprint: null,
  );
  bool _initialized = false;
  bool _purchaseInitialized = false;
  bool _onlineServicesStarting = false;
  bool _redeemingPromo = false;
  bool _rewardFlowBusy = false;
  String? _promoMessageCode;
  int _meaningfulActionsSinceAd = 0;
  DateTime _lastFullScreenAdAtUtc = DateTime.now().toUtc();
  Timer? _tickTimer;
  bool _refreshingEntitlement = false;

  bool get initialized => _initialized;
  bool get isPermanentPremium => _snapshot.permanent;
  String? get permanentPurchaseFingerprint =>
      isPermanentPremium ? _snapshot.permanentPurchaseFingerprint : null;
  bool get isPremium => _snapshot.hasPremiumAt(DateTime.now().toUtc());
  bool get isTemporaryPremium => isPremium && !_snapshot.permanent;
  DateTime? get temporaryPremiumUntilUtc => _snapshot.temporaryUntilUtc;
  Duration get temporaryPremiumRemaining =>
      _snapshot.remainingAt(DateTime.now().toUtc());
  bool get isOnline => _networkGate.isOnline;
  bool get canUseApp => isPremium || isOnline;
  bool get canExportPdf => isPremium;
  bool get shouldShowRewardedPremium => !isPremium;
  bool get rewardFlowBusy => _rewardFlowBusy;
  int get rewardedViewsToday => _snapshot.rewardedViewsToday;
  int get rewardedViewsRemaining =>
      (MonetizationConfig.rewardedViewsRequiredForDailyPremium -
              _snapshot.rewardedViewsToday)
          .clamp(0, MonetizationConfig.rewardedViewsRequiredForDailyPremium)
          .toInt();
  bool get redeemingPromo => _redeemingPromo;
  String? get promoMessageCode => _promoMessageCode;
  bool get privacyOptionsRequired => _adService.privacyOptionsRequired;
  MizanPurchaseService get purchaseService => _purchaseService;

  Future<void> initialize() async {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);

    _snapshot = await _entitlementStore.load();
    _networkGate.addListener(_onNetworkChanged);
    _purchaseService.addListener(_onPurchaseChanged);
    _adService.addListener(_relayChange);
    await _applyPremiumAdSuppression();

    _lastFullScreenAdAtUtc = DateTime.now().toUtc();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_tick());
    });
    _initialized = true;
    notifyListeners();

    unawaited(_startOnlineServices());
  }

  Future<void> _startOnlineServices() async {
    if (_onlineServicesStarting) return;
    _onlineServicesStarting = true;
    try {
      await _networkGate.start();
      if (_networkGate.isOnline) {
        await _handleOnlineAvailable();
      }
    } finally {
      _onlineServicesStarting = false;
    }
  }

  Future<void> _ensurePurchaseInitialized() async {
    if (_purchaseInitialized) return;
    await _purchaseService.initialize();
    _purchaseInitialized = true;
  }

  Future<void> _handleOnlineAvailable() async {
    await _ensurePurchaseInitialized();
    await _purchaseService.synchronizeOwnedPurchases();
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    if (!isPremium) {
      unawaited(_adService.initializeForFreeUser());
    }
  }

  Future<void> _tick() async {
    if (_snapshot.temporaryUntilUtc != null && !isPremium) {
      await _refreshSnapshot();
      await _applyPremiumAdSuppression();
      if (!isPremium && _networkGate.isOnline) {
        unawaited(_adService.initializeForFreeUser());
      }
    }
    notifyListeners();
  }

  void _relayChange() => notifyListeners();

  void _onNetworkChanged() {
    if (_networkGate.isOnline) {
      unawaited(_handleOnlineAvailable());
    }
    notifyListeners();
  }

  void _onPurchaseChanged() {
    unawaited(_refreshSnapshotAndAds());
    notifyListeners();
  }

  Future<void> _refreshSnapshotAndAds() async {
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
  }

  Future<void> _refreshSnapshot() async {
    if (_refreshingEntitlement) return;
    _refreshingEntitlement = true;
    try {
      _snapshot = await _entitlementStore.load();
    } finally {
      _refreshingEntitlement = false;
    }
    notifyListeners();
  }

  Future<void> _applyPremiumAdSuppression() async {
    await _adService.setPremiumSuppressed(isPremium);
  }

  Future<String?> refreshPermanentPurchaseProof() async {
    if (!_networkGate.isOnline) return permanentPurchaseFingerprint;
    await _ensurePurchaseInitialized();
    await _purchaseService.synchronizeOwnedPurchases();
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    return permanentPurchaseFingerprint;
  }

  Future<bool> buyPermanentPremium() async {
    if (isPermanentPremium) return true;
    if (!_networkGate.isOnline) return false;
    await _ensurePurchaseInitialized();
    final started = await _purchaseService.buyPermanentPremium();
    notifyListeners();
    return started;
  }

  Future<bool> watchRewardedForDailyPremium() async {
    if (isPremium ||
        !_networkGate.isOnline ||
        rewardedViewsRemaining <= 0 ||
        _rewardFlowBusy) {
      return false;
    }

    _rewardFlowBusy = true;
    notifyListeners();
    try {
      final earned = await _adService.showRewarded();
      if (!earned) return false;

      _snapshot = await _entitlementStore.recordRewardedView();
      if (_snapshot.rewardedViewsToday >=
          MonetizationConfig.rewardedViewsRequiredForDailyPremium) {
        _snapshot = await _entitlementStore.grantTemporaryDuration(
          MonetizationConfig.rewardedPremiumDuration,
        );
      }
      await _applyPremiumAdSuppression();
      notifyListeners();
      return true;
    } finally {
      _rewardFlowBusy = false;
      notifyListeners();
    }
  }

  Future<PromoRedemptionResult> redeemPromo(String code) async {
    if (_redeemingPromo) {
      return const PromoRedemptionResult(accepted: false, messageCode: 'busy');
    }

    _redeemingPromo = true;
    _promoMessageCode = null;
    notifyListeners();
    try {
      final result = await _promoService.redeem(code);
      final duration = result.premiumDuration;
      if (result.accepted && duration != null) {
        _snapshot = await _entitlementStore.grantTemporaryDuration(duration);
        await _applyPremiumAdSuppression();
      }
      _promoMessageCode = result.messageCode;
      notifyListeners();
      return result;
    } finally {
      _redeemingPromo = false;
      notifyListeners();
    }
  }

  void recordMeaningfulCompletedAction() {
    if (isPremium) return;
    _meaningfulActionsSinceAd++;
    if (_meaningfulActionsSinceAd >=
        MonetizationConfig.behaviorActionThreshold) {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 350), () async {
          await onBehaviorAdBreak();
        }),
      );
    }
  }

  Future<bool> onTimeAdBreak() => _attemptAdBreak(AdBreakTrigger.time);

  Future<bool> onBehaviorAdBreak() => _attemptAdBreak(AdBreakTrigger.behavior);

  Future<bool> onNaturalAdBreak() => onTimeAdBreak();

  Future<bool> _attemptAdBreak(AdBreakTrigger trigger) async {
    if (isPremium || !_networkGate.isOnline) return false;
    final now = DateTime.now().toUtc();
    final elapsed = now.difference(_lastFullScreenAdAtUtc);
    final eligible = MonetizationPolicy.adBreakEligible(
      trigger: trigger,
      premium: isPremium,
      online: _networkGate.isOnline,
      sinceLastFullScreenAd: elapsed,
      completedMeaningfulActions: _meaningfulActionsSinceAd,
    );
    if (!eligible) return false;

    final shown = await _adService.showInterstitialAtNaturalBreak();
    if (shown) {
      _lastFullScreenAdAtUtc = DateTime.now().toUtc();
      _meaningfulActionsSinceAd = 0;
      notifyListeners();
    }
    return shown;
  }

  Future<void> showPrivacyOptions() => _adService.showPrivacyOptions();

  Future<void> refreshInternetNow() => _networkGate.checkNow();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_onResume());
  }

  Future<void> _onResume() async {
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    await _networkGate.checkNow();
    if (_networkGate.isOnline) {
      await _handleOnlineAvailable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _networkGate.removeListener(_onNetworkChanged);
    _purchaseService.removeListener(_onPurchaseChanged);
    _adService.removeListener(_relayChange);
    _networkGate.dispose();
    _purchaseService.dispose();
    _adService.dispose();
    super.dispose();
  }
}
