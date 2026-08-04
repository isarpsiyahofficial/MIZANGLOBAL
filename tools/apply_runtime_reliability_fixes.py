from __future__ import annotations

from pathlib import Path


def replace_once(path: str, old: str, new: str) -> None:
    file_path = Path(path)
    text = file_path.read_text(encoding="utf-8")
    count = text.count(old)
    if count == 1:
        file_path.write_text(text.replace(old, new, 1), encoding="utf-8")
        return
    if count == 0 and new in text:
        return
    raise SystemExit(
        f"{path}: expected one patch target or verified result, found {count}."
    )


def patch_monthly_status_service() -> None:
    path = Path("lib/services/monthly_payment_status_service.dart")
    text = path.read_text(encoding="utf-8")

    old_signature = """  MonthlyPaymentStatus build({
    required MizanState state,
    required DateTime month,
  }) {
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
"""
    new_signature = """  MonthlyPaymentStatus build({
    required MizanState state,
    required DateTime month,
    DateTime? referenceDate,
  }) {
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    final today = dateOnly(referenceDate ?? DateTime.now());
    final timingReference = month.year == today.year && month.month == today.month
        ? today
        : dateOnly(end);
"""
    if new_signature not in text:
        if text.count(old_signature) != 1:
            raise SystemExit("monthly status signature patch target is not unique")
        text = text.replace(old_signature, new_signature, 1)

    old_list = """            })
            .toList(growable: false)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
"""
    new_list = """            })
            .map(
              (record) => _withReferenceTiming(record, timingReference),
            )
            .toList(growable: false)
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
"""
    if new_list not in text:
        if text.count(old_list) != 1:
            raise SystemExit("monthly status record timing patch target is not unique")
        text = text.replace(old_list, new_list, 1)

    old_end = """    return MonthlyPaymentStatus(
      openRecords: openRecords,
      paymentDetails: paymentDetails,
    );
  }
}
"""
    new_end = """    return MonthlyPaymentStatus(
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
"""
    if new_end not in text:
        if text.count(old_end) != 1:
            raise SystemExit("monthly status helper insertion target is not unique")
        text = text.replace(old_end, new_end, 1)

    path.write_text(text, encoding="utf-8")


def patch_dashboard() -> None:
    replace_once(
        "lib/screens/dashboard_screen.dart",
        """      final monthlyStatus = const MonthlyPaymentStatusService().build(
        state: state,
        month: now,
      );
""",
        """      final monthlyStatus = const MonthlyPaymentStatusService().build(
        state: state,
        month: now,
        referenceDate: now,
      );
""",
    )


def patch_formatters() -> None:
    path = Path("lib/core/formatters.dart")
    text = path.read_text(encoding="utf-8")

    if "MizanI18n.isUkrainian" in text:
        for fragment in (
            "MizanI18n.isRussian || MizanI18n.isUkrainian",
            "MizanI18n.isPolish ? '\\u202F' : '\\u00A0'",
        ):
            if fragment not in text:
                raise SystemExit(
                    f"lib/core/formatters.dart: missing Ukrainian-aware reliability fragment {fragment!r}"
                )
        return

    money_old = r"""  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : ((MizanI18n.isFrench || MizanI18n.isPolish)
            ? '\u202F'
            : (MizanI18n.isPortuguesePt ? ' ' : '.'));
"""
    money_new = r"""  final groupSeparator = MizanI18n.isEnglish
      ? ','
      : ((MizanI18n.isFrench || MizanI18n.isPolish)
            ? '\u202F'
            : (MizanI18n.isRussian
                  ? '\u00A0'
                  : (MizanI18n.isPortuguesePt ? ' ' : '.')));
"""
    if money_new not in text:
        if text.count(money_old) != 1:
            raise SystemExit(
                f"formatter money grouping target count: {text.count(money_old)}"
            )
        text = text.replace(money_old, money_new, 1)

    decimal_old = r"""        grouped.write(
          (MizanI18n.isRomanian || MizanI18n.isGreek) ? '.' : '\u00A0',
        );
"""
    decimal_new = r"""        grouped.write(
          (MizanI18n.isRomanian || MizanI18n.isGreek)
              ? '.'
              : (MizanI18n.isPolish ? '\u202F' : '\u00A0'),
        );
"""
    if decimal_new not in text:
        if text.count(decimal_old) != 1:
            raise SystemExit(
                f"formatter decimal grouping target count: {text.count(decimal_old)}"
            )
        text = text.replace(decimal_old, decimal_new, 1)

    path.write_text(text, encoding="utf-8")


