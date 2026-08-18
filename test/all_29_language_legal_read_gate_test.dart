import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/legal/legal_consent_strings.dart';
import 'package:lefferion_prime_mizan/legal/legal_documents.dart';
import 'package:lefferion_prime_mizan/screens/legal_consent_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _tags = <String>{
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
};

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

FilledButton _filledButton(WidgetTester tester, String label) =>
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

  testWidgets(
    '$tag: legal documents cannot be accepted without reading to end',
    (tester) async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var acceptedCallback = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LegalConsentScreen(onAccepted: () => acceptedCallback = true),
        ),
      );
      await tester.pumpAndSettle();

      final acceptLabel = LegalConsentStrings.text(tag, 'accept');
      final blockedLabel = LegalConsentStrings.text(tag, 'blocked');
      final readAllLabel = LegalConsentStrings.text(tag, 'readAll');
      final readDoneLabel = LegalConsentStrings.text(tag, 'readDone');
      expect(find.text(blockedLabel), findsOneWidget);
      expect(_filledButton(tester, acceptLabel).onPressed, isNull);
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(),
        isFalse,
      );
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
        isFalse,
      );

      final documents = <(LegalDocumentType, String)>[
        (LegalDocumentType.privacy, LegalConsentStrings.text(tag, 'privacy')),
        (LegalDocumentType.terms, LegalConsentStrings.text(tag, 'terms')),
        (LegalDocumentType.purchase, LegalConsentStrings.text(tag, 'purchase')),
      ];

      for (var index = 0; index < documents.length; index++) {
        final (_, label) = documents[index];
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(FilledButton, readAllLabel),
          findsOneWidget,
          reason: '$tag/$label read-before-scroll gate',
        );
        expect(_filledButton(tester, readAllLabel).onPressed, isNull);

        final scrollable = find.byType(Scrollable).first;
        final state = tester.state<ScrollableState>(scrollable);
        expect(
          state.position.maxScrollExtent,
          greaterThan(0),
          reason: '$tag/$label',
        );
        state.position.jumpTo(state.position.maxScrollExtent);
        await tester.pumpAndSettle();

        expect(
          find.widgetWithText(FilledButton, readDoneLabel),
          findsOneWidget,
          reason: '$tag/$label read-to-end completion',
        );
        expect(_filledButton(tester, readDoneLabel).onPressed, isNotNull);
        await tester.tap(find.widgetWithText(FilledButton, readDoneLabel));
        await tester.pumpAndSettle();

        if (index < documents.length - 1) {
          expect(_filledButton(tester, acceptLabel).onPressed, isNull);
          expect(
            await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(),
            isFalse,
          );
        }
      }

      expect(find.text(blockedLabel), findsNothing);
      expect(_filledButton(tester, acceptLabel).onPressed, isNotNull);
      await tester.tap(find.widgetWithText(FilledButton, acceptLabel));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(acceptedCallback, isTrue);
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentLegalBundle(),
        isTrue,
      );
      expect(
        await LegalAcceptanceStore.hasAcceptedCurrentPurchaseTerms(),
        isTrue,
      );
    },
  );
}
