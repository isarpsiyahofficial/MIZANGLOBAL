import '../core/formatters.dart';
import '../l10n/mizan_i18n.dart';
import '../models/mizan_models.dart';

enum ReminderKind { payment, expense }

/// Android tarafında aynı anda tutulacak yakın bildirimleri kontrollü tutar.
/// Uzak tarihler uygulama açıldığında yeniden hesaplanır.
const int safeMaximumConcurrentNotifications = 96;

class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.sourceId,
    required this.kind,
    required this.title,
    required this.message,
    required this.scheduledAt,
    this.repeatsDaily = false,
  });

  final int id;
  final String sourceId;
  final ReminderKind kind;
  final String title;
  final String message;
  final DateTime scheduledAt;
  final bool repeatsDaily;
}

class ReminderPlanBuilder {
  const ReminderPlanBuilder();

  List<ScheduledReminder> build({
    required MizanState state,
    required DateTime now,
    int maximumPaymentReminders = safeMaximumConcurrentNotifications,
  }) {
    MizanI18n.setProfile(
      languageTag: state.appLanguageTag,
      currencyCode: state.defaultCurrencyCode,
    );
    if (!state.notificationsEnabled) return const [];

    final daily = _expenseReminders(state, now)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final payments = _paymentReminders(state, now)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final paymentLimit = (safeMaximumConcurrentNotifications - daily.length)
        .clamp(0, maximumPaymentReminders)
        .toInt();

    final unique = <int, ScheduledReminder>{};
    for (final reminder in <ScheduledReminder>[
      ...daily,
      ...payments.take(paymentLimit),
    ]) {
      unique.putIfAbsent(reminder.id, () => reminder);
    }
    final result = unique.values.toList(growable: false)
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    return result
        .take(safeMaximumConcurrentNotifications)
        .toList(growable: false);
  }

  String _localizedSlotText(String value) {
    const systemValues = <String>{
      'Sabah gider',
      'Bugünkü giderlerini işlemeyi unutma.',
      'Öğlen gider',
      'Öğlene kadar yaptığın harcamaları ekleyebilirsin.',
      'Akşam gider',
      'Günü kapatmadan giderlerini kontrol et.',
      'Ödeme hatırlatması 1',
      'Ödeme hatırlatması 2',
      'Ödeme hatırlatması 3',
      'Yaklaşan ve gecikmiş ödemelerini kontrol et.',
      'Günün ödeme planını gözden geçir.',
    };
    return systemValues.contains(value)
        ? MizanI18n.text(value)
        : MizanI18n.user(value);
  }

  List<ScheduledReminder> _expenseReminders(MizanState state, DateTime now) => [
        for (final slot in state.notificationSlots)
          if (slot.enabled)
            ScheduledReminder(
              id: stableNotificationId('expense-${slot.id}'),
              sourceId: slot.id,
              kind: ReminderKind.expense,
              title: _localizedSlotText(slot.label),
              message: _localizedSlotText(slot.message),
              scheduledAt: _nextTime(now, slot.hour, slot.minute),
              repeatsDaily: true,
            ),
      ];

  DateTime _nextTime(DateTime now, int hour, int minute) {
    var result = DateTime(now.year, now.month, now.day, hour, minute);
    if (!result.isAfter(now)) result = result.add(const Duration(days: 1));
    return result;
  }

  /// Her açık kayıt ve etkin saat için yalnızca sıradaki bildirimi üretir.
  /// Böylece kayıt sayısı arttığında yüzlerce günlük kopya oluşturulmaz.
  List<ScheduledReminder> _paymentReminders(MizanState state, DateTime now) {
    final reminders = <ScheduledReminder>[];
    final records = state.recordReferencesAt(now)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    for (final record in records) {
      if (record.amount <= 0 ||
          record.status == PaymentStatus.completed ||
          record.status == PaymentStatus.passive) {
        continue;
      }
      final dueDay = dateOnly(record.dueDate);
      final today = dateOnly(now);
      for (final slot in state.paymentNotificationSlots) {
        if (!slot.enabled) continue;
        final scheduledAt = _nextPaymentTime(
          now: now,
          today: today,
          dueDay: dueDay,
          hour: slot.hour,
          minute: slot.minute,
        );
        if (scheduledAt == null) continue;
        final key =
            'payment-${record.type.name}-${record.personId}-${record.bankId ?? 'none'}-${record.sourceId}-${scheduledAt.year}-${scheduledAt.month}-${scheduledAt.day}-${slot.id}';
        final timing = record.overdueDays > 0
            ? MizanI18n.text('Ödeme ${record.overdueDays} gün gecikti.')
            : MizanI18n.text('Son ödeme ${shortDate(dueDay)}.');
        reminders.add(
          ScheduledReminder(
            id: stableNotificationId(key),
            sourceId: record.sourceId,
            kind: ReminderKind.payment,
            title: MizanI18n.text(
              '${record.type.label}: ${MizanI18n.user(record.title)}',
            ),
            message: MizanI18n.text(
              '${_localizedSlotText(slot.message.trim())} $timing ${MizanI18n.text('Kalan tutar')} ${money(record.amount, currencyCode: record.currencyCode)}.'
                  .trim(),
            ),
            scheduledAt: scheduledAt,
            repeatsDaily: true,
          ),
        );
      }
    }
    return reminders;
  }

  DateTime? _nextPaymentTime({
    required DateTime now,
    required DateTime today,
    required DateTime dueDay,
    required int hour,
    required int minute,
  }) {
    final firstDay = dueDay.isBefore(today)
        ? today
        : dueDay.subtract(const Duration(days: 5));
    final lastDay = dueDay.isBefore(today)
        ? today.add(const Duration(days: 1))
        : dueDay.add(const Duration(days: 5));
    var day = firstDay.isBefore(today) ? today : firstDay;
    while (!day.isAfter(lastDay)) {
      final candidate = DateTime(day.year, day.month, day.day, hour, minute);
      if (candidate.isAfter(now)) return candidate;
      day = day.add(const Duration(days: 1));
    }
    return null;
  }
}
