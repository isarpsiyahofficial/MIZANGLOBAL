import '../core/formatters.dart';
import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';

enum ReportPeriod {
  daily('Günlük'),
  weekly('Haftalık'),
  monthly('Aylık'),
  yearly('Yıllık'),
  allTime('Tüm zamanlar');

  const ReportPeriod(this._label);
  final String _label;
  String get label => MizanI18n.text(_label);
}

class ReportDateRange {
  const ReportDateRange({this.start, this.endInclusive, required this.label});

  final DateTime? start;
  final DateTime? endInclusive;
  final String label;

  bool contains(DateTime value) {
    final day = dateOnly(value);
    if (start != null && day.isBefore(dateOnly(start!))) return false;
    if (endInclusive != null && day.isAfter(dateOnly(endInclusive!))) {
      return false;
    }
    return true;
  }
}

class ReportFilter {
  const ReportFilter({
    required this.period,
    required this.anchorDate,
    this.selectedPersonIds = const {},
    this.status,
  });

  final ReportPeriod period;
  final DateTime anchorDate;
  final Set<String> selectedPersonIds;
  final PaymentStatus? status;

  bool includesPerson(String personId) =>
      selectedPersonIds.isEmpty || selectedPersonIds.contains(personId);

  ReportDateRange range(DateTime now) {
    final anchor = dateOnly(anchorDate);
    switch (period) {
      case ReportPeriod.daily:
        return ReportDateRange(
          start: anchor,
          endInclusive: anchor,
          label: shortDate(anchor),
        );
      case ReportPeriod.weekly:
        final start = anchor.subtract(Duration(days: anchor.weekday - 1));
        final end = start.add(const Duration(days: 6));
        return ReportDateRange(
          start: start,
          endInclusive: end,
          label: '${shortDate(start)} - ${shortDate(end)}',
        );
      case ReportPeriod.monthly:
        final start = DateTime(anchor.year, anchor.month);
        final end = DateTime(anchor.year, anchor.month + 1, 0);
        return ReportDateRange(
          start: start,
          endInclusive: end,
          label: monthLabel(anchor),
        );
      case ReportPeriod.yearly:
        final start = DateTime(anchor.year);
        final end = anchor.year == now.year
            ? dateOnly(now)
            : DateTime(anchor.year, 12, 31);
        return ReportDateRange(
          start: start,
          endInclusive: end,
          label: anchor.year == now.year
              ? MizanI18n.isEnglish
                    ? '${anchor.year} · January 1 - ${shortDate(end)}'
                    : '${anchor.year} · 1 Ocak - ${shortDate(end)}'
              : anchor.year.toString(),
        );
      case ReportPeriod.allTime:
        return ReportDateRange(label: MizanI18n.text('Tüm zamanlar'));
    }
  }
}

class ReportPaymentDetail {
  const ReportPaymentDetail({
    required this.personId,
    required this.personName,
    required this.type,
    required this.recordId,
    this.bankId,
    required this.recordTitle,
    required this.recordSubtitle,
    required this.payment,
  });

  final String personId;
  final String personName;
  final RecordType type;
  final String recordId;
  final String? bankId;
  final String recordTitle;
  final String recordSubtitle;
  final PaymentRecord payment;
}

class ReportExpenseDetail {
  const ReportExpenseDetail({
    required this.categoryName,
    required this.expense,
  });

  final String categoryName;
  final ExpenseItem expense;
}

class ReportIncomeDetail {
  const ReportIncomeDetail({required this.income, required this.amount});

  final IncomeEntry income;
  final double amount;
}

class ReportDistributionEntry {
  const ReportDistributionEntry({
    required this.label,
    required this.amount,
    this.type,
    this.expenseCategory,
  });

  final String label;
  final double amount;
  final RecordType? type;
  final String? expenseCategory;

  bool get isNormalExpense => type == null;
}

