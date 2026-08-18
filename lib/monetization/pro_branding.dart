import 'monetization_strings.dart';

abstract final class ProBranding {
  static String monetizationText(String languageTag, String key) {
    var raw = MonetizationStrings.text(languageTag, key);
    if (key == 'rewardSubtitle') {
      raw = raw
          .replaceAll('3', '5')
          .replaceAll('٣', '٥')
          .replaceAll('۳', '۵')
          .replaceAll('३', '५')
          .replaceAll('৩', '৫')
          .replaceAll('๓', '๕')
          .replaceAll('３', '５');
    }
    return visibleText(languageTag, raw);
  }

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
