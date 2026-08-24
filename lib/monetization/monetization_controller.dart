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
      promoService:
          promoService ??
          MizanPromoCodeService(
            grant: (duration) async {
              await resolvedStore.grantTemporaryDuration(duration);
            },
          ),
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
  bool _legalAccessGranted = false;
  bool _purchaseInitialized = false;
  bool _onlineServicesStarting = false;
  bool _redeemingPromo = false;
  bool _rewardFlowBusy = false;
  String? _promoMessageCode;
  int _meaningfulActionsSinceAd = 0;
  final Stopwatch _fullScreenAdClock = Stopwatch();
  final Stopwatch _premiumClock = Stopwatch();
  DateTime _premiumClockAnchorUtc = DateTime.now().toUtc();
  Timer? _tickTimer;
  Future<void>? _refreshEntitlementFuture;

  DateTime get _premiumNowUtc =>
      _premiumClockAnchorUtc.add(_premiumClock.elapsed);

  void _anchorPremiumClock(DateTime trustedUtc) {
    _premiumClockAnchorUtc = trustedUtc.toUtc();
    _premiumClock
      ..reset()
      ..start();
  }

  Future<void> _refreshPremiumClockAnchor() async {
    final current = _premiumClock.isRunning
        ? _premiumNowUtc
        : DateTime.now().toUtc();
    try {
      final trusted = await _entitlementStore.trustedNowUtc();
      _anchorPremiumClock(trusted.isAfter(current) ? trusted : current);
    } on Object {
      final wallClock = DateTime.now().toUtc();
      _anchorPremiumClock(wallClock.isAfter(current) ? wallClock : current);
    }
  }

  bool get initialized => _initialized;
  bool get legalAccessGranted => _legalAccessGranted;
  bool get isPermanentPremium => _snapshot.permanent;
  String? get permanentPurchaseFingerprint =>
      isPermanentPremium ? _snapshot.permanentPurchaseFingerprint : null;
  bool get isPremium => _snapshot.hasPremiumAt(_premiumNowUtc);
  bool get isTemporaryPremium => isPremium && !_snapshot.permanent;
  DateTime? get temporaryPremiumUntilUtc => _snapshot.temporaryUntilUtc;
  Duration get temporaryPremiumRemaining =>
      _snapshot.remainingAt(_premiumNowUtc);
  bool get isOnline => _networkGate.isOnline;
  bool get canUseApp => _legalAccessGranted && (isPremium || isOnline);
  bool get canExportPdf => _legalAccessGranted && isPremium;
  bool get shouldShowRewardedPremium => _legalAccessGranted && !isPremium;
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

  Future<void> _runSafely(Future<void> Function() operation) async {
    try {
      await operation();
    } on Object {
      return;
    }
  }

  Future<void> initialize({bool legalAccessGranted = true}) async {
    if (_initialized) return;
    WidgetsBinding.instance.addObserver(this);
    _legalAccessGranted = _legalAccessGranted || legalAccessGranted;

    try {
      _snapshot = await _entitlementStore.load();
    } on Object {
      _snapshot = const PremiumSnapshot(
        permanent: false,
        temporaryUntilUtc: null,
        rewardDateUtc: '',
        rewardedViewsToday: 0,
        permanentPurchaseFingerprint: null,
      );
    }
    await _refreshPremiumClockAnchor();
    _networkGate.addListener(_onNetworkChanged);
    _purchaseService.addListener(_onPurchaseChanged);
    _adService.addListener(_relayChange);
    await _runSafely(_applyPremiumAdSuppression);

    _fullScreenAdClock
      ..reset()
      ..start();
    _tickTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      unawaited(_runSafely(_tick));
    });
    _initialized = true;
    notifyListeners();

    unawaited(_runSafely(_startOnlineServices));
  }

  Future<void> activateAfterLegalAcceptance() async {
    if (_legalAccessGranted) return;
    _legalAccessGranted = true;
    notifyListeners();
    if (_networkGate.isOnline) {
      await _runSafely(_handleOnlineAvailable);
    }
  }

  Future<void> _startOnlineServices() async {
    if (_onlineServicesStarting) return;
    _onlineServicesStarting = true;
    try {
      await _networkGate.start();
      if (_networkGate.isOnline && _legalAccessGranted) {
        await _handleOnlineAvailable();
      }
    } finally {
      _onlineServicesStarting = false;
    }
  }

  Future<void> _ensurePurchaseInitialized() async {
    if (!_legalAccessGranted || _purchaseInitialized) return;
    await _purchaseService.initialize();
    _purchaseInitialized = true;
  }

  Future<void> _handleOnlineAvailable() async {
    if (!_legalAccessGranted) return;
    await _ensurePurchaseInitialized();
    if (!_purchaseInitialized) return;
    await _purchaseService.synchronizeOwnedPurchases();
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    if (!isPremium) {
      unawaited(_runSafely(_adService.initializeForFreeUser));
    }
  }

  Future<void> _tick() async {
    if (_snapshot.temporaryUntilUtc != null && !isPremium) {
      await _refreshSnapshot();
      await _applyPremiumAdSuppression();
      if (_legalAccessGranted && !isPremium && _networkGate.isOnline) {
        unawaited(_runSafely(_adService.initializeForFreeUser));
      }
    }
    notifyListeners();
  }

  void _relayChange() => notifyListeners();

  void _onNetworkChanged() {
    if (_legalAccessGranted && _networkGate.isOnline) {
      unawaited(_runSafely(_handleOnlineAvailable));
    }
    notifyListeners();
  }

  void _onPurchaseChanged() {
    if (_legalAccessGranted) {
      unawaited(_runSafely(_refreshSnapshotAndAds));
    }
    notifyListeners();
  }

  Future<void> _refreshSnapshotAndAds() async {
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
  }

  Future<void> _refreshSnapshot() async {
    final active = _refreshEntitlementFuture;
    if (active != null) {
      await active;
      return;
    }
    final refresh = _performSnapshotRefresh();
    _refreshEntitlementFuture = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_refreshEntitlementFuture, refresh)) {
        _refreshEntitlementFuture = null;
      }
    }
  }

  Future<void> _performSnapshotRefresh() async {
    try {
      final current = _premiumClock.isRunning
          ? _premiumNowUtc
          : DateTime.now().toUtc();
      await _entitlementStore.trustedNowUtc(current);
      _snapshot = await _entitlementStore.load();
      await _refreshPremiumClockAnchor();
      notifyListeners();
    } on Object {
      return;
    }
  }

  Future<void> _applyPremiumAdSuppression() async {
    try {
      await _adService.setPremiumSuppressed(isPremium);
    } on Object {
      return;
    }
  }

  Future<String?> refreshPermanentPurchaseProof() async {
    if (!_legalAccessGranted || !_networkGate.isOnline) return null;
    try {
      await _ensurePurchaseInitialized();
      if (!_purchaseInitialized) return null;
      await _purchaseService.synchronizeOwnedPurchases();
      await _refreshSnapshot();
      await _applyPremiumAdSuppression();
      return permanentPurchaseFingerprint;
    } on Object {
      return null;
    }
  }

  Future<bool> buyPermanentPremium() async {
    if (!_legalAccessGranted) return false;
    if (isPermanentPremium) return true;
    if (!_networkGate.isOnline) return false;
    try {
      await _ensurePurchaseInitialized();
      if (!_purchaseInitialized) return false;
      final started = await _purchaseService.buyPermanentPremium();
      notifyListeners();
      return started;
    } on Object {
      return false;
    }
  }

  Future<bool> watchRewardedForDailyPremium() async {
    if (!_legalAccessGranted ||
        isPremium ||
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
      await _refreshPremiumClockAnchor();
      await _applyPremiumAdSuppression();
      notifyListeners();
      return true;
    } on Object {
      return false;
    } finally {
      _rewardFlowBusy = false;
      notifyListeners();
    }
  }

  Future<PromoRedemptionResult> redeemPromo(String code) async {
    if (!_legalAccessGranted) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'legal_not_accepted',
      );
    }
    if (_redeemingPromo) {
      return const PromoRedemptionResult(accepted: false, messageCode: 'busy');
    }

    _redeemingPromo = true;
    _promoMessageCode = null;
    notifyListeners();
    try {
      final result = await _promoService.redeem(code);
      if (result.accepted) {
        await _refreshSnapshot();
        await _applyPremiumAdSuppression();
      }
      _promoMessageCode = result.messageCode;
      notifyListeners();
      return result;
    } on Object {
      _promoMessageCode = 'invalid_code';
      notifyListeners();
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'invalid_code',
      );
    } finally {
      _redeemingPromo = false;
      notifyListeners();
    }
  }

  void recordMeaningfulCompletedAction() {
    if (!_legalAccessGranted || isPremium) return;
    _meaningfulActionsSinceAd++;
    if (_meaningfulActionsSinceAd >=
        MonetizationConfig.behaviorActionThreshold) {
      unawaited(
        Future<void>.delayed(const Duration(milliseconds: 350), () async {
          await _runSafely(() async {
            await onBehaviorAdBreak();
          });
        }),
      );
    }
  }

  Future<bool> onTimeAdBreak() => _attemptAdBreak(AdBreakTrigger.time);

  Future<bool> onBehaviorAdBreak() => _attemptAdBreak(AdBreakTrigger.behavior);

  Future<bool> onNaturalAdBreak() => onTimeAdBreak();

  Future<bool> _attemptAdBreak(AdBreakTrigger trigger) async {
    if (!_legalAccessGranted || isPremium || !_networkGate.isOnline) {
      return false;
    }
    final eligible = MonetizationPolicy.adBreakEligible(
      trigger: trigger,
      premium: isPremium,
      online: _networkGate.isOnline,
      sinceLastFullScreenAd: _fullScreenAdClock.elapsed,
      completedMeaningfulActions: _meaningfulActionsSinceAd,
    );
    if (!eligible) return false;

    bool shown;
    try {
      shown = await _adService.showInterstitialAtNaturalBreak();
    } on Object {
      return false;
    }
    if (shown) {
      _fullScreenAdClock
        ..reset()
        ..start();
      _meaningfulActionsSinceAd = 0;
      notifyListeners();
    }
    return shown;
  }

  Future<void> showPrivacyOptions() async {
    if (!_legalAccessGranted) return;
    await _runSafely(_adService.showPrivacyOptions);
  }

  Future<void> refreshInternetNow() async {
    await _runSafely(() async {
      await _networkGate.checkNow();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_runSafely(_onResume));
  }

  Future<void> _onResume() async {
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    await _networkGate.checkNow();
    if (_legalAccessGranted && _networkGate.isOnline) {
      await _handleOnlineAvailable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _fullScreenAdClock.stop();
    _premiumClock.stop();
    _networkGate.removeListener(_onNetworkChanged);
    _purchaseService.removeListener(_onPurchaseChanged);
    _adService.removeListener(_relayChange);
    _networkGate.dispose();
    _purchaseService.dispose();
    _adService.dispose();
    super.dispose();
  }
}