class ReportInstallmentDetail {
  const ReportInstallmentDetail({
    required this.personName,
    required this.type,
    required this.title,
    required this.remainingCount,
  });

  final String personName;
  final RecordType type;
  final String title;
  final int remainingCount;
}

class ReportPersonDebtDetail {
  const ReportPersonDebtDetail({
    required this.personId,
    required this.personName,
    required this.totalRemaining,
    required this.byType,
    required this.records,
  });

  final String personId;
  final String personName;
  final double totalRemaining;
  final Map<RecordType, double> byType;
  final List<RecordReference> records;
}

class MizanReport {
  const MizanReport({
    required this.filter,
    required this.range,
    required this.languageTag,
    required this.currencyCode,
    required this.generatedAt,
    required this.selectedPersonNames,
    required this.incomeSpecified,
    required this.incomeDetails,
    required this.paymentTotalsByType,
    required this.paymentDetails,
    required this.expenseTotalsByCategory,
    required this.expenseDetails,
    required this.remainingTotalsByType,
    required this.remainingDetails,
    required this.upcomingDetails,
    required this.personDebtDetails,
    required this.installmentDetails,
  });

  final ReportFilter filter;
  final ReportDateRange range;
  final String languageTag;
  final String currencyCode;
  final DateTime generatedAt;
  final List<String> selectedPersonNames;
  final bool incomeSpecified;
  final List<ReportIncomeDetail> incomeDetails;
  final Map<RecordType, double> paymentTotalsByType;
  final List<ReportPaymentDetail> paymentDetails;
  final Map<String, double> expenseTotalsByCategory;
  final List<ReportExpenseDetail> expenseDetails;
  final Map<RecordType, double> remainingTotalsByType;
  final List<RecordReference> remainingDetails;
  final List<RecordReference> upcomingDetails;
  final List<ReportPersonDebtDetail> personDebtDetails;
  final List<ReportInstallmentDetail> installmentDetails;

  DateTime get balanceReference {
    final end = range.endInclusive;
    if (end == null || end.isAfter(generatedAt)) return generatedAt;
    return end;
  }

  double get totalIncome =>
      incomeDetails.fold<double>(0, (sum, item) => sum + item.amount);

  double get totalPayments =>
      paymentTotalsByType.values.fold<double>(0, (sum, amount) => sum + amount);

  double get totalExpenses => expenseDetails.fold<double>(
    0,
    (sum, item) => sum + item.expense.totalAmount,
  );

  double get paymentExpenseTotal => totalPayments;

  double get normalExpenseTotal => totalExpenses;

  double get realizedGrandTotal => totalPayments + totalExpenses;

  double get combinedExpenseTotal => realizedGrandTotal;

  List<ReportDistributionEntry> get realizedDistribution {
    final result = <ReportDistributionEntry>[
      ReportDistributionEntry(label: MizanI18n.text('Giderler'), amount: totalExpenses),
      for (final type in RecordType.values)
        ReportDistributionEntry(
          label: type.label,
          amount: paymentTotalsByType[type] ?? 0,
          type: type,
        ),
    ];
    result.sort((a, b) {
      final amountOrder = b.amount.compareTo(a.amount);
      return amountOrder != 0 ? amountOrder : a.label.compareTo(b.label);
    });
    return result;
  }

  List<ReportDistributionEntry> get combinedOutflowDistribution {
    final result = <ReportDistributionEntry>[
      for (final entry in expenseTotalsByCategory.entries)
        ReportDistributionEntry(
          label: '${MizanI18n.text('Günlük harcama')} · ${entry.key}',
          amount: entry.value,
          expenseCategory: entry.key,
        ),
      for (final type in RecordType.values)
        ReportDistributionEntry(
          label: '${MizanI18n.text('Ödeme')} · ${type.label}',
          amount: paymentTotalsByType[type] ?? 0,
          type: type,
        ),
    ]..removeWhere((entry) => entry.amount <= 0);
    result.sort((a, b) {
      final amountOrder = b.amount.compareTo(a.amount);
      return amountOrder != 0 ? amountOrder : a.label.compareTo(b.label);
    });
    return result;
  }

