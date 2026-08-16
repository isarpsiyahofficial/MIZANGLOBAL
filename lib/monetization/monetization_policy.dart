import 'monetization_config.dart';

abstract final class MonetizationPolicy {
  static bool canUseApp({required bool premium, required bool online}) =>
      premium || online;

  static bool canExportPdf({required bool premium}) => premium;

  static bool mayLoadOrShowAds({required bool premium, required bool online}) =>
      !premium && online;

  static bool showRewardedPremiumOffer({required bool premium}) => !premium;

  static bool timeAdEligible({
    required bool premium,
    required bool online,
    required Duration sinceLastFullScreenAd,
  }) =>
      mayLoadOrShowAds(premium: premium, online: online) &&
      sinceLastFullScreenAd >= MonetizationConfig.fullScreenAdCooldown;

  static bool behaviorAdEligible({
    required bool premium,
    required bool online,
    required Duration sinceLastFullScreenAd,
    required int completedMeaningfulActions,
  }) =>
      mayLoadOrShowAds(premium: premium, online: online) &&
      sinceLastFullScreenAd >= MonetizationConfig.fullScreenAdCooldown &&
      completedMeaningfulActions >= MonetizationConfig.behaviorActionThreshold;

  static bool rewardEarned({required int completedRewardedViewsToday}) =>
      completedRewardedViewsToday >=
      MonetizationConfig.rewardedViewsRequiredForDailyPremium;
}
