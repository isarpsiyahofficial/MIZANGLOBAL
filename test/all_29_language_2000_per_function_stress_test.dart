import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lefferion_prime_mizan/controllers/mizan_controller.dart';
import 'package:lefferion_prime_mizan/core/mizan_clock.dart';
import 'package:lefferion_prime_mizan/l10n/mizan_i18n.dart';
import 'package:lefferion_prime_mizan/models/mizan_models.dart';

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

const _publicFunctions = <String>[
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
];

const _stressCurrencies = <String>[
  'TRY',
  'USD',
  'EUR',
  'JPY',
  'AED',
  'GBP',
  'CNY',
  'CHF',
];

const _recordTypes = <RecordType>[
  RecordType.debt,
  RecordType.personalDebt,
  RecordType.bill,
  RecordType.subscription,
  RecordType.rent,
];

const _requestedTag = String.fromEnvironment(
  'MIZAN_TEST_LOCALE',
  defaultValue: 'tr',
);

const _runHeavy = bool.fromEnvironment(
  'MIZAN_RUN_2000_FUNCTION_STRESS',
  defaultValue: false,
);

_LocaleCase get _locale => _localeCases.singleWhere(
  (item) => item.tag == _requestedTag,
  orElse: () => throw StateError('Unsupported locale: $_requestedTag'),
);

MizanState _stateFor(
  _LocaleCase locale,
  DateTime reference, {
  required String currencyCode,
  bool setupCompleted = true,
}) => comprehensiveState(reference: reference, currencyCode: currencyCode)
    .copyWith(
      setupCompleted: setupCompleted,
      appLanguageTag: locale.tag,
      debtRegionCountryCode: locale.country,
      defaultCurrencyCode: currencyCode,
      recentCurrencyCodes: <String>[
        currencyCode,
        if (currencyCode != 'USD') 'USD',
        if (currencyCode != 'EUR') 'EUR',
      ],
    );

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