  double get afterPayments => totalIncome - totalPayments;

  double get finalNet => totalIncome - totalPayments - totalExpenses;

  double get remainingLoad => remainingTotalsByType.values.fold<double>(
    0,
    (sum, amount) => sum + amount,
  );

  double get overdueLoad => remainingDetails
      .where((item) => item.status == PaymentStatus.overdue)
      .fold<double>(0, (sum, item) => sum + item.amount);

  DateTime get upcomingReference => range.contains(generatedAt)
      ? dateOnly(generatedAt)
      : dateOnly(balanceReference);

  double get upcomingLoad =>
      upcomingDetails.fold<double>(0, (sum, item) => sum + item.amount);
}

class MizanReportService {
  const MizanReportService();

  List<ReportPaymentDetail> paymentDetailsForRange({
    required MizanState state,
    DateTime? start,
    DateTime? endInclusive,
    Set<String> selectedPersonIds = const {},
  }) {
    bool includesDay(DateTime value) {
      final day = dateOnly(value);
      if (start != null && day.isBefore(dateOnly(start))) return false;
      if (endInclusive != null && day.isAfter(dateOnly(endInclusive))) {
        return false;
      }
      return true;
    }

    bool includesPerson(String personId) =>
        selectedPersonIds.isEmpty || selectedPersonIds.contains(personId);

    final details = <ReportPaymentDetail>[];
    void addPayments({
      required PersonAccount person,
      required RecordType type,
      required String recordId,
      String? bankId,
      required String title,
      required String subtitle,
      required Iterable<PaymentRecord> payments,
    }) {
      if (!includesPerson(person.id)) return;
      for (final payment in payments) {
        if (!includesDay(payment.paidAt)) continue;
        details.add(
          ReportPaymentDetail(
            personId: person.id,
            personName: MizanI18n.user(person.name),
            type: type,
            recordId: recordId,
            bankId: bankId,
            recordTitle: MizanI18n.user(title),
            recordSubtitle: MizanI18n.user(subtitle),
            payment: payment,
          ),
        );
      }
    }

    for (final person in state.people) {
      for (final bank in person.banks) {
        for (final debt in bank.products) {
          addPayments(
            person: person,
            type: RecordType.debt,
            recordId: debt.id,
            bankId: bank.id,
            title: MizanI18n.user(debt.title),
            subtitle: '${bank.userWrittenName} · ${debt.displayKind}',
            payments: debt.payments,
          );
        }
      }
      for (final debt in person.personalDebts) {
        addPayments(
          person: person,
          type: RecordType.personalDebt,
          recordId: debt.id,
          title: MizanI18n.user(debt.title),
          subtitle: '${debt.creditorType.label} · ${debt.displayCreditor}',
          payments: debt.payments,
        );
      }
      for (final bill in person.bills) {
        addPayments(
          person: person,
          type: RecordType.bill,
          recordId: bill.id,
          title: bill.kind.label,
          subtitle: bill.institutionName,
          payments: bill.payments,
        );
      }
      for (final subscription in person.subscriptions) {
        addPayments(
          person: person,
          type: RecordType.subscription,
          recordId: subscription.id,
          title: MizanI18n.user(subscription.title),
          subtitle: subscription.providerName,
          payments: subscription.payments,
        );
      }
      for (final rent in person.rents) {
        addPayments(
          person: person,
          type: RecordType.rent,
          recordId: rent.id,
          title: MizanI18n.user(rent.title),
          subtitle: rent.receiverName,
          payments: rent.payments,
        );
      }
    }
    details.sort((a, b) => b.payment.paidAt.compareTo(a.payment.paidAt));
    return details;
  }

