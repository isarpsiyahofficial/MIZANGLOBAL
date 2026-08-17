import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_id.dart';
import 'package:lefferion_prime_mizan/legal/legal_acceptance_store.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/record_form_dialogs.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/pdf_report_service.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_support.dart';

class _LocaleCase {
  const _LocaleCase(this.tag, this.country, this.currency);

  final String tag;
  final String country;
  final String currency;
}

const _localeCases = <_LocaleCase>[
  _LocaleCase('tr', 'TR', 'TRY'),
  _LocaleCase('en', 'US', 'USD'),
  _LocaleCase('es', 'ES', 'EUR'),
  _LocaleCase('pt-BR', 'BR', 'BRL'),
  _LocaleCase('pt-PT', 'PT', 'EUR'),
  _LocaleCase('fr', 'FR', 'EUR'),
  _LocaleCase('de', 'DE', 'EUR'),
  _LocaleCase('it', 'IT', 'EUR'),
  _LocaleCase('nl', 'NL', 'EUR'),
  _LocaleCase('pl', 'PL', 'PLN'),
  _LocaleCase('ro', 'RO', 'RON'),
  _LocaleCase('el', 'GR', 'EUR'),
  _LocaleCase('ru', 'RU', 'RUB'),
  _LocaleCase('uk', 'UA', 'UAH'),
  _LocaleCase('ar', 'SA', 'SAR'),
  _LocaleCase('fa', 'IR', 'IRR'),
  _LocaleCase('he', 'IL', 'ILS'),
  _LocaleCase('hi', 'IN', 'INR'),
  _LocaleCase('bn', 'BD', 'BDT'),
  _LocaleCase('ur', 'PK', 'PKR'),
  _LocaleCase('id', 'ID', 'IDR'),
  _LocaleCase('ms', 'MY', 'MYR'),
  _LocaleCase('fil', 'PH', 'PHP'),
  _LocaleCase('vi', 'VN', 'VND'),
  _LocaleCase('th', 'TH', 'THB'),
  _LocaleCase('sw', 'TZ', 'TZS'),
  _LocaleCase('zh', 'CN', 'CNY'),
  _LocaleCase('ja', 'JP', 'JPY'),
  _LocaleCase('ko', 'KR', 'KRW'),
];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

_LocaleCase get _localeCase => _localeCases.singleWhere(
  (item) => item.tag == _requestedTag,
  orElse: () => throw StateError(
    'Unsupported MIZAN_TEST_LOCALE=$_requestedTag. '
    'Expected one of ${_localeCases.map((item) => item.tag).join(', ')}',
  ),
);

final _now = DateTime(2026, 8, 1, 10);

Future<void> _loadUnicodePdfTestFont() async {
  final fontFile = File('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf');
  if (!await fontFile.exists()) {
    throw StateError('PDF test Unicode font missing: ${fontFile.path}');
  }
  final bytes = await fontFile.readAsBytes();
  final loader = FontLoader('Roboto');
  loader.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
  await loader.load();
}

MizanState _stateFor(_LocaleCase locale) {
  return comprehensiveState(
    reference: _now,
    currencyCode: locale.currency,
  ).copyWith(
    setupCompleted: true,
    appLanguageTag: locale.tag,
    debtRegionCountryCode: locale.country,
    defaultCurrencyCode: locale.currency,
    recentCurrencyCodes: [locale.currency, 'USD', 'EUR'],
  );
}

Future<MizanController> _pumpApp(
  WidgetTester tester,
  _LocaleCase locale,
  Size size, {
  double textScale = 1,
}) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  await LegalAcceptanceStore.acceptCurrentLegalBundle();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  MizanClock.setNowForTesting(_now);
  final controller = MizanController(
    MemoryStore(_stateFor(locale)),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  await tester.pumpWidget(MizanApp(controller: controller));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: '${locale.tag}: initial app');
  return controller;
}

Finder _navigationRoot() {
  final bar = find.byType(NavigationBar);
  return bar.evaluate().isNotEmpty ? bar : find.byType(NavigationRail);
}

const _systemLeakProbeSources = <String>[
  'Ana sayfa',
  'Kayıtlar',
  'Giderler',
  'Raporlar',
  'Ayarlar',
  'Kaydet',
  'Vazgeç',
  'Toplam borç',
  'Aylık tutar',
  'Son ödeme tarihi',
  'Varsayılan para birimi',
  'Gider adı',
  'Birim fiyat',
  'Kişi ekle',
  'Banka adı',
  'Borç türü',
  'Tutar',
  'PDF raporu',
  'Ödeme geçmişi',
  'Kategori',
  'Açıklama',
  'Düzenle',
  'Sil',
  'Ara',
  'Onayla',
];

