import '../core/mizan_clock.dart';
import '../core/formatters.dart';
import '../models/mizan_models.dart';
import 'report_service.dart';

class MonthlyPaymentStatus {
  const MonthlyPaymentStatus({
    required this.openRecords,
    required this.paymentDetails,
  });

  final List<RecordReference> openRecords;
  final List<ReportPaymentDetail> paymentDetails;

  double get openTotal =>
      openRecords.fold<double>(0.0, (sum, item) => sum + item.amount);

  double get paidTotal => paymentDetails.fold<double>(
    0.0,
    (sum, item) => sum + item.payment.amount,
  );

  double get plannedAndPaidTotal => openTotal + paidTotal;
}

class MonthlyPaymentStatusService {
  const MonthlyPaymentStatusService({
    this.reportService = const MizanReportService(),
  });

  final MizanReportService reportService;

  MonthlyPaymentStatus build({
    required MizanState state,
    required DateTime month,
    DateTime? referenceDate,
  }) {
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final today = dateOnly(referenceDate ?? MizanClock.now());
    final timingReference =
        month.year == today.year && month.month == today.month
        ? today
        : dateOnly(end);
    final dueKeys = <String>{};
    for (final person in state.people) {
      for (final bank in person.banks) {
        for (final product in bank.products) {
          if (!product.isArchived && product.isDueInMonth(month)) {
            dueKeys.add('debt|${bank.id}|${product.id}');
          }
        }
      }
      for (final debt in person.personalDebts) {
        if (!debt.isArchived && debt.isDueInMonth(month)) {
          dueKeys.add('personalDebt||${debt.id}');
        }
      }
      for (final bill in person.bills) {
        if (!bill.isArchived && bill.isDueInMonth(month)) {
          dueKeys.add('bill||${bill.id}');
        }
      }
      for (final subscription in person.subscriptions) {
        if (!subscription.isArchived && subscription.isDueInMonth(month)) {
          dueKeys.add('subscription||${subscription.id}');
        }
      }
      for (final rent in person.rents) {
        if (!rent.isArchived && rent.isDueInMonth(month)) {
          dueKeys.add('rent||${rent.id}');
        }
      }
    }

    final openRecords =
        state
            .recordReferencesAt(end)
            .where((record) {
              final key =
                  '${record.type.name}|${record.bankId ?? ''}|${record.sourceId}';
              if (!dueKeys.contains(key) || record.amount <= 0) return false;
              if (record.status == PaymentStatus.completed ||
                  record.status == PaymentStatus.passive) {
                return false;
              }
              return !dateOnly(record.dueDate).isAfter(dateOnly(end));
            })
            .map((record) => _withReferenceTiming(record, timingReference))
            .toList(growable: false)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final paymentDetails = reportService.paymentDetailsForRange(
      state: state,
      start: DateTime(month.year, month.month),
      endInclusive: DateTime(month.year, month.month + 1, 0),
    );
    return MonthlyPaymentStatus(
      openRecords: openRecords,
      paymentDetails: paymentDetails,
    );
  }

  RecordReference _withReferenceTiming(
    RecordReference record,
    DateTime reference,
  ) {
    final today = dateOnly(reference);
    final due = dateOnly(record.dueDate);
    final overdueDays = due.isBefore(today) ? today.difference(due).inDays : 0;
    final daysUntilDue = calendarDaysBetween(today, due);
    final status = overdueDays > 0
        ? PaymentStatus.overdue
        : daysUntilDue <= 5
        ? PaymentStatus.upcoming
        : PaymentStatus.active;
    return RecordReference(
      type: record.type,
      personId: record.personId,
      sourceId: record.sourceId,
      currencyCode: record.currencyCode,
      bankId: record.bankId,
      title: record.title,
      subtitle: record.subtitle,
      amount: record.amount,
      dueDate: record.dueDate,
      status: status,
      overdueDays: overdueDays,
    );
  }
}
