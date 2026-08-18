import 'monetization_strings.dart';

abstract final class ProBranding {
  static String monetizationText(String languageTag, String key) =>
      visibleText(languageTag, MonetizationStrings.text(languageTag, key));

  static String visibleText(String languageTag, String raw) {
    final localizedPremium = MonetizationStrings.text(languageTag, 'premium');
    var value = raw;
    if (localizedPremium.isNotEmpty && localizedPremium != 'premium') {
      value = value.replaceAll(localizedPremium, 'PRO');
    }
    value = value
        .replaceAll('PREMIUM', 'PRO')
        .replaceAll('Premium', 'PRO')
        .replaceAll('premium', 'PRO');
    return value;
  }
}