  MizanReport build({
    required MizanState state,
    required ReportFilter filter,
    DateTime? now,
  }) {
    final generatedAt = now ?? DateTime.now();
    final range = filter.range(generatedAt);
    final includedPeople = state.people
        .where((person) => filter.includesPerson(person.id))
        .toList(growable: false);

    final incomeSpecified = state.hasIncomeInformation;
    final incomeStart =
        range.start ??
        (state.incomes.isEmpty
            ? generatedAt
            : state.incomes
                  .map((item) => item.startDate)
                  .reduce((a, b) => a.isBefore(b) ? a : b));
    final incomeEnd = range.endInclusive ?? generatedAt;
    final incomeDetails = state.incomes
        .where((item) => !item.isArchived)
        .map(
          (item) => ReportIncomeDetail(
            income: item,
            amount: item.totalForRange(incomeStart, incomeEnd),
          ),
        )
        .where((item) => item.amount > 0)
        .toList(growable: false);

    final paymentTotals = <RecordType, double>{
      for (final type in RecordType.values) type: 0,
    };
    final paymentDetails = <ReportPaymentDetail>[];

    void addPayments({
      required PersonAccount person,
      required RecordType type,
      required String recordId,
      String? bankId,
      required String title,
      required String subtitle,
      required Iterable<PaymentRecord> payments,
    }) {
      for (final payment in payments) {
        if (!range.contains(payment.paidAt)) continue;
        paymentTotals[type] = (paymentTotals[type] ?? 0) + payment.amount;
        paymentDetails.add(
          ReportPaymentDetail(
            personId: person.id,
            personName: MizanI18n.user(person.name),
            type: type,
            recordId: recordId,
            bankId: bankId,
            recordTitle: MizanI18n.user(title),
            recordSubtitle: MizanI18n.user(subtitle),
            payment: payment,
          ),
        );
      }
    }

    for (final person in includedPeople) {
      for (final bank in person.banks) {
        for (final debt in bank.products) {
          addPayments(
            person: person,
            type: RecordType.debt,
            recordId: debt.id,
            bankId: bank.id,
            title: MizanI18n.user(debt.title),
            subtitle: '${bank.userWrittenName} · ${debt.displayKind}',
            payments: debt.payments,
          );
        }
      }
      for (final debt in person.personalDebts) {
        addPayments(
          person: person,
          type: RecordType.personalDebt,
          recordId: debt.id,
          title: MizanI18n.user(debt.title),
          subtitle: '${debt.creditorType.label} · ${debt.displayCreditor}',
          payments: debt.payments,
        );
      }
      for (final bill in person.bills) {
        addPayments(
          person: person,
          type: RecordType.bill,
          recordId: bill.id,
          title: bill.kind.label,
          subtitle: bill.institutionName,
          payments: bill.payments,
        );
      }
      for (final subscription in person.subscriptions) {
        addPayments(
          person: person,
          type: RecordType.subscription,
          recordId: subscription.id,
          title: MizanI18n.user(subscription.title),
          subtitle: subscription.providerName,
          payments: subscription.payments,
        );
      }
      for (final rent in person.rents) {
        addPayments(
          person: person,
          type: RecordType.rent,
          recordId: rent.id,
          title: MizanI18n.user(rent.title),
          subtitle: rent.receiverName,
          payments: rent.payments,
        );
      }
    }
    paymentDetails.sort((a, b) => b.payment.paidAt.compareTo(a.payment.paidAt));

    final categoryNames = {
      for (final category in state.expenseCategories)
        category.id: category.name,
    };
    final expenseDetails =
        state.expenses
            .where((expense) => range.contains(expense.spentAt))
            .map(
              (expense) => ReportExpenseDetail(
                categoryName:
                    categoryNames[expense.categoryId] ?? 'Kategorisiz',
                expense: expense,
              ),
            )
            .toList(growable: false)
          ..sort((a, b) => b.expense.spentAt.compareTo(a.expense.spentAt));
    final expenseTotals = <String, double>{};
    for (final item in expenseDetails) {
      expenseTotals[item.categoryName] =
          (expenseTotals[item.categoryName] ?? 0) + item.expense.totalAmount;
    }

    final periodEnd = range.endInclusive;
    final balanceReference = periodEnd == null || periodEnd.isAfter(generatedAt)
        ? generatedAt
        : periodEnd;
    final remaining =
        state
            .recordReferencesAt(balanceReference)
            .where((record) {
              if (!filter.includesPerson(record.personId)) return false;
              if (record.status == PaymentStatus.completed ||
                  record.status == PaymentStatus.passive ||
                  record.amount <= 0) {
                return false;
              }
              final inScope = range.start == null || range.endInclusive == null
                  ? true
                  : record.status == PaymentStatus.overdue
                  ? !record.dueDate.isAfter(range.endInclusive!)
                  : range.contains(record.dueDate);
              if (!inScope) return false;
              if (filter.status != null && record.status != filter.status) {
                return false;
              }
              return true;
            })
            .toList(growable: false)
          ..sort((a, b) {
            final statusOrder = a.status == PaymentStatus.overdue
                ? 0
                : b.status == PaymentStatus.overdue
                ? 1
                : 0;
            if (statusOrder != 0) return statusOrder;
            return a.dueDate.compareTo(b.dueDate);
          });
    final remainingTotals = <RecordType, double>{
      for (final type in RecordType.values) type: 0,
    };
    for (final record in remaining) {
      remainingTotals[record.type] =
          (remainingTotals[record.type] ?? 0) + record.amount;
    }

    final upcomingReference = range.contains(generatedAt)
        ? dateOnly(generatedAt)
        : dateOnly(balanceReference);
    final upcomingEnd = upcomingReference.add(const Duration(days: 7));
    final upcomingDetails =
        state
            .recordReferencesAt(upcomingReference)
            .where((record) {
              if (!filter.includesPerson(record.personId) ||
                  record.amount <= 0) {
                return false;
              }
              if (record.status == PaymentStatus.completed ||
                  record.status == PaymentStatus.passive) {
                return false;
              }
              if (filter.status != null && record.status != filter.status) {
                return false;
              }
              final due = dateOnly(record.dueDate);
              return !due.isBefore(upcomingReference) &&
                  !due.isAfter(upcomingEnd);
            })
            .toList(growable: false)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final personDebtDetails = <ReportPersonDebtDetail>[];
    for (final person in includedPeople) {
      final records = _fullRemainingReferences(person, generatedAt)
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      final byType = <RecordType, double>{
        for (final type in RecordType.values) type: 0,
      };
      for (final record in records) {
        byType[record.type] = (byType[record.type] ?? 0) + record.amount;
      }
      personDebtDetails.add(
        ReportPersonDebtDetail(
          personId: person.id,
          personName: MizanI18n.user(person.name),
          totalRemaining: records.fold<double>(
            0,
            (sum, record) => sum + record.amount,
          ),
          byType: byType,
          records: records,
        ),
      );
    }
    personDebtDetails.sort(
      (a, b) => b.totalRemaining.compareTo(a.totalRemaining),
    );

    // Bu bilgi rapor arayüzünden kaldırıldı. Değişken taksit yapılarında
    // yanıltıcı olabildiği için pahalı taksit taraması da yapılmaz.
    const installmentDetails = <ReportInstallmentDetail>[];

    return MizanReport(
      filter: filter,
      range: range,
      languageTag: MizanI18n.normalizeLanguageTag(state.appLanguageTag),
      currencyCode: state.defaultCurrencyCode,
      generatedAt: generatedAt,
      selectedPersonNames: includedPeople
          .map((item) => MizanI18n.user(item.name))
          .toList(),
      incomeSpecified: incomeSpecified,
      incomeDetails: incomeDetails,
      paymentTotalsByType: paymentTotals,
      paymentDetails: paymentDetails,
      expenseTotalsByCategory: expenseTotals,
      expenseDetails: expenseDetails,
      remainingTotalsByType: remainingTotals,
      remainingDetails: remaining,
      upcomingDetails: upcomingDetails,
      personDebtDetails: personDebtDetails,
      installmentDetails: installmentDetails,
    );
  }

