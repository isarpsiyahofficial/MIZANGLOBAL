abstract final class MonetizationConfig {
  static const String permanentPremiumProductId = 'premium_lifetime';

  // Google-provided sample IDs. These are the only IDs permitted in test mode.
  static const String androidTestAdMobAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';

  static const String androidProductionInterstitialId = String.fromEnvironment(
    'MIZAN_ADMOB_INTERSTITIAL_ID',
    defaultValue: '',
  );
  static const String androidProductionRewardedId = String.fromEnvironment(
    'MIZAN_ADMOB_REWARDED_ID',
    defaultValue: '',
  );

  static const Duration networkPollInterval = Duration(seconds: 10);
  static const Duration fullScreenAdCooldown = Duration(seconds: 120);
  static const int behaviorActionThreshold = 3;

  static const int rewardedViewsRequiredForDailyPremium = 3;
  static const Duration rewardedPremiumDuration = Duration(days: 1);

  // Configure with --dart-define=MIZAN_MONETIZATION_API=https://...
  // Promo and rewarded entitlement flows deliberately have no insecure local
  // authority fallback.
  static const String monetizationApiBaseUrl = String.fromEnvironment(
    'MIZAN_MONETIZATION_API',
    defaultValue: '',
  );

  // Required for Standard Play Integrity token preparation in production.
  static const int playIntegrityCloudProjectNumber = int.fromEnvironment(
    'MIZAN_PLAY_INTEGRITY_CLOUD_PROJECT_NUMBER',
    defaultValue: 0,
  );

  // Development may test Google Play Billing without a deployed backend.
  // Production release must set this true after the verification Worker is live.
  static const bool requireBillingBackendVerification = bool.fromEnvironment(
    'MIZAN_REQUIRE_BILLING_BACKEND',
    defaultValue: false,
  );

  // Reachability is independent of the entitlement backend. This endpoint
  // returns a tiny response and is used only to determine real internet access.
  static const String reachabilityUrl = String.fromEnvironment(
    'MIZAN_REACHABILITY_URL',
    defaultValue: 'https://www.google.com/generate_204',
  );

  static const bool useTestAds = bool.fromEnvironment(
    'MIZAN_TEST_ADS',
    defaultValue: true,
  );

  static String get androidInterstitialAdUnitId => resolveAdUnitId(
    useTestAds: useTestAds,
    productionId: androidProductionInterstitialId,
    testId: androidInterstitialTestId,
  );

  static String get androidRewardedAdUnitId => resolveAdUnitId(
    useTestAds: useTestAds,
    productionId: androidProductionRewardedId,
    testId: androidRewardedTestId,
  );

  static String resolveAdUnitId({
    required bool useTestAds,
    required String productionId,
    required String testId,
  }) {
    if (useTestAds) return testId;
    final normalized = productionId.trim();
    if (normalized.isEmpty ||
        normalized.contains('3940256099942544') ||
        !normalized.startsWith('ca-app-pub-') ||
        !normalized.contains('/')) {
      throw StateError(
        'A valid production AdMob ad unit ID is required when MIZAN_TEST_ADS=false.',
      );
    }
    return normalized;
  }
}
