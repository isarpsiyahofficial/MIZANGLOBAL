import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'monetization_config.dart';

class MizanAdService extends ChangeNotifier {
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _interstitialLoading = false;
  bool _rewardedLoading = false;
  bool _mobileAdsInitialized = false;
  bool _consentResolved = false;
  bool _canRequestAds = false;
  bool _premiumSuppressed = false;
  bool _fullScreenShowing = false;
  bool _privacyOptionsRequired = false;
  Future<void>? _consentFuture;

  bool get canRequestAds =>
      _consentResolved && _canRequestAds && !_premiumSuppressed;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  bool get rewardedReady => _rewarded != null && canRequestAds;

  static const AdRequest _privacyPreservingRequest = AdRequest(
    nonPersonalizedAds: true,
    extras: {'rdp': '1'},
  );

  Future<void> initializeForFreeUser() async {
    if (_premiumSuppressed) return;
    await _resolveConsent();
    if (!canRequestAds) return;
    await _initializeSdkIfNeeded();
    if (!canRequestAds) return;
    await Future.wait([loadInterstitial(), loadRewarded()]);
  }

  Future<void> _refreshConsentState() async {
    try {
      final canRequest = await ConsentInformation.instance.canRequestAds();
      final privacyStatus = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      _consentResolved = true;
      _canRequestAds = canRequest;
      _privacyOptionsRequired =
          privacyStatus == PrivacyOptionsRequirementStatus.required;
    } on Object {
      _consentResolved = true;
      _canRequestAds = false;
    }
    notifyListeners();
  }

  Future<void> _resolveConsent() async {
    final active = _consentFuture;
    if (active != null) {
      await active;
      return;
    }
    final resolution = _performConsentResolution();
    _consentFuture = resolution;
    try {
      await resolution;
    } finally {
      if (identical(_consentFuture, resolution)) {
        _consentFuture = null;
      }
    }
  }

