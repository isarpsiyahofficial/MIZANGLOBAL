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
  }) {
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
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
}
