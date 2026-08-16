abstract final class MonetizationConfig {
  static const String permanentPremiumProductId = 'premium_lifetime';

  // Google-provided sample IDs. Production release must replace all of them.
  static const String androidTestAdMobAppId =
      'ca-app-pub-3940256099942544~3347511713';
  static const String androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';

  static const Duration networkPollInterval = Duration(seconds: 10);
  static const Duration fullScreenAdCooldown = Duration(seconds: 120);
  static const int behaviorActionThreshold = 3;

  static const int rewardedViewsRequiredForDailyPremium = 3;
  static const Duration rewardedPremiumDuration = Duration(days: 1);

  // Configure with --dart-define=MIZAN_MONETIZATION_API=https://...
  // Promo redemption deliberately has no insecure local fallback.
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
  // Production builds must set this true after the verification Worker is live.
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
}
