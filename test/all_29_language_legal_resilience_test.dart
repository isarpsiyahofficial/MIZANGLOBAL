import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_locale_summaries.dart';
import 'package:lefferion_prime_mizan/screens/legal_consent_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tags = <String>[
  'tr',
  'en',
  'es',
  'pt-BR',
  'pt-PT',
  'fr',
  'de',
  'it',
  'nl',
  'pl',
  'ro',
  'el',
  'ru',
  'uk',
  'ar',
  'fa',
  'he',
  'hi',
  'bn',
  'ur',
  'id',
  'ms',
  'fil',
  'vi',
  'th',
  'sw',
  'zh',
  'ja',
  'ko',
];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

FilledButton _button(WidgetTester tester, String label) =>
    tester.widget<FilledButton>(find.widgetWithText(FilledButton, label));

RegExp? _nativeScript(String tag) => switch (tag) {
  'el' => RegExp('[\u0370-\u03ff]'),
  'ru' || 'uk' => RegExp('[\u0400-\u04ff]'),
  'ar' || 'fa' || 'ur' => RegExp('[\u0600-\u06ff]'),
  'he' => RegExp('[\u0590-\u05ff]'),
  'hi' => RegExp('[\u0900-\u097f]'),
  'bn' => RegExp('[\u0980-\u09ff]'),
  'th' => RegExp('[\u0e00-\u0e7f]'),
  'zh' => RegExp('[\u4e00-\u9fff]'),
  'ja' => RegExp('[\u3040-\u30ff\u4e00-\u9fff]'),
  'ko' => RegExp('[\uac00-\ud7af]'),
  _ => null,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final tag = _requestedTag;
  if (!_tags.contains(tag)) {
    throw StateError('Unsupported MIZAN_TEST_LOCALE=$tag');
  }

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test(
    '$tag: stale legal acceptance versions never unlock current terms',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'mizan_legal_acceptance_version': 'stale-version',
        'mizan_purchase_terms_version': 'stale-version',
      });
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(),
        isFalse,
      );
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
        isFalse,
      );
    },
  );

  test('$tag: localized legal summaries are substantial and non-fallback', () {
    for (final type in LegalDocumentType.values) {
      final localized = LegalLocaleSummaries.overview(type, tag).trim();
      final english = LegalLocaleSummaries.overview(type, 'en').trim();
      expect(localized.length, greaterThan(220), reason: '$tag/$type length');
      expect(localized, isNot(contains('TODO')), reason: '$tag/$type TODO');
      expect(
        localized,
        isNot(contains('PLACEHOLDER')),
        reason: '$tag/$type placeholder',
      );
      if (tag != 'en') {
        expect(
          localized,
          isNot(english),
          reason: '$tag/$type English fallback',
        );
      }
      final script = _nativeScript(tag);
      if (script != null) {
        expect(
          script.hasMatch(localized),
          isTrue,
          reason: '$tag/$type native script',
        );
      }
    }
  });

  testWidgets('$tag: partial legal reading cannot be counted as read', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(const <String, Object>{});
    MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: LegalConsentScreen(onAccepted: () {})),
    );
    await tester.pumpAndSettle();

    final privacy = LegalConsentStrings.text(tag, 'privacy');
    final readAll = LegalConsentStrings.text(tag, 'readAll');
    final accept = LegalConsentStrings.text(tag, 'accept');
    await tester.tap(find.text(privacy));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    final state = tester.state<ScrollableState>(scrollable);
    expect(state.position.maxScrollExtent, greaterThan(40));
    state.position.jumpTo(state.position.maxScrollExtent - 1);
    await tester.pumpAndSettle();
    expect(_button(tester, readAll).onPressed, isNull);

    state.position.jumpTo(state.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(_button(tester, readAll).onPressed, isNotNull);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pop(false);
    await tester.pumpAndSettle();
    expect(_button(tester, accept).onPressed, isNull);
    expect(await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(), isFalse);
  });
}
