import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('Hindi reports localize system copy and preserve linked user data', () {
    final now = DateTime(2026, 8, 5, 12);
    final state = comprehensiveState(reference: now, currencyCode: 'INR')
        .copyWith(
          appLanguageTag: 'hi',
          debtRegionCountryCode: 'IN',
          defaultCurrencyCode: 'INR',
        );
    MizanI18n.setProfile(languageTag: 'hi', currencyCode: 'INR');

    final report = const MizanReportService().build(
      state: state,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: now),
      now: now,
    );

    expect(report.languageTag, 'hi');
    expect(report.currencyCode, 'INR');
    expect(report.filter.period.label, 'मासिक');
    expect(report.range.label, 'अगस्त 2026');
    expect(
      report.realizedDistribution.map((entry) => entry.label),
      contains('खर्च'),
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('İbrahim')),
      isTrue,
    );
    expect(
      report.remainingDetails.any((item) => item.title.contains('Kart borcu')),
      isTrue,
    );
    expect(
      report.selectedPersonNames.any((value) => value.contains('\u{E000}')),
      isFalse,
    );
    for (final leak in const ['Ağustos', 'אוגוסט', 'أغسطس', 'اوت', 'август']) {
      expect(report.range.label, isNot(contains(leak)));
    }
  });

  test(
    'Hindi destructive confirmation accepts only its configured phrase',
    () async {
      final state = comprehensiveState().copyWith(
        appLanguageTag: 'hi',
        debtRegionCountryCode: 'IN',
        defaultCurrencyCode: 'INR',
      );
      final controller = MizanController(
        MemoryStore(state),
        scheduler: SpyScheduler(),
      );
      await controller.load();
      final categoryId = controller.state.expenseCategories.first.id;

      for (final wrong in const [
        'ONAYLIYORUM',
        'I CONFIRM',
        'CONFIRMO',
        'JE CONFIRME',
        'ICH BESTÄTIGE',
        'أؤكد',
        'תأیید می‌کنم',
        'אני מאשר',
        'मैं पुष्टि करता हूँ',
      ]) {
        await expectLater(
          controller.deleteExpenseCategory(
            categoryId: categoryId,
            confirmation: wrong,
          ),
          throwsA(isA<ArgumentError>()),
        );
      }

      await controller.deleteExpenseCategory(
        categoryId: categoryId,
        confirmation: '  मैं सहमत हूँ  ',
      );
      expect(
        controller.state.expenseCategories.any((item) => item.id == categoryId),
        isFalse,
      );
      expect(
        controller.state.expenses.any((item) => item.categoryId == categoryId),
        isFalse,
      );
      controller.dispose();
    },
  );
}