void _require(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

Future<void> _runCall(
  Map<String, int> counts,
  String name,
  Future<void> Function() action,
) async {
  await action();
  counts[name] = counts[name]! + 1;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    MizanClock.resetForTesting();
    MizanI18n.setProfile(languageTag: 'tr', currencyCode: 'TRY');
  });

  test(
    '2000-scenario coverage is locked to every public controller function',
    () {
      final source = File(
        'lib/controllers/mizan_controller.dart',
      ).readAsStringSync();
      final publicMethods =
          RegExp(r'^  Future<void> ([A-Za-z]\w*)\(', multiLine: true)
              .allMatches(source)
              .map((match) => match.group(1)!)
              .where((name) => !name.startsWith('_'))
              .toSet();

      expect(_publicFunctions, hasLength(48));
      expect(publicMethods, _publicFunctions.toSet());
    },
  );

  test(
    '${_locale.tag}: 96000 function scenarios = 48 public functions x 2000',
    () async {
      final locale = _locale;
      final baseDate = DateTime(2026, 1, 1, 9);
      final store = MemoryStore(
        _stateFor(
          locale,
          baseDate,
          currencyCode: locale.currency,
          setupCompleted: false,
        ),
        acceptLegal: false,
      );
      final controller = MizanController(store, scheduler: SpyScheduler());
      final counts = <String, int>{
        for (final name in _publicFunctions) name: 0,
      };

      for (var scenario = 0; scenario < 2000; scenario++) {
        final at = baseDate.add(Duration(days: scenario));
        final currency =
            _stressCurrencies[(scenario + _localeCases.indexOf(locale)) %
                _stressCurrencies.length];
        final token =
            'Q${scenario.toString().padLeft(4, '0')}-${locale.tag}-İb-東京-ع';
        final amount = 1000.0 + scenario + (scenario % 4) * 0.25;
        final archived = scenario.isEven;

        MizanClock.setNowForTesting(at);
        MizanI18n.setProfile(languageTag: locale.tag, currencyCode: currency);
        store.current = _stateFor(
          locale,
          at,
          currencyCode: currency,
          setupCompleted: false,
        );

        await _runCall(counts, 'load', controller.load);
        _require(controller.storageReady, '$token load did not ready storage');
        _require(
          controller.state.defaultCurrencyCode == currency,
          '$token load currency diverged',
        );

        await _runCall(
          counts,
          'completeGlobalSetup',
          () => controller.completeGlobalSetup(
            appLanguageTag: locale.tag,
            debtRegionCountryCode: locale.country,
            defaultCurrencyCode: currency,
          ),
        );
        _require(controller.state.setupCompleted, '$token setup not completed');

        await _runCall(
          counts,
          'updateGlobalPreferences',
          () => controller.updateGlobalPreferences(
            appLanguageTag: locale.tag,
            debtRegionCountryCode: locale.country,
            defaultCurrencyCode: currency,
          ),
        );
        _require(
          controller.state.appLanguageTag == locale.tag &&
              controller.state.defaultCurrencyCode == currency,
          '$token global preferences diverged',
        );

        final personName = '$token-person';
        await _runCall(
          counts,
          'addPerson',
          () => controller.addPerson(personName),
        );
        final addedPerson = controller.state.people.singleWhere(
          (item) => item.name == personName,
        );
        final personName2 = '$token-person-2';
        await _runCall(
          counts,
          'updatePerson',
          () => controller.updatePerson(
            personId: addedPerson.id,
            name: personName2,
          ),
        );
        _require(
          controller.state.people
                  .singleWhere((item) => item.id == addedPerson.id)
                  .name ==
              personName2,
          '$token person update lost user text',
        );
        await _runCall(
          counts,
          'deletePerson',
          () => controller.deletePerson(addedPerson.id),
        );
        _require(
          !controller.state.people.any((item) => item.id == addedPerson.id),
          '$token person delete failed',
        );

        final bankName = '$token-bank';
        await _runCall(
          counts,
          'addBankGroup',
          () => controller.addBankGroup(
            personId: 'person-1',
            userWrittenName: bankName,
          ),
        );
        final bank = _person(
          controller.state,
        ).banks.singleWhere((item) => item.userWrittenName == bankName);
        final bankName2 = '$token-bank-2';
        await _runCall(
          counts,
          'updateBankGroup',
          () => controller.updateBankGroup(
            personId: 'person-1',
            bankId: bank.id,
            userWrittenName: bankName2,
          ),
        );
        _require(
          _person(controller.state).banks
                  .singleWhere((item) => item.id == bank.id)
                  .userWrittenName ==
              bankName2,
          '$token bank update failed',
        );
        await _runCall(
          counts,
          'deleteBankGroup',
          () =>
              controller.deleteBankGroup(personId: 'person-1', bankId: bank.id),
        );
        _require(
          !_person(controller.state).banks.any((item) => item.id == bank.id),
          '$token bank delete failed',
        );

        final debtTitle = '$token-debt';
        await _runCall(
          counts,
          'addDebtProduct',
          () => controller.addDebtProduct(
            personId: 'person-1',
            bankId: 'bank-1',
            kind: DebtKind.loan,
            title: debtTitle,
            totalAmount: amount + 1000,
            monthlyAmount: 100 + (scenario % 300),
            dueDate: at.add(Duration(days: 1 + scenario % 60)),
            currencyCode: currency,
          ),
        );
        final debt = _person(controller.state).banks
            .singleWhere((item) => item.id == 'bank-1')
            .products
            .singleWhere((item) => item.title == debtTitle);

        final personalTitle = '$token-personal';
        await _runCall(
          counts,
          'addPersonalDebt',
          () => controller.addPersonalDebt(
            personId: 'person-1',
            creditorType: CreditorType.person,
            title: personalTitle,
            creditorName: '$token-creditor',
            totalAmount: amount + 900,
            debtDate: at.subtract(Duration(days: scenario % 30)),
            dueDate: at.add(Duration(days: 2 + scenario % 60)),
            frequency: PaymentFrequency.oneTime,
            currencyCode: currency,
          ),
        );
        final personal = _person(
          controller.state,
        ).personalDebts.singleWhere((item) => item.title == personalTitle);

        final billName = '$token-utility';
        await _runCall(
          counts,
          'addBill',
          () => controller.addBill(
            personId: 'person-1',
            kind: BillKind.water,
            institutionName: billName,
            amount: 300 + scenario % 500,
            dueDate: at.add(Duration(days: 3 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        final bill = _person(
          controller.state,
        ).bills.singleWhere((item) => item.institutionName == billName);

        final subscriptionTitle = '$token-sub';
        await _runCall(
          counts,
          'addSubscription',
          () => controller.addSubscription(
            personId: 'person-1',
            kind: SubscriptionKind.membership,
            title: subscriptionTitle,
            providerName: '$token-provider',
            amount: 80 + scenario % 200,
            frequency: PaymentFrequency.monthly,
            nextDueDate: at.add(Duration(days: 4 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        final subscription = _person(
          controller.state,
        ).subscriptions.singleWhere((item) => item.title == subscriptionTitle);

        final rentTitle = '$token-rent';
        await _runCall(
          counts,
          'addRent',
          () => controller.addRent(
            personId: 'person-1',
            kind: RentEntryKind.custom,
            title: rentTitle,
            amount: 500 + scenario % 1000,
            paymentDay: 1 + scenario % 28,
            receiverName: '$token-receiver',
            dueDate: at.add(Duration(days: 5 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        final rent = _person(
          controller.state,
        ).rents.singleWhere((item) => item.title == rentTitle);

        final paymentType = _recordTypes[scenario % _recordTypes.length];
        final paymentSourceId = switch (paymentType) {
          RecordType.debt => debt.id,
          RecordType.personalDebt => personal.id,
          RecordType.bill => bill.id,
          RecordType.subscription => subscription.id,
          RecordType.rent => rent.id,
        };
        final paymentIds = _payments(
          controller.state,
          paymentType,
          paymentSourceId,
        ).map((item) => item.id).toSet();
        await _runCall(
          counts,
          'addPayment',
          () => controller.addPayment(
            personId: 'person-1',
            type: paymentType,
            sourceId: paymentSourceId,
            amount: 1 + scenario % 10,
            paidAt: at,
            entryType: PaymentEntryType.partial,
            note: '$token-payment',
            method: 'QA-${scenario % 17}',
          ),
        );
        final payment = _payments(
          controller.state,
          paymentType,
          paymentSourceId,
        ).singleWhere((item) => !paymentIds.contains(item.id));
        final updatedPaymentAmount = 2.0 + scenario % 10;
        await _runCall(
          counts,
          'updatePayment',
          () => controller.updatePayment(
            personId: 'person-1',
            type: paymentType,
            sourceId: paymentSourceId,
            paymentId: payment.id,
            amount: updatedPaymentAmount,
            paidAt: at.add(const Duration(hours: 1)),
            entryType: PaymentEntryType.partial,
            note: '$token-payment-updated',
            method: 'QA2-${scenario % 19}',
          ),
        );
        _require(
          _payments(
                controller.state,
                paymentType,
                paymentSourceId,
              ).singleWhere((item) => item.id == payment.id).amount ==
              updatedPaymentAmount,
          '$token payment update failed',
        );
        await _runCall(
          counts,
          'deletePayment',
          () => controller.deletePayment(
            personId: 'person-1',
            type: paymentType,
            sourceId: paymentSourceId,
            paymentId: payment.id,
          ),
        );
        _require(
          !_payments(
            controller.state,
            paymentType,
            paymentSourceId,
          ).any((item) => item.id == payment.id),
          '$token payment delete failed',
        );

        final noteIds = _notes(
          controller.state,
          paymentType,
          paymentSourceId,
        ).map((item) => item.id).toSet();
        final noteText = '$token-note-İbrahim-東京-العربية';
        await _runCall(
          counts,
          'addNote',
          () => controller.addNote(
            personId: 'person-1',
            type: paymentType,
            sourceId: paymentSourceId,
            text: noteText,
          ),
        );
        final note = _notes(
          controller.state,
          paymentType,
          paymentSourceId,
        ).singleWhere((item) => !noteIds.contains(item.id));
        _require(note.text == noteText, '$token note changed');
        await _runCall(
          counts,
          'deleteNote',
          () => controller.deleteNote(
            personId: 'person-1',
            type: paymentType,
            sourceId: paymentSourceId,
            noteId: note.id,
          ),
        );
        _require(
          !_notes(
            controller.state,
            paymentType,
            paymentSourceId,
          ).any((item) => item.id == note.id),
          '$token note delete failed',
        );

        final debtTitle2 = '$token-debt-2';
        await _runCall(
          counts,
          'updateDebtProduct',
          () => controller.updateDebtProduct(
            personId: 'person-1',
            bankId: 'bank-1',
            debtId: debt.id,
            kind: DebtKind.loan,
            title: debtTitle2,
            totalAmount: amount + 1200,
            monthlyAmount: 120 + scenario % 300,
            dueDate: at.add(Duration(days: 6 + scenario % 60)),
            currencyCode: currency,
          ),
        );
        _require(
          _debt(controller.state, debt.id).title == debtTitle2,
          '$token debt update failed',
        );
        await _runCall(
          counts,
          'setDebtArchived',
          () => controller.setDebtArchived(
            personId: 'person-1',
            bankId: 'bank-1',
            debtId: debt.id,
            archived: archived,
          ),
        );
        _require(
          _debt(controller.state, debt.id).isArchived == archived,
          '$token debt archive failed',
        );
        await _runCall(
          counts,
          'deleteDebtProduct',
          () => controller.deleteDebtProduct(
            personId: 'person-1',
            bankId: 'bank-1',
            debtId: debt.id,
          ),
        );

        final personalTitle2 = '$token-personal-2';
        await _runCall(
          counts,
          'updatePersonalDebt',
          () => controller.updatePersonalDebt(
            personId: 'person-1',
            debtId: personal.id,
            creditorType: CreditorType.person,
            title: personalTitle2,
            creditorName: '$token-creditor-2',
            totalAmount: amount + 950,
            debtDate: at,
            dueDate: at.add(Duration(days: 7 + scenario % 60)),
            frequency: PaymentFrequency.oneTime,
            currencyCode: currency,
          ),
        );
        _require(
          _personalDebt(controller.state, personal.id).title == personalTitle2,
          '$token personal debt update failed',
        );
        await _runCall(
          counts,
          'setPersonalDebtArchived',
          () => controller.setPersonalDebtArchived(
            personId: 'person-1',
            debtId: personal.id,
            archived: archived,
          ),
        );
        _require(
          _personalDebt(controller.state, personal.id).isArchived == archived,
          '$token personal debt archive failed',
        );
        await _runCall(
          counts,
          'deletePersonalDebt',
          () => controller.deletePersonalDebt(
            personId: 'person-1',
            debtId: personal.id,
          ),
        );

        final billName2 = '$token-utility-2';
        await _runCall(
          counts,
          'updateBill',
          () => controller.updateBill(
            personId: 'person-1',
            billId: bill.id,
            kind: BillKind.water,
            institutionName: billName2,
            amount: 350 + scenario % 500,
            dueDate: at.add(Duration(days: 8 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        _require(
          _bill(controller.state, bill.id).institutionName == billName2,
          '$token bill update failed',
        );
        await _runCall(
          counts,
          'setBillArchived',
          () => controller.setBillArchived(
            personId: 'person-1',
            billId: bill.id,
            archived: archived,
          ),
        );
        _require(
          _bill(controller.state, bill.id).isArchived == archived,
          '$token bill archive failed',
        );
        await _runCall(
          counts,
          'deleteBill',
          () => controller.deleteBill(personId: 'person-1', billId: bill.id),
        );

        final subscriptionTitle2 = '$token-sub-2';
        await _runCall(
          counts,
          'updateSubscription',
          () => controller.updateSubscription(
            personId: 'person-1',
            subscriptionId: subscription.id,
            kind: SubscriptionKind.membership,
            title: subscriptionTitle2,
            providerName: '$token-provider-2',
            amount: 90 + scenario % 200,
            frequency: PaymentFrequency.monthly,
            nextDueDate: at.add(Duration(days: 9 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        _require(
          _subscription(controller.state, subscription.id).title ==
              subscriptionTitle2,
          '$token subscription update failed',
        );
        await _runCall(
          counts,
          'setSubscriptionArchived',
          () => controller.setSubscriptionArchived(
            personId: 'person-1',
            subscriptionId: subscription.id,
            archived: archived,
          ),
        );
        _require(
          _subscription(controller.state, subscription.id).isArchived ==
              archived,
          '$token subscription archive failed',
        );
        await _runCall(
          counts,
          'deleteSubscription',
          () => controller.deleteSubscription(
            personId: 'person-1',
            subscriptionId: subscription.id,
          ),
        );

        final rentTitle2 = '$token-rent-2';
        await _runCall(
          counts,
          'updateRent',
          () => controller.updateRent(
            personId: 'person-1',
            rentId: rent.id,
            kind: RentEntryKind.custom,
            title: rentTitle2,
            amount: 550 + scenario % 1000,
            paymentDay: 1 + (scenario + 1) % 28,
            receiverName: '$token-receiver-2',
            dueDate: at.add(Duration(days: 10 + scenario % 28)),
            currencyCode: currency,
          ),
        );
        _require(
          _rent(controller.state, rent.id).title == rentTitle2,
          '$token rent update failed',
        );
        await _runCall(
          counts,
          'setRentArchived',
          () => controller.setRentArchived(
            personId: 'person-1',
            rentId: rent.id,
            archived: archived,
          ),
        );
        _require(
          _rent(controller.state, rent.id).isArchived == archived,
          '$token rent archive failed',
        );
        await _runCall(
          counts,
          'deleteRent',
          () => controller.deleteRent(personId: 'person-1', rentId: rent.id),
        );

        final categoryName = '$token-category';
        await _runCall(
          counts,
          'addExpenseCategory',
          () => controller.addExpenseCategory(categoryName),
        );
        var category = controller.state.expenseCategories.singleWhere(
          (item) => item.name == categoryName,
        );
        final categoryName2 = '$token-category-2';
        await _runCall(
          counts,
          'renameExpenseCategory',
          () => controller.renameExpenseCategory(
            categoryId: category.id,
            name: categoryName2,
          ),
        );
        category = controller.state.expenseCategories.singleWhere(
          (item) => item.id == category.id,
        );
        _require(
          category.name == categoryName2,
          '$token category rename failed',
        );

        final expenseName = '$token-expense';
        await _runCall(
          counts,
          'addExpense',
          () => controller.addExpense(
            categoryId: category.id,
            name: expenseName,
            quantity: 1 + scenario % 5,
            unitPrice: 10 + (scenario % 100) * 0.5,
            spentAt: at,
            currencyCode: currency,
            note: '$token-expense-note',
          ),
        );
        final expense = controller.state.expenses.singleWhere(
          (item) => item.name == expenseName,
        );
        final expenseName2 = '$token-expense-2';
        await _runCall(
          counts,
          'updateExpense',
          () => controller.updateExpense(
            expenseId: expense.id,
            categoryId: category.id,
            name: expenseName2,
            quantity: 1 + (scenario + 1) % 5,
            unitPrice: 12 + (scenario % 90) * 0.5,
            spentAt: at.add(const Duration(hours: 2)),
            currencyCode: currency,
            note: '$token-expense-note-2',
          ),
        );
        _require(
          controller.state.expenses
                  .singleWhere((item) => item.id == expense.id)
                  .name ==
              expenseName2,
          '$token expense update failed',
        );
        await _runCall(
          counts,
          'deleteExpense',
          () => controller.deleteExpense(expense.id),
        );
        _require(
          !controller.state.expenses.any((item) => item.id == expense.id),
          '$token expense delete failed',
        );
        await _runCall(
          counts,
          'deleteExpenseCategory',
          () => controller.deleteExpenseCategory(
            categoryId: category.id,
            confirmation: MizanI18n.destructiveConfirmation,
          ),
        );
        _require(
          !controller.state.expenseCategories.any(
            (item) => item.id == category.id,
          ),
          '$token category delete failed',
        );

        final incomeTitle = '$token-income';
        await _runCall(
          counts,
          'addIncome',
          () => controller.addIncome(
            title: incomeTitle,
            amount: amount + 5000,
            frequency: IncomeFrequency.monthly,
            startDate: at,
            currencyCode: currency,
            scheduleTrackingEnabled: true,
            scheduledDayOfMonth: 1 + scenario % 28,
          ),
        );
        final income = controller.state.incomes.singleWhere(
          (item) => item.title == incomeTitle,
        );
        final incomeTitle2 = '$token-income-2';
        await _runCall(
          counts,
          'updateIncome',
          () => controller.updateIncome(
            incomeId: income.id,
            title: incomeTitle2,
            amount: amount + 5100,
            frequency: IncomeFrequency.monthly,
            startDate: at,
            currencyCode: currency,
            scheduleTrackingEnabled: true,
            scheduledDayOfMonth: 1 + (scenario + 1) % 28,
          ),
        );
        _require(
          controller.state.incomes
                  .singleWhere((item) => item.id == income.id)
                  .title ==
              incomeTitle2,
          '$token income update failed',
        );
        await _runCall(
          counts,
          'markIncomeReceived',
          () => controller.markIncomeReceived(
            incomeId: income.id,
            receivedAt: at,
            referenceDate: at,
          ),
        );
        _require(
          controller.state.incomes
              .singleWhere((item) => item.id == income.id)
              .receipts
              .isNotEmpty,
          '$token income receipt failed',
        );
        await _runCall(
          counts,
          'undoLatestIncomeReceipt',
          () => controller.undoLatestIncomeReceipt(income.id),
        );
        _require(
          controller.state.incomes
              .singleWhere((item) => item.id == income.id)
              .receipts
              .isEmpty,
          '$token income receipt undo failed',
        );
        await _runCall(
          counts,
          'setIncomeArchived',
          () => controller.setIncomeArchived(income.id, archived),
        );
        _require(
          controller.state.incomes
                  .singleWhere((item) => item.id == income.id)
                  .isArchived ==
              archived,
          '$token income archive failed',
        );
        await _runCall(
          counts,
          'deleteIncome',
          () => controller.deleteIncome(income.id),
        );
        _require(
          !controller.state.incomes.any((item) => item.id == income.id),
          '$token income delete failed',
        );

        final backup = _stateFor(locale, at, currencyCode: currency);
        await _runCall(
          counts,
          'restoreFromBackup',
          () => controller.restoreFromBackup(backup),
        );
        _require(
          controller.state.appLanguageTag == locale.tag &&
              controller.state.defaultCurrencyCode == currency,
          '$token restore changed locale profile',
        );
        await _runCall(
          counts,
          'mergeFromBackup',
          () => controller.mergeFromBackup(
            controller.state,
            addedCount: 1 + scenario % 7,
            mergedCount: scenario % 5,
            duplicateCount: scenario % 3,
          ),
        );
        _require(controller.lastError == null, '$token controller error');

        final roundTrip = MizanState.fromJson(controller.state.toJson());
        _require(
          roundTrip.appLanguageTag == locale.tag &&
              roundTrip.defaultCurrencyCode == currency &&
              roundTrip.people.length == controller.state.people.length,
          '$token state JSON round-trip failed',
        );
      }

      for (final name in _publicFunctions) {
        expect(
          counts[name],
          2000,
          reason: '${locale.tag}/$name did not execute 2000 scenarios',
        );
      }
      expect(counts.values.fold<int>(0, (sum, value) => sum + value), 96000);
    },
    skip: !_runHeavy,
    timeout: const Timeout(Duration(minutes: 35)),
  );
}
