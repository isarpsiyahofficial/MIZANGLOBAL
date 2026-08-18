import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/settings_screen.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';

void main() {
  testWidgets('CSV merge confirmation renders every supported language', (
    tester,
  ) async {
    final result = CsvMergeResult(
      state: MizanState.empty(),
      addedCount: 2,
      mergedCount: 1,
      duplicateCount: 3,
    );
    const sources = <String>[
      'CSV yedeğini birleştir',
      'Mevcut kayıtlar silinmeyecek veya yedekteki ortak verilerle yeniden yazılmayacak. Yalnız yeni kayıtlar ve eksik alt ilişkiler eklenecek.',
      'Yeni eklenecek',
      'Eksik ilişkisi tamamlanacak',
      'Ortak kullanıcı kaydı atlanacak',
      'Vazgeç',
      'Verileri birleştir',
    ];

    for (final tag in MizanI18n.supportedLanguageTags) {
      MizanI18n.setProfile(languageTag: tag, currencyCode: 'USD');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CsvMergeConfirmationDialog(result: result)),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('csv-merge-confirmation-dialog')),
        findsOneWidget,
        reason: tag,
      );
      for (final source in sources) {
        final localized = MizanI18n.text(source, languageTag: tag);
        expect(localized.trim(), isNotEmpty, reason: '$tag/$source');
        if (tag != 'tr') {
          expect(localized, isNot(source), reason: '$tag Turkish leak: $source');
        }
      }
      expect(
        find.text(MizanI18n.text('CSV yedeğini birleştir', languageTag: tag)),
        findsOneWidget,
        reason: tag,
      );
      expect(find.byKey(const ValueKey('csv-merge-cancel')), findsOneWidget);
      expect(find.byKey(const ValueKey('csv-merge-confirm')), findsOneWidget);
    }
  });
}
