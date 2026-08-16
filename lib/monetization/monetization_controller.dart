import 'dart:async';

import 'package:flutter/widgets.dart';

import 'ad_service.dart';
import 'monetization_api.dart';
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
    MizanMonetizationApi? api,
    MizanPurchaseService? purchaseService,
  }) {
    final resolvedStore = entitlementStore ?? PremiumEntitlementStore();
    final resolvedApi = api ?? MizanMonetizationApi();
    return MonetizationController._(
      entitlementStore: resolvedStore,
      networkGate: networkGate ?? NetworkGateService(),
      adService: adService ?? MizanAdService(),
      api: resolvedApi,
      purchaseService:
          purchaseService ??
          MizanPurchaseService(
            entitlementStore: resolvedStore,
            api: resolvedApi,
          ),
    );
  }

  MonetizationController._({
    required PremiumEntitlementStore entitlementStore,
    required NetworkGateService networkGate,
    required MizanAdService adService,
    required MizanMonetizationApi api,
    required MizanPurchaseService purchaseService,
  }) : _entitlementStore = entitlementStore,
       _networkGate = networkGate,
       _adService = adService,
       _api = api,
       _purchaseService = purchaseService;

  final PremiumEntitlementStore _entitlementStore;
  final NetworkGateService _networkGate;
  final MizanAdService _adService;
  final MizanMonetizationApi _api;
  final MizanPurchaseService _purchaseService;

  PremiumSnapshot _snapshot = const PremiumSnapshot(
    permanent: false,
    temporaryUntilUtc: null,
    rewardDateUtc: '',
    rewardedViewsToday: 0,
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

    // A locally cached, previously verified entitlement is loaded before any
    // network work so a PRO user can open and continue using MIZAN offline.
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

    // Connectivity, Play ownership reconciliation, temporary entitlement
    // synchronization, and ad consent stay off the PRO offline startup path.
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

    // The backend is authoritative for temporary promo/reward grants whenever
    // it is reachable. This also restores an active temporary PRO grant after
    // reinstall on the same device identity.
    if (!_snapshot.permanent) {
      await _syncTemporaryEntitlement();
    }
    await _refreshSnapshot();
    await _applyPremiumAdSuppression();
    if (!isPremium) {
      unawaited(_adService.initializeForFreeUser());
    }
  }

  Future<void> _syncTemporaryEntitlement() async {
    if (!_api.isConfigured || !_networkGate.isOnline) return;
    final result = await _api.syncTemporaryEntitlement();
    if (!result.accepted) return;
    _snapshot = await _entitlementStore.applyVerifiedTemporaryState(
      rewardedViewsToday: result.rewardedViewsToday,
      temporaryUntilUtc: result.premiumUntilUtc,
    );
  }

  Future<void> _applyRewardServerState(RewardSessionResult result) async {
    _snapshot = await _entitlementStore.applyVerifiedTemporaryState(
      rewardedViewsToday: result.rewardedViewsToday,
      temporaryUntilUtc: result.premiumUntilUtc,
    );
    await _applyPremiumAdSuppression();
    notifyListeners();
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
        _rewardFlowBusy ||
        !_api.isConfigured) {
      return false;
    }

    _rewardFlowBusy = true;
    notifyListeners();
    try {
      final session = await _api.createRewardSession();
      if (session.premiumUntilUtc != null || session.rewardedViewsToday > 0) {
        await _applyRewardServerState(session);
      }
      final sessionId = session.sessionId;
      if (!session.accepted || sessionId == null || sessionId.isEmpty) {
        return false;
      }

      final clientEarned = await _adService.showRewarded(customData: sessionId);
      if (!clientEarned) return false;

      // PRO time is granted only after the authenticated AdMob SSV callback has
      // reached the backend. Client reward callbacks never increment authority.
      for (var attempt = 0; attempt < 15; attempt++) {
        final status = await _api.rewardSessionStatus(sessionId);
        if (status.accepted) {
          await _applyRewardServerState(status);
          if (status.sessionRewarded) return true;
        }
        if (attempt < 14) {
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }

      // A delayed Google callback is picked up by the normal online entitlement
      // sync on resume/reconnect. No unverified local reward is granted here.
      return false;
    } finally {
      _rewardFlowBusy = false;
      notifyListeners();
    }
  }

  Future<PromoRedemptionResult> redeemPromo(String code) async {
    if (_redeemingPromo) {
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'busy',
      );
    }
    if (!_networkGate.isOnline) {
      _promoMessageCode = 'internet_required';
      notifyListeners();
      return const PromoRedemptionResult(
        accepted: false,
        messageCode: 'internet_required',
      );
    }

    _redeemingPromo = true;
    _promoMessageCode = null;
    notifyListeners();
    try {
      final result = await _api.redeemPromo(code);
      if (result.accepted && result.premiumUntilUtc != null) {
        _snapshot = await _entitlementStore.grantTemporaryUntil(
          result.premiumUntilUtc!,
        );
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
    if (_meaningfulActionsSinceAd >= MonetizationConfig.behaviorActionThreshold) {
      // Durable mutation has completed before this callback. A short UI settle
      // delay keeps the interstitial away from the data-entry interaction itself.
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
    _api.close();
    super.dispose();
  }
}
