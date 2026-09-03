import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';
import 'package:lefferion_prime_mizan/screens/record_form_dialogs.dart';
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
  orElse: () => throw StateError('Unsupported locale: $_requestedTag'),
);

final _now = DateTime(2026, 8, 18, 12);

MizanState _stateFor(_LocaleCase locale, {bool setupCompleted = true}) =>
    comprehensiveState(reference: _now, currencyCode: locale.currency).copyWith(
      setupCompleted: setupCompleted,
      appLanguageTag: locale.tag,
      debtRegionCountryCode: locale.country,
      defaultCurrencyCode: locale.currency,
      recentCurrencyCodes: [locale.currency, 'USD', 'EUR'],
    );

Future<MizanController> _controller(_LocaleCase locale) async {
  SharedPreferences.setMockInitialValues(const <String, Object>{});
  MizanClock.setNowForTesting(_now);
  MizanI18n.setProfile(languageTag: locale.tag, currencyCode: locale.currency);
  final controller = MizanController(
    MemoryStore(_stateFor(locale)),
    scheduler: SpyScheduler(),
  );
  await controller.load();
  return controller;
}

PersonAccount _person(MizanState state) =>
    state.people.singleWhere((item) => item.id == 'person-1');

DebtProduct _debt(MizanState state, String id) => _person(
  state,
).banks.expand((bank) => bank.products).singleWhere((item) => item.id == id);

PersonalDebtEntry _personalDebt(MizanState state, String id) =>
    _person(state).personalDebts.singleWhere((item) => item.id == id);

BillEntry _bill(MizanState state, String id) =>
    _person(state).bills.singleWhere((item) => item.id == id);

SubscriptionEntry _subscription(MizanState state, String id) =>
    _person(state).subscriptions.singleWhere((item) => item.id == id);

RentEntry _rent(MizanState state, String id) =>
    _person(state).rents.singleWhere((item) => item.id == id);

List<PaymentRecord> _payments(MizanState state, RecordType type, String id) =>
    switch (type) {
      RecordType.debt => _debt(state, id).payments,
      RecordType.personalDebt => _personalDebt(state, id).payments,
      RecordType.bill => _bill(state, id).payments,
      RecordType.subscription => _subscription(state, id).payments,
      RecordType.rent => _rent(state, id).payments,
    };

List<RecordNote> _notes(MizanState state, RecordType type, String id) =>
    switch (type) {
      RecordType.debt => _debt(state, id).notes,
      RecordType.personalDebt => _personalDebt(state, id).notes,
      RecordType.bill => _bill(state, id).notes,
      RecordType.subscription => _subscription(state, id).notes,
      RecordType.rent => _rent(state, id).notes,
    };