  Future<void> _performConsentResolution() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    Future<void> finish() async {
      await _refreshConsentState();
      if (!completer.isCompleted) completer.complete();
    }

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () {
          unawaited(
            ConsentForm.loadAndShowConsentFormIfRequired((formError) {
              unawaited(finish());
            }),
          );
        },
        (formError) {
          unawaited(finish());
        },
      );
      await completer.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          _consentResolved = true;
          _canRequestAds = false;
          notifyListeners();
        },
      );
    } on Object {
      _consentResolved = true;
      _canRequestAds = false;
      notifyListeners();
    }
  }

  Future<void> _initializeSdkIfNeeded() async {
    if (_mobileAdsInitialized || _premiumSuppressed || !canRequestAds) return;
    await MobileAds.instance.initialize();
    if (_premiumSuppressed || !canRequestAds) return;
    _mobileAdsInitialized = true;
  }

  Future<void> setPremiumSuppressed(bool value) async {
    if (_premiumSuppressed == value) return;
    _premiumSuppressed = value;
    if (value) {
      await disposeLoadedAds();
    } else if (_consentResolved && _canRequestAds) {
      await _initializeSdkIfNeeded();
      if (canRequestAds) {
        await Future.wait([loadInterstitial(), loadRewarded()]);
      }
    }
    notifyListeners();
  }

  Future<void> loadInterstitial() async {
    if (!canRequestAds || _interstitialLoading || _interstitial != null) return;
    _interstitialLoading = true;
    final completer = Completer<void>();
    var acceptingResult = true;
    try {
      await InterstitialAd.load(
        adUnitId: MonetizationConfig.androidInterstitialAdUnitId,
        request: _privacyPreservingRequest,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (!acceptingResult || _premiumSuppressed || !canRequestAds) {
              unawaited(ad.dispose());
            } else {
              _interstitial = ad;
            }
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            debugPrint('MIZAN interstitial load failed: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future.timeout(const Duration(seconds: 20));
    } on Object catch (error) {
      debugPrint('MIZAN interstitial load failed: $error');
    } finally {
      acceptingResult = false;
      _interstitialLoading = false;
    }
  }

  Future<void> loadRewarded() async {
    if (!canRequestAds || _rewardedLoading || _rewarded != null) return;
    _rewardedLoading = true;
    final completer = Completer<void>();
    var acceptingResult = true;
    try {
      await RewardedAd.load(
        adUnitId: MonetizationConfig.androidRewardedAdUnitId,
        request: _privacyPreservingRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (!acceptingResult || _premiumSuppressed || !canRequestAds) {
              unawaited(ad.dispose());
            } else {
              _rewarded = ad;
            }
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (error) {
            debugPrint('MIZAN rewarded load failed: $error');
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      await completer.future.timeout(const Duration(seconds: 20));
    } on Object catch (error) {
      debugPrint('MIZAN rewarded load failed: $error');
    } finally {
      acceptingResult = false;
      _rewardedLoading = false;
    }
  }

  Future<bool> showInterstitialAtNaturalBreak() async {
    if (!canRequestAds || _fullScreenShowing) return false;
    var ad = _interstitial;
    if (ad == null) {
      await loadInterstitial();
      ad = _interstitial;
    }
    if (ad == null || _premiumSuppressed || !canRequestAds) return false;

    _interstitial = null;
    _fullScreenShowing = true;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (shownAd) {
        _fullScreenShowing = false;
        unawaited(shownAd.dispose());
        if (!completer.isCompleted) completer.complete(true);
        unawaited(loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        _fullScreenShowing = false;
        unawaited(shownAd.dispose());
        debugPrint('MIZAN interstitial show failed: $error');
        if (!completer.isCompleted) completer.complete(false);
        unawaited(loadInterstitial());
      },
    );
    try {
      await ad.show();
      return await completer.future;
    } on Object catch (error) {
      _fullScreenShowing = false;
      if (!completer.isCompleted) completer.complete(false);
      await ad.dispose();
      debugPrint('MIZAN interstitial show failed: $error');
      unawaited(loadInterstitial());
      return false;
    }
  }

  Future<bool> showRewarded() async {
    if (!canRequestAds || _fullScreenShowing) return false;
    var ad = _rewarded;
    if (ad == null) {
      await loadRewarded();
      ad = _rewarded;
    }
    if (ad == null || _premiumSuppressed || !canRequestAds) return false;

    _rewarded = null;
    _fullScreenShowing = true;
    var rewardEarned = false;
    final completer = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (shownAd) {
        _fullScreenShowing = false;
        unawaited(shownAd.dispose());
        if (!completer.isCompleted) completer.complete(rewardEarned);
        unawaited(loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (shownAd, error) {
        _fullScreenShowing = false;
        unawaited(shownAd.dispose());
        debugPrint('MIZAN rewarded show failed: $error');
        if (!completer.isCompleted) completer.complete(false);
        unawaited(loadRewarded());
      },
    );
    try {
      await ad.show(
        onUserEarnedReward: (_, _) {
          rewardEarned = true;
        },
      );
      return await completer.future;
    } on Object catch (error) {
      _fullScreenShowing = false;
      if (!completer.isCompleted) completer.complete(false);
      await ad.dispose();
      debugPrint('MIZAN rewarded show failed: $error');
      unawaited(loadRewarded());
      return false;
    }
  }

  Future<void> showPrivacyOptions() async {
    if (!_privacyOptionsRequired) return;
    final completer = Completer<void>();
    try {
      await ConsentForm.showPrivacyOptionsForm((error) {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future.timeout(const Duration(seconds: 30));
    } on Object {
      return;
    }
    await disposeLoadedAds();
    await _refreshConsentState();
    if (canRequestAds) {
      await _initializeSdkIfNeeded();
      if (canRequestAds) {
        await Future.wait([loadInterstitial(), loadRewarded()]);
      }
    }
  }

  Future<void> disposeLoadedAds() async {
    final interstitial = _interstitial;
    final rewarded = _rewarded;
    _interstitial = null;
    _rewarded = null;
    if (interstitial != null) await interstitial.dispose();
    if (rewarded != null) await rewarded.dispose();
  }

  @override
  void dispose() {
    final interstitial = _interstitial;
    final rewarded = _rewarded;
    _interstitial = null;
    _rewarded = null;
    if (interstitial != null) unawaited(interstitial.dispose());
    if (rewarded != null) unawaited(rewarded.dispose());
    super.dispose();
  }
}
