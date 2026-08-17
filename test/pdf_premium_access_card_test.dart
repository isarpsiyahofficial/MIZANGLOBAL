import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/widgets/pdf_premium_access_card.dart';

Widget _host({
  required bool isPremium,
  required VoidCallback onSave,
  required VoidCallback onShare,
}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: PdfPremiumAccessCard(
        controller: null,
        isPremium: isPremium,
        generating: false,
        onSave: onSave,
        onShare: onShare,
      ),
    ),
  ),
);

void main() {
  setUp(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  testWidgets(
    'free user sees PDF lock and sample preview but no export actions',
    (tester) async {
      var saves = 0;
      var shares = 0;
      await tester.pumpWidget(
        _host(isPremium: false, onSave: () => saves++, onShare: () => shares++),
      );

      expect(find.byKey(const ValueKey('pdf-pro-locked')), findsOneWidget);
      expect(find.byKey(const ValueKey('pdf-pro-lock-banner')), findsOneWidget);
      expect(find.byKey(const ValueKey('pdf-preview-button')), findsOneWidget);
      expect(find.byKey(const ValueKey('pdf-save-enabled')), findsNothing);
      expect(find.byKey(const ValueKey('pdf-share-enabled')), findsNothing);
      expect(saves, 0);
      expect(shares, 0);

      await tester.tap(find.byKey(const ValueKey('pdf-preview-button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('pdf-sample-page')), findsOneWidget);
      expect(find.text('Örnek PDF önizlemesi'), findsOneWidget);
      expect(
        find.textContaining('Kendi kayıtların kullanılmaz'),
        findsOneWidget,
      );
      expect(saves, 0);
      expect(shares, 0);
    },
  );

  testWidgets('active PRO removes the lock and enables real PDF actions', (
    tester,
  ) async {
    var saves = 0;
    var shares = 0;
    await tester.pumpWidget(
      _host(isPremium: true, onSave: () => saves++, onShare: () => shares++),
    );

    expect(find.byKey(const ValueKey('pdf-pro-unlocked')), findsOneWidget);
    expect(find.byKey(const ValueKey('pdf-pro-active-banner')), findsOneWidget);
    expect(find.byKey(const ValueKey('pdf-pro-lock-banner')), findsNothing);
    expect(find.byKey(const ValueKey('pdf-preview-button')), findsNothing);
    expect(find.byKey(const ValueKey('pdf-save-enabled')), findsOneWidget);
    expect(find.byKey(const ValueKey('pdf-share-enabled')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('pdf-save-enabled')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('pdf-share-enabled')));
    await tester.pump();

    expect(saves, 1);
    expect(shares, 1);
  });

  test('PDF access copy covers exactly every supported MIZAN language', () {
    expect(
      PdfAccessStrings.supportedLanguageTags,
      MizanI18n.supportedLanguageTags,
    );
    const keys = <String>{
      'pdfTitle',
      'lockedTitle',
      'lockedHint',
      'lockedBody',
      'unlockedHint',
      'preview',
      'previewTitle',
      'previewNotice',
      'download',
      'share',
      'preparing',
    };
    for (final languageTag in MizanI18n.supportedLanguageTags) {
      for (final key in keys) {
        final value = PdfAccessStrings.text(languageTag, key).trim();
        expect(value, isNotEmpty, reason: '$languageTag/$key is empty');
        expect(value, isNot(key), reason: '$languageTag/$key fell back to key');
      }
    }
  });
}