def patch_notification_service() -> None:
    replace_once(
        "lib/services/notification_service.dart",
        """      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${reminder.kind.name}:${reminder.sourceId}',
""",
        """      androidScheduleMode: _preciseTimingGranted
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: '${reminder.kind.name}:${reminder.sourceId}',
""",
    )
    replace_once(
        "lib/services/notification_service.dart",
        """    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;
    if (!_preciseTimingGranted) {
      throw StateError(
        MizanI18n.text(
          'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.',
        ),
      );
    }

    final current = DateTime.now();
""",
        """    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;

    final current = DateTime.now();
""",
    )
    replace_once(
        "lib/services/notification_service.dart",
        """    if (!_preciseTimingGranted) {
      throw StateError(
        MizanI18n.text(
          'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
        ),
      );
    }
    final target = DateTime.now().add(const Duration(minutes: 1));
""",
        """    final target = DateTime.now().add(const Duration(minutes: 1));
""",
    )
    replace_once(
        "lib/services/notification_service.dart",
        """      body: MizanI18n.text(
        'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.',
        languageTag: state.appLanguageTag,
      ),
""",
        """      body: _preciseTimingGranted
          ? MizanI18n.text(
              'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.',
              languageTag: state.appLanguageTag,
            )
          : slot.message,
""",
    )
    replace_once(
        "lib/services/notification_service.dart",
        """      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'test:${slot.id}',
""",
        """      androidScheduleMode: _preciseTimingGranted
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'test:${slot.id}',
""",
    )


def patch_controller() -> None:
    replace_once(
        "lib/controllers/mizan_controller.dart",
        """        if (state.notificationsEnabled &&
            (!health.permissionGranted || !health.preciseTimingGranted)) {
          if (surfaceErrors) {
            _lastError = !health.permissionGranted
                ? 'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.'
                : 'Dakik bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.';
          }
          return;
        }
""",
        """        if (state.notificationsEnabled && !health.permissionGranted) {
          if (surfaceErrors) {
            _lastError =
                'Bildirim izni kapalı. Android izni açıldığında MİZAN otomatik olarak yeniden senkronize eder.';
          }
          return;
        }
""",
    )


def patch_settings_copy() -> None:
    replace_once(
        "lib/screens/settings_screen.dart",
        """                      : 'Android dakik bildirim izni kapalı. MİZAN yaklaşık zamanlama kullanmaz; saat ve dakikada teslim için bu izin açılmalıdır.',
""",
        """                      : 'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
""",
    )
    replace_once(
        "lib/screens/settings_screen.dart",
        """                            text:
                                'MİZAN yaklaşık zamanlama kullanmaz. Kaydettiğinde gerekli Android izin ekranı otomatik açılır; izin verildiğinde bildirimler uygulamaya dönüşte otomatik senkronize edilir.',
""",
        """                            text:
                                'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
""",
    )
    replace_once(
        "lib/screens/settings_screen.dart",
        """                                      _showMessage(
                                        dialogContext,
                                        'Test ${timeLabel(target.hour, target.minute)} için dakik olarak planlandı.',
                                      );
""",
        """                                      _showMessage(
                                        dialogContext,
                                        controller
                                                .notificationHealth
                                                .preciseTimingGranted
                                            ? 'Test ${timeLabel(target.hour, target.minute)} için dakik olarak planlandı.'
                                            : 'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.',
                                      );
""",
    )


def main() -> None:
    patch_monthly_status_service()
    patch_dashboard()
    patch_formatters()
    patch_notification_service()
    patch_controller()
    patch_settings_copy()

    required_fragments = {
        "lib/services/monthly_payment_status_service.dart": [
            "DateTime? referenceDate",
            "_withReferenceTiming(record, timingReference)",
        ],
        "lib/core/formatters.dart": [
            "MizanI18n.isRussian || MizanI18n.isUkrainian",
            "MizanI18n.isPolish ? '\\u202F' : '\\u00A0'",
        ],
        "lib/services/notification_service.dart": [
            "AndroidScheduleMode.inexactAllowWhileIdle",
            "AndroidScheduleMode.exactAllowWhileIdle",
            ": slot.message",
        ],
        "lib/controllers/mizan_controller.dart": [
            "state.notificationsEnabled && !health.permissionGranted",
        ],
        "lib/screens/dashboard_screen.dart": ["referenceDate: now"],
        "lib/screens/settings_screen.dart": [
            "controller\n                                                .notificationHealth\n                                                .preciseTimingGranted",
        ],
    }
    forbidden_fragments = {
        "lib/services/notification_service.dart": [
            "Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder",
            "Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.",
        ],
        "lib/screens/settings_screen.dart": [
            "MİZAN yaklaşık zamanlama kullanmaz",
        ],
    }
    for file_name, fragments in required_fragments.items():
        text = Path(file_name).read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment not in text:
                raise SystemExit(f"{file_name}: missing verified fragment {fragment!r}")
    for file_name, fragments in forbidden_fragments.items():
        text = Path(file_name).read_text(encoding="utf-8")
        for fragment in fragments:
            if fragment in text:
                raise SystemExit(f"{file_name}: forbidden stale fragment {fragment!r}")

    print("Runtime reliability fixes are present and deterministic.")


if __name__ == "__main__":
    main()
