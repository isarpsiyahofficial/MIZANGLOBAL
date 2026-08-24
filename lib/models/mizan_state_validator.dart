import 'mizan_models.dart';

const _amountTolerance = 0.001;

void validateMizanState(MizanState state) {
  if (!state.hasCompleteRecordCurrencies) {
    throw StateError(
      'Para taşıyan her kaydın kalıcı ISO para birimi bulunmalıdır.',
    );
  }
  if (state.setupCompleted) {
    if (state.appLanguageTag.trim().isEmpty) {
      throw StateError('Tamamlanmış profilde uygulama dili eksik.');
    }
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(state.debtRegionCountryCode)) {
      throw StateError('Tamamlanmış profilde ülke kodu geçersiz.');
    }
    if (!RegExp(r'^[A-Z]{3}$').hasMatch(state.defaultCurrencyCode)) {
      throw StateError('Tamamlanmış profilde para birimi kodu geçersiz.');
    }
  }

  final ids = <String>{};
  void addId(String id, String type) {
    if (id.trim().isEmpty || !ids.add(id)) {
      throw StateError('$type kayıt kimliği geçersiz veya tekrarlı.');
    }
  }

  void positive(double value, String type) {
    if (!value.isFinite || value <= 0) {
      throw StateError('$type tutarı sıfırdan büyük olmalıdır.');
    }
  }

  void nonNegative(double value, String type) {
    if (!value.isFinite || value < 0) {
      throw StateError('$type tutarı negatif olamaz.');
    }
  }

  void validatePayments(List<PaymentRecord> payments) {
    for (final payment in payments) {
      addId(payment.id, 'Ödeme');
      positive(payment.amount, 'Ödeme');
    }
  }

  void validateNotes(List<RecordNote> notes) {
    for (final note in notes) {
      addId(note.id, 'Not');
    }
  }

  void validateCycleTotals(
    List<PaymentRecord> payments,
    double Function(DateTime dueDate) limitForDueDate,
    String type,
  ) {
    final totals = <DateTime, double>{};
    for (final payment in payments) {
      final appliesTo = payment.appliesToDueDate;
      if (appliesTo == null) continue;
      final due = DateTime(appliesTo.year, appliesTo.month, appliesTo.day);
      totals[due] = (totals[due] ?? 0) + payment.amount;
    }
    for (final entry in totals.entries) {
      if (entry.value > limitForDueDate(entry.key) + _amountTolerance) {
        throw StateError('$type dönem ödemesi dönem tutarını aşıyor.');
      }
    }
  }

  for (final person in state.people) {
    addId(person.id, 'Kişi');
    if (person.name.trim().isEmpty) {
      throw StateError('Kişi adı boş olamaz.');
    }
    for (final bank in person.banks) {
      addId(bank.id, 'Banka');
      if (bank.userWrittenName.trim().isEmpty) {
        throw StateError('Banka adı boş olamaz.');
      }
      for (final debt in bank.products) {
        addId(debt.id, 'Borç');
        positive(debt.totalAmount, 'Borç');
        nonNegative(debt.monthlyAmount, 'Aylık borç');
        validatePayments(debt.payments);
        validateNotes(debt.notes);
        if (debt.paidAmount > debt.totalAmount + _amountTolerance) {
          throw StateError('Bir borç kaydında ödeme toplamı borcu aşıyor.');
        }
      }
    }
    for (final debt in person.personalDebts) {
      addId(debt.id, 'Kişisel/kurumsal borç');
      positive(debt.totalAmount, 'Kişisel borç');
      nonNegative(debt.monthlyAmount, 'Düzenli ödeme');
      for (final scheduleItem in debt.schedule) {
        addId(scheduleItem.id, 'Ödeme planı');
        positive(scheduleItem.amount, 'Ödeme planı');
      }
      validatePayments(debt.payments);
      validateNotes(debt.notes);
      if (debt.paidAmount > debt.totalAmount + _amountTolerance) {
        throw StateError('Bir kişisel borçta ödeme toplamı borcu aşıyor.');
      }
    }
    for (final bill in person.bills) {
      addId(bill.id, 'Fatura');
      positive(bill.amount, 'Fatura');
      if (bill.isMonthly &&
          (bill.paymentDay == null ||
              bill.paymentDay! < 1 ||
              bill.paymentDay! > 31)) {
        throw StateError('Aylık fatura ödeme günü geçersiz.');
      }
      for (final period in bill.periodAmounts) {
        positive(period.amount, 'Dönemsel fatura');
      }
      validatePayments(bill.payments);
      validateNotes(bill.notes);
      if (bill.isMonthly) {
        validateCycleTotals(bill.payments, bill.amountForMonth, 'Fatura');
      } else if (bill.paidAmount > bill.amount + _amountTolerance) {
        throw StateError('Bir fatura kaydında ödeme toplamı tutarı aşıyor.');
      }
    }
    for (final subscription in person.subscriptions) {
      addId(subscription.id, 'Abonelik');
      positive(subscription.amount, 'Abonelik');
      validatePayments(subscription.payments);
      validateNotes(subscription.notes);
      validateCycleTotals(
        subscription.payments,
        (_) => subscription.amount,
        'Abonelik',
      );
    }
    for (final rent in person.rents) {
      addId(rent.id, 'Kira');
      positive(rent.amount, 'Kira');
      if (rent.paymentDay < 1 || rent.paymentDay > 31) {
        throw StateError('Kira ödeme günü geçersiz.');
      }
      validatePayments(rent.payments);
      validateNotes(rent.notes);
      if (rent.isMonthlySchedule &&
          rent.kind != RentEntryKind.productInstallment &&
          rent.installmentCount == null) {
        validateCycleTotals(rent.payments, (_) => rent.amount, 'Kira');
      } else if (rent.paidAmount > rent.amount + _amountTolerance) {
        throw StateError('Bir kira kaydında ödeme toplamı tutarı aşıyor.');
      }
    }
  }

  final categoryIds = <String>{};
  for (final category in state.expenseCategories) {
    addId(category.id, 'Kategori');
    if (category.name.trim().isEmpty) {
      throw StateError('Kategori adı boş olamaz.');
    }
    categoryIds.add(category.id);
  }
  for (final expense in state.expenses) {
    addId(expense.id, 'Gider');
    positive(expense.quantity, 'Gider adedi');
    nonNegative(expense.unitPrice, 'Gider');
    if (!categoryIds.contains(expense.categoryId)) {
      throw StateError('Bir gider kaydı bulunmayan kategoriye bağlı.');
    }
  }
  for (final income in state.incomes) {
    addId(income.id, 'Gelir');
    positive(income.amount, 'Gelir');
    for (final receipt in income.receipts) {
      addId(receipt.id, 'Gelir tahsilatı');
    }
  }
}
