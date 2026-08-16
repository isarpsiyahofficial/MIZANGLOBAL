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

  bool get canRequestAds =>
      _consentResolved && _canRequestAds && !_premiumSuppressed;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  bool get rewardedReady => _rewarded != null && canRequestAds;

  Future<void> initializeForFreeUser() async {
    if (_premiumSuppressed) return;
    await _resolveConsent();
    if (!canRequestAds) return;
    await _initializeSdkIfNeeded();
    await Future.wait([loadInterstitial(), loadRewarded()]);
  }

  Future<void> _resolveConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        unawaited(
          ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
            _consentResolved = true;
            _canRequestAds = await ConsentInformation.instance.canRequestAds();
            _privacyOptionsRequired =
                await ConsentInformation.instance
                    .getPrivacyOptionsRequirementStatus() ==
                PrivacyOptionsRequirementStatus.required;
            notifyListeners();
            if (!completer.isCompleted) completer.complete();
          }),
        );
      },
      (formError) async {
        _consentResolved = true;
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
        _privacyOptionsRequired =
            await ConsentInformation.instance
                .getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        _consentResolved = true;
        _canRequestAds = false;
      },
    );
  }

  Future<void> _initializeSdkIfNeeded() async {
    if (_mobileAdsInitialized || _premiumSuppressed) return;
    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;
  }

  Future<void> setPremiumSuppressed(bool value) async {
    if (_premiumSuppressed == value) return;
    _premiumSuppressed = value;
    if (value) {
      await disposeLoadedAds();
    } else if (_consentResolved && _canRequestAds) {
      await _initializeSdkIfNeeded();
      await Future.wait([loadInterstitial(), loadRewarded()]);
    }
    notifyListeners();
  }

  Future<void> loadInterstitial() async {
    if (!canRequestAds || _interstitialLoading || _interstitial != null) return;
    _interstitialLoading = true;
    final completer = Completer<void>();
    await InterstitialAd.load(
      adUnitId: MonetizationConfig.androidInterstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          if (_premiumSuppressed) {
            unawaited(ad.dispose());
          } else {
            _interstitial = ad;
          }
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          debugPrint('MIZAN interstitial load failed: $error');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future;
  }

  Future<void> loadRewarded() async {
    if (!canRequestAds || _rewardedLoading || _rewarded != null) return;
    _rewardedLoading = true;
    final completer = Completer<void>();
    await RewardedAd.load(
      adUnitId: MonetizationConfig.androidRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedLoading = false;
          if (_premiumSuppressed) {
            unawaited(ad.dispose());
          } else {
            _rewarded = ad;
          }
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedLoading = false;
          debugPrint('MIZAN rewarded load failed: $error');
          if (!completer.isCompleted) completer.complete();
        },
      ),
    );
    await completer.future;
  }

  Future<bool> showInterstitialAtNaturalBreak() async {
    if (!canRequestAds || _fullScreenShowing) return false;
    var ad = _interstitial;
    if (ad == null) {
      await loadInterstitial();
      ad = _interstitial;
    }
    if (ad == null || _premiumSuppressed) return false;

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
    await ad.show();
    return completer.future;
  }

  Future<bool> showRewarded({required String customData}) async {
    if (!canRequestAds || _fullScreenShowing || customData.trim().isEmpty) {
      return false;
    }
    var ad = _rewarded;
    if (ad == null) {
      await loadRewarded();
      ad = _rewarded;
    }
    if (ad == null || _premiumSuppressed) return false;

    await ad.setServerSideOptions(
      ServerSideVerificationOptions(customData: customData.trim()),
    );
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
    await ad.show(
      onUserEarnedReward: (_, _) {
        rewardEarned = true;
      },
    );
    return completer.future;
  }

  Future<void> showPrivacyOptions() async {
    if (!_privacyOptionsRequired) return;
    final completer = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((error) {
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    notifyListeners();
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