void _expectNoForeignSystemLeak(WidgetTester tester, _LocaleCase locale) {
  final targetCatalog = mizanIndonesian.keys
      .map((key) => MizanI18n.text(key, languageTag: locale.tag).trim())
      .where((value) => value.isNotEmpty)
      .toSet();
  final visible = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toSet();

  for (final foreign in _localeCases) {
    if (foreign.tag == locale.tag) continue;

    var distinctiveProbes = 0;
    for (final source in _systemLeakProbeSources) {
      final targetCopy = MizanI18n.text(source, languageTag: locale.tag).trim();
      final foreignCopy = MizanI18n.text(
        source,
        languageTag: foreign.tag,
      ).trim();
      if (foreignCopy.isEmpty ||
          foreignCopy == targetCopy ||
          targetCatalog.contains(foreignCopy)) {
        continue;
      }
      distinctiveProbes++;
      expect(
        visible,
        isNot(contains(foreignCopy)),
        reason:
            '${locale.tag} <- ${foreign.tag}: foreign system copy leaked for '
            '"$source": "$foreignCopy"',
      );
    }

    expect(
      distinctiveProbes,
      greaterThan(0),
      reason:
          '${locale.tag} <- ${foreign.tag}: no distinguishable system probe; '
          'pairwise leak coverage would be ineffective',
    );
  }

  expect(
    find.text(MizanI18n.text('Bildirim sistemi')),
    findsNothing,
    reason: '${locale.tag}: removed notification UI returned',
  );
}

Future<void> _visitEveryPrimaryScreen(
  WidgetTester tester,
  _LocaleCase locale,
) async {
  for (final icon in const [
    Icons.people_alt_outlined,
    Icons.shopping_bag_outlined,
    Icons.bar_chart_outlined,
    Icons.settings_outlined,
    Icons.space_dashboard_outlined,
  ]) {
    final target = find.descendant(
      of: _navigationRoot(),
      matching: find.byIcon(icon),
    );
    expect(target, findsOneWidget, reason: '${locale.tag}: navigation $icon');
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(
      tester.takeException(),
      isNull,
      reason: '${locale.tag}: screen $icon overflow/exception',
    );
    _expectNoForeignSystemLeak(tester, locale);
  }
}

