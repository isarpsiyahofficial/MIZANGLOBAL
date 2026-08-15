import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/formatters.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/main.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/record_form_dialogs.dart';
import 'package:lefferion_prime_mizan/services/csv_backup_service.dart';
import 'package:lefferion_prime_mizan/services/pdf_report_service.dart';
import 'package:lefferion_prime_mizan/services/reminder_engine.dart';
import 'package:lefferion_prime_mizan/services/report_service.dart';

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
    notificationSlots: const [],
    paymentReminderFrequency: PaymentReminderFrequency.onceDaily,
    paymentNotificationSlots: const [
      NotificationSlot(
        id: 'deep-surface-payment-slot',
        label: 'User Slot 24',
        hour: 11,
        minute: 0,
        message: 'User message Bank 24 — 東京 — Việt Nam',
      ),
    ],
  );
}

Future<MizanController> _pumpApp(
  WidgetTester tester,
  _LocaleCase locale,
  Size size, {
  double textScale = 1,
}) async {
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
  }
}

Future<void> _openAndCloseDialog(
  WidgetTester tester,
  _LocaleCase locale,
  Future<void> Function() open,
  List<String> requiredSourceCopy,
) async {
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

  test(
    '${locale.tag}: runtime, report, reminder, backup and destructive flows',
    () async {
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
        'Bildirim sistemi',
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
        report.remainingDetails.any(
          (item) => item.title.contains('Kart borcu'),
        ),
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

      final reminders = const ReminderPlanBuilder().build(
        state: sourceState,
        now: _now,
      );
      final reminder = reminders.firstWhere(
        (item) => item.sourceId == 'bank-debt-1',
      );
      expect(reminder.title, contains('Kart borcu'));
      expect(reminder.message, contains('User message Bank 24'));
      expect(reminder.title, isNot(contains('\u{E000}')));
      expect(reminder.message, isNot(contains('\u{E000}')));
      if (locale.tag != 'tr') {
        expect(
          reminder.title,
          isNot(startsWith('Banka borcu:')),
          reason: '${locale.tag}: Turkish reminder prefix leaked',
        );
      }

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
        throwsA(isA<ArgumentError>()),
      );
      await controller.deleteExpenseCategory(
        categoryId: categoryId,
        confirmation: MizanI18n.destructiveConfirmation,
      );
      expect(
        controller.state.expenseCategories.any((item) => item.id == categoryId),
        isFalse,
        reason: '${locale.tag}: localized destructive confirmation',
      );
    },
  );

  test(
    '${locale.tag}: PDF generation uses the active language/report path',
    () async {
      MizanClock.setNowForTesting(_now);
      await _loadUnicodePdfTestFont();
      final state = _stateFor(locale);
      MizanI18n.setProfile(
        languageTag: locale.tag,
        currencyCode: locale.currency,
      );
      final report = const MizanReportService().build(
        state: state,
        filter: ReportFilter(period: ReportPeriod.monthly, anchorDate: _now),
        now: _now,
      );
      final bytes = await const PdfReportService().build(report);
      expect(
        bytes.length,
        greaterThan(1000),
        reason: '${locale.tag}: PDF size',
      );
      expect(String.fromCharCodes(bytes.take(4)), '%PDF', reason: locale.tag);
    },
  );

  testWidgets(
    '${locale.tag}: phone visits all primary screens without overflow',
    (tester) async {
      await _pumpApp(tester, locale, const Size(320, 568), textScale: 1.4);
      for (final source in const [
        'Ana sayfa',
        'Kayıtlar',
        'Giderler',
        'Raporlar',
        'Ayarlar',
      ]) {
        expect(
          find.text(MizanI18n.text(source)),
          findsWidgets,
          reason: '${locale.tag}: navigation label $source',
        );
      }
      if (locale.tag != 'tr') {
        expect(find.text('Ana sayfa'), findsNothing, reason: locale.tag);
      }
      final expectedDirection =
          const {'ar', 'fa', 'he', 'ur'}.contains(locale.tag)
          ? TextDirection.rtl
          : TextDirection.ltr;
      expect(
        Directionality.of(
          tester.element(find.text(MizanI18n.text('Ana sayfa')).first),
        ),
        expectedDirection,
        reason: '${locale.tag}: directionality',
      );
      await _visitEveryPrimaryScreen(tester, locale);
    },
  );

  testWidgets(
    '${locale.tag}: tablet visits all primary screens without overflow',
    (tester) async {
      await _pumpApp(tester, locale, const Size(1180, 820));
      await _visitEveryPrimaryScreen(tester, locale);
    },
  );

  testWidgets(
    '${locale.tag}: all record dialogs render localized and overflow-free',
    (tester) async {
      final controller = await _pumpApp(
        tester,
        locale,
        const Size(320, 568),
        textScale: 1.4,
      );
      final scaffoldContext = tester.element(find.byType(Scaffold).first);
      final person = controller.state.people.first;
      final bank = person.banks.first;
      final debt = bank.products.first;

      await _openAndCloseDialog(
        tester,
        locale,
        () => showPersonForm(context: scaffoldContext, controller: controller),
        const ['Kişi ekle', 'Kişi adı'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showBankForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
        ),
        const ['Banka grubu ekle', 'Banka adı'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showDebtForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
          bank: bank,
        ),
        const ['Borç ürünü ekle', 'Borç türü'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showPersonalDebtForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
        ),
        const ['Kişisel / kurumsal borç ekle'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showBillForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
        ),
        const ['Fatura ekle'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showSubscriptionForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
        ),
        const ['Abonelik ekle'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showRentForm(
          context: scaffoldContext,
          controller: controller,
          person: person,
        ),
        const ['Kira / taksit ekle'],
      );
      await _openAndCloseDialog(
        tester,
        locale,
        () => showPaymentForm(
          context: scaffoldContext,
          controller: controller,
          personId: person.id,
          type: RecordType.debt,
          sourceId: debt.id,
          remainingAmount: debt.remainingAmount,
          suggestedInstallmentAmount: debt.monthlyAmount,
          allowInstallmentPayment: true,
        ),
        const ['Ödeme ekle'],
      );
    },
  );
}
