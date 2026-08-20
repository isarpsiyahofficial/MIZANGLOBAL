import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/legal/legal_turkish_documents.dart';
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
    '$tag: stale acceptance versions never unlock current documents',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{
        'mizan_legal_acceptance_version': '2026-08-19-r2',
        'mizan_purchase_terms_version': '2026-08-19-r2',
      });

      expect(LegalAcceptanceStore.currentVersion, '2026-08-20-general-r1');
      expect(
        LegalAcceptanceStore.currentPurchaseVersion,
        '2026-08-20-purchase-r1',
      );
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

  test('$tag: full legal texts exclude retired implementation narration', () {
    final masters = <String>[
      LegalTurkishDocuments.privacy,
      LegalTurkishDocuments.terms,
      LegalTurkishDocuments.purchase,
      for (final type in LegalDocumentType.values)
        MizanLegalDocuments.document(type, 'en').englishMaster,
    ].join('\n').toLowerCase();

    for (final forbidden in <String>[
      '120 saniye',
      '120 seconds',
      'iki tamamlanmış anlamlı işlem',
      'two completed meaningful actions',
      'three successfully completed rewarded ads',
      'üç ödüllü reklam',
      'esmanur',
      'd1',
      'worker',
      'play integrity',
      'rdp=1',
      'querypastpurchases',
      'serververificationdata',
      'yürürlük tarihi',
      'effective date',
    ]) {
      expect(masters, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('$tag: retired alternate legal layers cannot return through source', () {
    expect(File('lib/legal/legal_document_focus.dart').existsSync(), isFalse);
    expect(File('lib/legal/legal_locale_summaries.dart').existsSync(), isFalse);
    expect(
      File('lib/legal/serverless_legal_overview.dart').existsSync(),
      isFalse,
    );

    final legalScreen = File(
      'lib/screens/legal_document_screen.dart',
    ).readAsStringSync();
    expect(legalScreen, isNot(contains('localizedOverview')));
    expect(legalScreen, isNot(contains('LegalLocaleSummaries')));
  });

  testWidgets('$tag: partial first-run legal reading cannot count as read', (
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
    final readDone = LegalConsentStrings.text(tag, 'readDone');
    final accept = LegalConsentStrings.text(tag, 'accept');
    await tester.tap(find.text(privacy));
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    final state = tester.state<ScrollableState>(scrollable);
    expect(state.position.maxScrollExtent, greaterThan(40));
    state.position.jumpTo(state.position.maxScrollExtent - 1);
    await tester.pumpAndSettle();
    expect(_button(tester, readDone).onPressed, isNull);

    Navigator.of(tester.element(find.byType(Scaffold).first)).pop(false);
    await tester.pumpAndSettle();
    expect(_button(tester, accept).onPressed, isNull);
    expect(await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(), isFalse);
    expect(
      await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
      isFalse,
    );
  });
}