Future<void> _openAndCloseDialog(
  WidgetTester tester,
  _LocaleCase locale,
  Future<void> Function() open,
  List<String> requiredSourceCopy, {
  String? expectedCurrencyCode,
}) async {
  final future = open();
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: '${locale.tag}: dialog open/render',
  );
  expect(find.byType(AlertDialog), findsOneWidget, reason: locale.tag);
  for (final source in requiredSourceCopy) {
    final localized = MizanI18n.text(source);
    expect(
      find.text(localized),
      findsWidgets,
      reason:
          '${locale.tag}: missing localized dialog copy for "$source" => "$localized"',
    );
  }
  expect(
    find.text(MizanI18n.text('Kaydet')),
    findsOneWidget,
    reason: '${locale.tag}: save action',
  );
  expect(
    find.text(MizanI18n.text('Vazgeç')),
    findsOneWidget,
    reason: '${locale.tag}: cancel action',
  );
  _expectNoForeignSystemLeak(tester, locale);
  if (expectedCurrencyCode != null) {
    final suffixes = tester
        .widgetList<TextField>(find.byType(TextField))
        .map((field) => field.decoration?.suffixText)
        .whereType<String>()
        .toList(growable: false);
    expect(
      suffixes,
      contains(expectedCurrencyCode),
      reason:
          '${locale.tag}: record money input must use $expectedCurrencyCode',
    );
    if (expectedCurrencyCode != 'TRY') {
      expect(
        suffixes,
        isNot(contains('TL')),
        reason:
            '${locale.tag}: TRY/TL suffix leaked into $expectedCurrencyCode record',
      );
    }
  }

  final dialogContext = tester.element(find.byType(AlertDialog));
  Navigator.of(dialogContext).pop();
  await tester.pumpAndSettle();
  await future;
  expect(tester.takeException(), isNull, reason: '${locale.tag}: dialog close');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locale = _localeCase;

  tearDown(() {
    MizanClock.resetForTesting();
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test('${locale.tag}: runtime, report, backup and destructive flows', () async {
    MizanClock.setNowForTesting(_now);
    final sourceState = _stateFor(locale);
    MizanI18n.setProfile(
      languageTag: locale.tag,
      currencyCode: locale.currency,
    );

    for (final source in const [
      'Ana sayfa',
      'Kayıtlar',
      'Giderler',
      'Raporlar',
      'Ayarlar',
      'Kişi ekle',
      'Banka adı',
      'Borç türü',
      'Tutar',
      'Son ödeme tarihi',
      'PDF raporu',
      'Kaydet',
      'Vazgeç',
    ]) {
      final localized = MizanI18n.text(source);
      expect(localized.trim(), isNotEmpty, reason: '${locale.tag}: $source');
      if (locale.tag != 'tr' && source == 'Ana sayfa') {
        expect(
          localized,
          isNot(source),
          reason: '${locale.tag}: raw Turkish navigation fallback',
        );
      }
    }

    const rawUserCopy = 'İbrahim Bank 24 — 東京 — Việt Nam — M-Pesa';
    final visibleUserCopy = MizanI18n.text(MizanI18n.user(rawUserCopy));
    for (final marker in const [
      'İbrahim',
      'Bank 24',
      '東京',
      'Việt Nam',
      'M-Pesa',
    ]) {
      expect(
        visibleUserCopy,
        contains(marker),
        reason: '${locale.tag}: $marker',
      );
    }
    expect(visibleUserCopy, isNot(contains('\u{E000}')), reason: locale.tag);

    final formatted = money(1234.56, currencyCode: locale.currency);
    expect(
      formatted.trim(),
      isNotEmpty,
      reason: '${locale.tag}: money formatter',
    );

    final report = const MizanReportService().build(
      state: sourceState,
      filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: _now),
      now: _now,
    );
    expect(report.languageTag, locale.tag);
    expect(report.currencyCode, locale.currency);
    expect(report.selectedPersonNames.join(' '), contains('İbrahim'));
    expect(
      report.remainingDetails.any((item) => item.title.contains('Kart borcu')),
      isTrue,
      reason: '${locale.tag}: report user-authored record title',
    );
    expect(
      report.remainingDetails.every(
        (item) => item.currencyCode == locale.currency,
      ),
      isTrue,
      reason: '${locale.tag}: report record currency propagation',
    );

    const backup = CsvBackupService();
    final restored = backup.importState(backup.exportState(sourceState));
    expect(restored.appLanguageTag, locale.tag);
    expect(restored.debtRegionCountryCode, locale.country);
    expect(restored.defaultCurrencyCode, locale.currency);
    expect(restored.hasCompleteRecordCurrencies, isTrue);
    expect(
      restored.allDebtProducts.every(
        (item) => item.currencyCode == locale.currency,
      ),
      isTrue,
    );
    expect(
      restored.allPersonalDebts.every(
        (item) => item.currencyCode == locale.currency,
      ),
      isTrue,
    );
    expect(
      restored.allBills.every((item) => item.currencyCode == locale.currency),
      isTrue,
    );
    expect(
      restored.allSubscriptions.every(
        (item) => item.currencyCode == locale.currency,
      ),
      isTrue,
    );
    expect(
      restored.allRents.every((item) => item.currencyCode == locale.currency),
      isTrue,
    );
    expect(
      restored.expenses.every((item) => item.currencyCode == locale.currency),
      isTrue,
    );

    final controller = MizanController(
      MemoryStore(restored),
      scheduler: SpyScheduler(),
    );
    await controller.load();
    final categoryId = controller.state.expenseCategories.first.id;
    await expectLater(
      controller.deleteExpenseCategory(
        categoryId: categoryId,
        confirmation: '__WRONG_CONFIRMATION__',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isTrue,
    );
    final exactCategoryConfirmation = controller.categoryDeleteConfirmation(
      categoryId,
    );
    final categoryName = controller.state.expenseCategories
        .firstWhere((item) => item.id == categoryId)
        .name;
    expect(
      exactCategoryConfirmation,
      contains(categoryName),
      reason: '${locale.tag}: localized category confirmation',
    );
    expect(exactCategoryConfirmation, isNot(categoryName));
    expect(
      exactCategoryConfirmation,
      MizanI18n.text(
        '"{name}" kategorisini ve bu kategoriye bağlı {count} gider kaydını kalıcı olarak silmek için bu metni aynen yaz.',
        args: {'name': categoryName, 'count': 1},
      ),
    );
    await controller.deleteExpenseCategory(
      categoryId: categoryId,
      confirmation: exactCategoryConfirmation,
    );
    expect(
      controller.state.expenseCategories.any((item) => item.id == categoryId),
      isFalse,
    );
    expect(
      controller.state.expenses.any((item) => item.categoryId == categoryId),
      isFalse,
    );

    final bankId = controller.state.banks.first.id;
    await expectLater(
      controller.deleteBank(
        bankId: bankId,
        confirmation: '__WRONG_CONFIRMATION__',
      ),
      throwsA(isA<FormatException>()),
    );
    expect(controller.state.banks.any((item) => item.id == bankId), isTrue);
    final exactBankConfirmation = controller.bankDeleteConfirmation(bankId);
    final bankName = controller.state.banks
        .firstWhere((item) => item.id == bankId)
        .name;
    expect(
      exactBankConfirmation,
      contains(bankName),
      reason: '${locale.tag}: localized bank confirmation',
    );
    expect(exactBankConfirmation, isNot(bankName));
    expect(
      exactBankConfirmation,
      MizanI18n.text(
        '"{name}" bankasını ve bu bankaya bağlı tüm ürün, taksit ve ödeme geçmişi kayıtlarını kalıcı olarak silmek için bu metni aynen yaz.',
        args: {'name': bankName},
      ),
    );
    await controller.deleteBank(
      bankId: bankId,
      confirmation: exactBankConfirmation,
    );
    expect(controller.state.banks.any((item) => item.id == bankId), isFalse);
    expect(
      controller.state.debtProducts.any((item) => item.bankId == bankId),
      isFalse,
    );
  });

  test(
    '${locale.tag}: PDF generation uses the active language/report path',
    () async {
      await _loadUnicodePdfTestFont();
      MizanI18n.setProfile(
        languageTag: locale.tag,
        currencyCode: locale.currency,
      );
      final state = _stateFor(locale);
      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: _now),
        now: _now,
      );
      final pdf = await const PdfReportService().buildPdfBytes(
        report,
        requirePremium: false,
      );
      expect(
        pdf.length,
        greaterThan(1500),
        reason: '${locale.tag}: real PDF bytes',
      );
      expect(pdf.take(4).toList(), [0x25, 0x50, 0x44, 0x46]);
    },
  );

  testWidgets(
    '${locale.tag}: phone visits all primary screens without overflow',
    (tester) async {
      final controller = await _pumpApp(
        tester,
        locale,
        const Size(360, 800),
        textScale: 1.15,
      );
      await _visitEveryPrimaryScreen(tester, locale);
      expect(controller.state.appLanguageTag, locale.tag);
      expect(controller.state.defaultCurrencyCode, locale.currency);
    },
  );

  testWidgets(
    '${locale.tag}: tablet visits all primary screens without overflow',
    (tester) async {
      await _pumpApp(tester, locale, const Size(1180, 820), textScale: 1.1);
      await _visitEveryPrimaryScreen(tester, locale);
    },
  );

  testWidgets(
    '${locale.tag}: all record dialogs render localized and overflow-free',
    (tester) async {
      final controller = await _pumpApp(tester, locale, const Size(412, 915));
      final context = tester.element(find.byType(MizanHome));
      final state = controller.state;
      final person = state.people.first;
      final bank = state.banks.first;
      final category = state.expenseCategories.first;
      final bill = state.bills.first;

      await _openAndCloseDialog(
        tester,
        locale,
        () => showPersonDialog(context, controller: controller, person: person),
        const ['Ad soyad', 'Telefon', 'E-posta'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showBankDialog(context, controller: controller, bank: bank),
        const ['Banka adı'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showDebtProductDialog(
          context,
          controller: controller,
          bankId: bank.id,
          bankName: bank.name,
          existing: state.debtProducts.first,
        ),
        const ['Borç türü', 'Toplam borç', 'Aylık tutar', 'Son ödeme tarihi'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showPersonalDebtDialog(
          context,
          controller: controller,
          person: person,
          existing: state.personalDebts.first,
        ),
        const ['Tutar', 'Açıklama', 'Son ödeme tarihi'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showBillDialog(context, controller: controller, bill: bill),
        const ['Tutar', 'Son ödeme tarihi'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showSubscriptionDialog(
          context,
          controller: controller,
          subscription: state.subscriptions.first,
        ),
        const ['Tutar', 'Son ödeme tarihi'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showRentDialog(
          context,
          controller: controller,
          rent: state.rents.first,
        ),
        const ['Tutar', 'Son ödeme tarihi'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showExpenseDialog(
          context,
          controller: controller,
          expense: state.expenses.first,
        ),
        const ['Gider adı', 'Tutar'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showIncomeDialog(
          context,
          controller: controller,
          income: state.incomes.first,
        ),
        const ['Gelir adı', 'Tutar'],
        expectedCurrencyCode: locale.currency,
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showCategoryDialog(
          context,
          controller: controller,
          category: category,
        ),
        const ['Kategori adı'],
      );
    },
  );
}