  List<RecordReference> _fullRemainingReferences(
    PersonAccount person,
    DateTime reference,
  ) {
    final records = <RecordReference>[];
    for (final bank in person.banks) {
      for (final debt in bank.products) {
        final status = debt.statusAt(reference);
        if (debt.remainingAmount <= 0 ||
            status == PaymentStatus.completed ||
            status == PaymentStatus.passive) {
          continue;
        }
        records.add(
          RecordReference(
            type: RecordType.debt,
            personId: person.id,
            sourceId: debt.id,
            bankId: bank.id,
            title: MizanI18n.user(debt.title),
            subtitle:
                MizanI18n.user('${person.name} · ${bank.userWrittenName} · ${debt.displayKind}'),
            amount: debt.remainingAmount,
            dueDate: debt.effectiveDueDateAt(reference),
            status: status,
          ),
        );
      }
    }
    for (final debt in person.personalDebts) {
      final status = debt.statusAt(reference);
      if (debt.remainingAmount <= 0 ||
          status == PaymentStatus.completed ||
          status == PaymentStatus.passive) {
        continue;
      }
      records.add(
        RecordReference(
          type: RecordType.personalDebt,
          personId: person.id,
          sourceId: debt.id,
          title: MizanI18n.user(debt.title),
          subtitle:
              MizanI18n.user('${person.name} · ${debt.creditorType.label} · ${debt.displayCreditor}'),
          amount: debt.remainingAmount,
          dueDate: debt.effectiveDueDate,
          status: status,
        ),
      );
    }
    for (final bill in person.bills) {
      final status = bill.statusAt(reference);
      if (bill.outstandingAmountAt(reference) <= 0 ||
          status == PaymentStatus.completed ||
          status == PaymentStatus.passive) {
        continue;
      }
      records.add(
        RecordReference(
          type: RecordType.bill,
          personId: person.id,
          sourceId: bill.id,
          title: bill.kind.label,
          subtitle: MizanI18n.user('${person.name} · ${bill.institutionName}'),
          amount: bill.outstandingAmountAt(reference),
          dueDate: bill.effectiveDueDateAt(reference),
          status: status,
          overdueDays: bill.overdueDaysAt(reference),
        ),
      );
    }
    for (final subscription in person.subscriptions) {
      final status = subscription.statusAt(reference);
      if (subscription.remainingAmount <= 0 ||
          status == PaymentStatus.completed ||
          status == PaymentStatus.passive) {
        continue;
      }
      records.add(
        RecordReference(
          type: RecordType.subscription,
          personId: person.id,
          sourceId: subscription.id,
          title: MizanI18n.user(subscription.title),
          subtitle: MizanI18n.user('${person.name} · ${subscription.providerName}'),
          amount: subscription.remainingAmount,
          dueDate: subscription.nextDueDate,
          status: status,
        ),
      );
    }
    for (final rent in person.rents) {
      final status = rent.statusAt(reference);
      if (rent.outstandingAmountAt(reference) <= 0 ||
          status == PaymentStatus.completed ||
          status == PaymentStatus.passive) {
        continue;
      }
      records.add(
        RecordReference(
          type: RecordType.rent,
          personId: person.id,
          sourceId: rent.id,
          title: MizanI18n.user(rent.title),
          subtitle: MizanI18n.user('${person.name} · ${rent.receiverName}'),
          amount: rent.outstandingAmountAt(reference),
          dueDate: rent.effectiveDueDateAt(reference),
          status: status,
          overdueDays: rent.overdueDaysAt(reference),
        ),
      );
    }
    return records;
  }
}