Future<void> _exercisePaymentAndNote(
  MizanController controller,
  RecordType type,
  String sourceId,
) async {
  final paymentIds = _payments(
    controller.state,
    type,
    sourceId,
  ).map((item) => item.id).toSet();
  await controller.addPayment(
    personId: 'person-1',
    type: type,
    sourceId: sourceId,
    amount: 10,
    paidAt: _now,
    entryType: PaymentEntryType.partial,
    note: 'QA payment',
    method: 'QA',
  );
  final payment = _payments(
    controller.state,
    type,
    sourceId,
  ).singleWhere((item) => !paymentIds.contains(item.id));
  await controller.updatePayment(
    personId: 'person-1',
    type: type,
    sourceId: sourceId,
    paymentId: payment.id,
    amount: 12,
    paidAt: _now,
    entryType: PaymentEntryType.partial,
    note: 'QA payment updated',
    method: 'QA updated',
  );
  expect(
    _payments(
      controller.state,
      type,
      sourceId,
    ).singleWhere((item) => item.id == payment.id).amount,
    12,
  );
  await controller.deletePayment(
    personId: 'person-1',
    type: type,
    sourceId: sourceId,
    paymentId: payment.id,
  );
  expect(
    _payments(
      controller.state,
      type,
      sourceId,
    ).any((item) => item.id == payment.id),
    isFalse,
  );

  final noteIds = _notes(
    controller.state,
    type,
    sourceId,
  ).map((item) => item.id).toSet();
  await controller.addNote(
    personId: 'person-1',
    type: type,
    sourceId: sourceId,
    text: 'QA note — 東京 — العربية',
  );
  final note = _notes(
    controller.state,
    type,
    sourceId,
  ).singleWhere((item) => !noteIds.contains(item.id));
  expect(note.text, contains('東京'));
  await controller.deleteNote(
    personId: 'person-1',
    type: type,
    sourceId: sourceId,
    noteId: note.id,
  );
  expect(
    _notes(controller.state, type, sourceId).any((item) => item.id == note.id),
    isFalse,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final locale = _localeCase;

  tearDown(() {
    MizanClock.resetForTesting();
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test(
    '${locale.tag}: every public controller feature mutates and persists',
    () async {
      final setupController = MizanController(
        MemoryStore(_stateFor(locale, setupCompleted: false)),
        scheduler: SpyScheduler(),
      );
      await setupController.load();
      await setupController.completeGlobalSetup(
        appLanguageTag: locale.tag,
        debtRegionCountryCode: locale.country,
        defaultCurrencyCode: locale.currency,
      );
      expect(setupController.state.setupCompleted, isTrue);

      final controller = await _controller(locale);
      expect(controller.storageReady, isTrue);
      await controller.updateGlobalPreferences(
        appLanguageTag: locale.tag,
        debtRegionCountryCode: locale.country,
        defaultCurrencyCode: locale.currency,
      );

      await controller.addPerson('QA Person');
      final addedPerson = controller.state.people.singleWhere(
        (item) => item.name == 'QA Person',
      );
      await controller.updatePerson(
        personId: addedPerson.id,
        name: 'QA Person 2',
      );
      expect(
        controller.state.people
            .singleWhere((item) => item.id == addedPerson.id)
            .name,
        'QA Person 2',
      );
      await controller.deletePerson(addedPerson.id);
      expect(
        controller.state.people.any((item) => item.id == addedPerson.id),
        isFalse,
      );

      await controller.addBankGroup(
        personId: 'person-1',
        userWrittenName: 'QA Bank',
      );
      var person = _person(controller.state);
      final bank = person.banks.singleWhere(
        (item) => item.userWrittenName == 'QA Bank',
      );
      await controller.updateBankGroup(
        personId: 'person-1',
        bankId: bank.id,
        userWrittenName: 'QA Bank 2',
      );
      expect(
        _person(
          controller.state,
        ).banks.singleWhere((item) => item.id == bank.id).userWrittenName,
        'QA Bank 2',
      );
      await controller.deleteBankGroup(personId: 'person-1', bankId: bank.id);
      expect(
        _person(controller.state).banks.any((item) => item.id == bank.id),
        isFalse,
      );

      await controller.addDebtProduct(
        personId: 'person-1',
        bankId: 'bank-1',
        kind: DebtKind.loan,
        title: 'QA Debt',
        totalAmount: 1200,
        monthlyAmount: 120,
        dueDate: _now.add(const Duration(days: 20)),
        currencyCode: locale.currency,
      );
      person = _person(controller.state);
      final debt = person.banks
          .singleWhere((item) => item.id == 'bank-1')
          .products
          .singleWhere((item) => item.title == 'QA Debt');
      await _exercisePaymentAndNote(controller, RecordType.debt, debt.id);
      await controller.updateDebtProduct(
        personId: 'person-1',
        bankId: 'bank-1',
        debtId: debt.id,
        kind: DebtKind.loan,
        title: 'QA Debt 2',
        totalAmount: 1300,
        monthlyAmount: 130,
        dueDate: _now.add(const Duration(days: 21)),
        currencyCode: locale.currency,
      );
      await controller.setDebtArchived(
        personId: 'person-1',
        bankId: 'bank-1',
        debtId: debt.id,
        archived: true,
      );
      expect(_debt(controller.state, debt.id).isArchived, isTrue);
      await controller.setDebtArchived(
        personId: 'person-1',
        bankId: 'bank-1',
        debtId: debt.id,
        archived: false,
      );
      await controller.deleteDebtProduct(
        personId: 'person-1',
        bankId: 'bank-1',
        debtId: debt.id,
      );
      expect(
        _person(controller.state).banks
            .expand((item) => item.products)
            .any((item) => item.id == debt.id),
        isFalse,
      );

      await controller.addPersonalDebt(
        personId: 'person-1',
        creditorType: CreditorType.person,
        title: 'QA Personal',
        creditorName: 'QA Creditor',
        totalAmount: 900,
        debtDate: _now,
        dueDate: _now.add(const Duration(days: 22)),
        frequency: PaymentFrequency.oneTime,
        currencyCode: locale.currency,
      );
      final personalDebt = _person(
        controller.state,
      ).personalDebts.singleWhere((item) => item.title == 'QA Personal');
      await _exercisePaymentAndNote(
        controller,
        RecordType.personalDebt,
        personalDebt.id,
      );
      await controller.updatePersonalDebt(
        personId: 'person-1',
        debtId: personalDebt.id,
        creditorType: CreditorType.person,
        title: 'QA Personal 2',
        creditorName: 'QA Creditor 2',
        totalAmount: 950,
        debtDate: _now,
        dueDate: _now.add(const Duration(days: 23)),
        frequency: PaymentFrequency.oneTime,
        currencyCode: locale.currency,
      );
      await controller.setPersonalDebtArchived(
        personId: 'person-1',
        debtId: personalDebt.id,
        archived: true,
      );
      expect(
        _personalDebt(controller.state, personalDebt.id).isArchived,
        isTrue,
      );
      await controller.setPersonalDebtArchived(
        personId: 'person-1',
        debtId: personalDebt.id,
        archived: false,
      );
      await controller.deletePersonalDebt(
        personId: 'person-1',
        debtId: personalDebt.id,
      );
      expect(
        _person(
          controller.state,
        ).personalDebts.any((item) => item.id == personalDebt.id),
        isFalse,
      );

      await controller.addBill(
        personId: 'person-1',
        kind: BillKind.water,
        institutionName: 'QA Utility',
        amount: 300,
        dueDate: _now.add(const Duration(days: 5)),
        currencyCode: locale.currency,
      );
      final bill = _person(
        controller.state,
      ).bills.singleWhere((item) => item.institutionName == 'QA Utility');
      await _exercisePaymentAndNote(controller, RecordType.bill, bill.id);
      await controller.updateBill(
        personId: 'person-1',
        billId: bill.id,
        kind: BillKind.water,
        institutionName: 'QA Utility 2',
        amount: 350,
        dueDate: _now.add(const Duration(days: 6)),
        currencyCode: locale.currency,
      );
      await controller.setBillArchived(
        personId: 'person-1',
        billId: bill.id,
        archived: true,
      );
      expect(_bill(controller.state, bill.id).isArchived, isTrue);
      await controller.setBillArchived(
        personId: 'person-1',
        billId: bill.id,
        archived: false,
      );
      await controller.deleteBill(personId: 'person-1', billId: bill.id);
      expect(
        _person(controller.state).bills.any((item) => item.id == bill.id),
        isFalse,
      );

      await controller.addSubscription(
        personId: 'person-1',
        kind: SubscriptionKind.membership,
        title: 'QA Subscription',
        providerName: 'QA Provider',
        amount: 80,
        frequency: PaymentFrequency.monthly,
        nextDueDate: _now.add(const Duration(days: 7)),
        currencyCode: locale.currency,
      );
      final subscription = _person(
        controller.state,
      ).subscriptions.singleWhere((item) => item.title == 'QA Subscription');
      await _exercisePaymentAndNote(
        controller,
        RecordType.subscription,
        subscription.id,
      );
      await controller.updateSubscription(
        personId: 'person-1',
        subscriptionId: subscription.id,
        kind: SubscriptionKind.membership,
        title: 'QA Subscription 2',
        providerName: 'QA Provider 2',
        amount: 90,
        frequency: PaymentFrequency.monthly,
        nextDueDate: _now.add(const Duration(days: 8)),
        currencyCode: locale.currency,
      );
      await controller.setSubscriptionArchived(
        personId: 'person-1',
        subscriptionId: subscription.id,
        archived: true,
      );
      expect(
        _subscription(controller.state, subscription.id).isArchived,
        isTrue,
      );
      await controller.setSubscriptionArchived(
        personId: 'person-1',
        subscriptionId: subscription.id,
        archived: false,
      );
      await controller.deleteSubscription(
        personId: 'person-1',
        subscriptionId: subscription.id,
      );
      expect(
        _person(
          controller.state,
        ).subscriptions.any((item) => item.id == subscription.id),
        isFalse,
      );

      await controller.addRent(
        personId: 'person-1',
        kind: RentEntryKind.custom,
        title: 'QA Rent',
        amount: 500,
        paymentDay: 10,
        receiverName: 'QA Receiver',
        dueDate: _now.add(const Duration(days: 10)),
        currencyCode: locale.currency,
      );
      final rent = _person(
        controller.state,
      ).rents.singleWhere((item) => item.title == 'QA Rent');
      await _exercisePaymentAndNote(controller, RecordType.rent, rent.id);
      await controller.updateRent(
        personId: 'person-1',
        rentId: rent.id,
        kind: RentEntryKind.custom,
        title: 'QA Rent 2',
        amount: 550,
        paymentDay: 11,
        receiverName: 'QA Receiver 2',
        dueDate: _now.add(const Duration(days: 11)),
        currencyCode: locale.currency,
      );
      await controller.setRentArchived(
        personId: 'person-1',
        rentId: rent.id,
        archived: true,
      );
      expect(_rent(controller.state, rent.id).isArchived, isTrue);
      await controller.setRentArchived(
        personId: 'person-1',
        rentId: rent.id,
        archived: false,
      );
      await controller.deleteRent(personId: 'person-1', rentId: rent.id);
      expect(
        _person(controller.state).rents.any((item) => item.id == rent.id),
        isFalse,
      );

      await controller.addExpenseCategory('QA Category');
      var category = controller.state.expenseCategories.singleWhere(
        (item) => item.name == 'QA Category',
      );
      await controller.renameExpenseCategory(
        categoryId: category.id,
        name: 'QA Category 2',
      );
      category = controller.state.expenseCategories.singleWhere(
        (item) => item.id == category.id,
      );
      expect(category.name, 'QA Category 2');
      await controller.addExpense(
        categoryId: category.id,
        name: 'QA Expense',
        quantity: 2,
        unitPrice: 15,
        spentAt: _now,
        currencyCode: locale.currency,
        note: 'QA expense note',
      );
      final expense = controller.state.expenses.singleWhere(
        (item) => item.name == 'QA Expense',
      );
      await controller.updateExpense(
        expenseId: expense.id,
        categoryId: category.id,
        name: 'QA Expense 2',
        quantity: 3,
        unitPrice: 20,
        spentAt: _now.add(const Duration(days: 1)),
        currencyCode: locale.currency,
        note: 'QA expense updated',
      );
      expect(
        controller.state.expenses
            .singleWhere((item) => item.id == expense.id)
            .totalAmount,
        60,
      );
      await controller.deleteExpense(expense.id);
      await controller.deleteExpenseCategory(
        categoryId: category.id,
        confirmation: MizanI18n.destructiveConfirmation,
      );
      expect(
        controller.state.expenseCategories.any(
          (item) => item.id == category.id,
        ),
        isFalse,
      );

      await controller.addIncome(
        title: 'QA Income',
        amount: 1000,
        frequency: IncomeFrequency.monthly,
        startDate: _now,
        currencyCode: locale.currency,
        scheduleTrackingEnabled: true,
        scheduledDayOfMonth: _now.day,
      );
      final income = controller.state.incomes.singleWhere(
        (item) => item.title == 'QA Income',
      );
      await controller.updateIncome(
        incomeId: income.id,
        title: 'QA Income 2',
        amount: 1100,
        frequency: IncomeFrequency.monthly,
        startDate: _now,
        currencyCode: locale.currency,
        scheduleTrackingEnabled: true,
        scheduledDayOfMonth: _now.day,
      );
      await controller.markIncomeReceived(
        incomeId: income.id,
        receivedAt: _now,
        referenceDate: _now,
      );
      expect(
        controller.state.incomes
            .singleWhere((item) => item.id == income.id)
            .receipts,
        isNotEmpty,
      );
      await controller.undoLatestIncomeReceipt(income.id);
      expect(
        controller.state.incomes
            .singleWhere((item) => item.id == income.id)
            .receipts,
        isEmpty,
      );
      await controller.setIncomeArchived(income.id, true);
      expect(
        controller.state.incomes
            .singleWhere((item) => item.id == income.id)
            .isArchived,
        isTrue,
      );
      await controller.setIncomeArchived(income.id, false);
      await controller.deleteIncome(income.id);
      expect(
        controller.state.incomes.any((item) => item.id == income.id),
        isFalse,
      );

      await controller.restoreFromBackup(_stateFor(locale));
      expect(
        controller.loadMessage,
        MizanI18n.text('CSV yedeği doğrulandı ve geri yüklendi.'),
      );
      await controller.mergeFromBackup(
        controller.state,
        addedCount: 2,
        mergedCount: 1,
        duplicateCount: 1,
      );
      expect(controller.loadMessage, isNotNull);
      if (locale.tag != 'tr') {
        expect(
          controller.loadMessage,
          isNot(contains('CSV yedeği mevcut kayıtlarla birleştirildi')),
        );
        expect(controller.loadMessage, isNot(contains('ilişki güncellendi')));
        expect(
          controller.loadMessage,
          isNot(contains('ortak kullanıcı kaydı')),
        );
      }
      controller.clearMessages();
      expect(controller.lastError, isNull);
      expect(controller.loadMessage, isNull);
    },
  );

  testWidgets(
    '${locale.tag}: generated form validation errors stay localized',
    (tester) async {
      final controller = await _controller(locale);
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox.shrink())),
      );
      final context = tester.element(find.byType(Scaffold));
      final dialog = showPersonForm(context: context, controller: controller);
      await tester.pumpAndSettle();
      await tester.tap(find.text(MizanI18n.text('Kaydet')));
      await tester.pumpAndSettle();
      final expected = MizanI18n.text('Kişi adı boş bırakılamaz.');
      expect(find.text(expected), findsOneWidget, reason: locale.tag);
      if (locale.tag != 'tr') {
        expect(find.text('Kişi adı boş bırakılamaz.'), findsNothing);
      }
      Navigator.of(tester.element(find.byType(AlertDialog))).pop();
      await tester.pumpAndSettle();
      await dialog;
    },
  );

  test('${locale.tag}: every validator error path is explicitly localized', () {
    const paths = <String>[
      'lib/screens/record_form_dialogs.dart',
      'lib/screens/dashboard_screen.dart',
      'lib/screens/expenses_screen.dart',
      'lib/widgets/record_notes_panel.dart',
    ];
    final combined = paths
        .map((path) => File(path).readAsStringSync())
        .join('\n');
    for (final forbidden in const <String>[
      r"? '$label boş bırakılamaz.'",
      r"return '$label geçersiz.';",
      'return error.message;',
      "? 'Gelir türü boş bırakılamaz.'",
      "return 'Gelir tutarı sıfırdan büyük olmalıdır.';",
      "? 'Kategori adı boş bırakılamaz.'",
      "? 'Gider adı boş bırakılamaz.'",
      "return 'Birim fiyat negatif olamaz.';",
      "? 'Not boş bırakılamaz.'",
      "return 'Ödeme tutarı kalan borçtan büyük olamaz.';",
    ]) {
      expect(combined, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('public controller API is locked to this functional coverage', () {
    final source = File(
      'lib/controllers/mizan_controller.dart',
    ).readAsStringSync();
    final publicMethods =
        RegExp(r'^  Future<void> ([A-Za-z]\w*)\(', multiLine: true)
            .allMatches(source)
            .map((match) => match.group(1)!)
            .where((name) => !name.startsWith('_'))
            .toSet();
    const covered = <String>{
      'load',
      'completeGlobalSetup',
      'updateGlobalPreferences',
      'addPerson',
      'updatePerson',
      'deletePerson',
      'addBankGroup',
      'updateBankGroup',
      'deleteBankGroup',
      'addDebtProduct',
      'updateDebtProduct',
      'deleteDebtProduct',
      'setDebtArchived',
      'addPersonalDebt',
      'updatePersonalDebt',
      'deletePersonalDebt',
      'setPersonalDebtArchived',
      'addBill',
      'updateBill',
      'deleteBill',
      'setBillArchived',
      'addSubscription',
      'updateSubscription',
      'deleteSubscription',
      'setSubscriptionArchived',
      'addRent',
      'updateRent',
      'deleteRent',
      'setRentArchived',
      'addPayment',
      'updatePayment',
      'deletePayment',
      'addNote',
      'deleteNote',
      'addExpenseCategory',
      'renameExpenseCategory',
      'deleteExpenseCategory',
      'addExpense',
      'updateExpense',
      'deleteExpense',
      'restoreFromBackup',
      'mergeFromBackup',
      'addIncome',
      'updateIncome',
      'markIncomeReceived',
      'undoLatestIncomeReceipt',
      'setIncomeArchived',
      'deleteIncome',
    };
    expect(publicMethods, covered);
  });
}
