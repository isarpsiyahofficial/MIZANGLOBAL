import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../core/formatters.dart';
import '../models/mizan_models.dart';
import 'reminder_engine.dart';

class NotificationHealth {
  const NotificationHealth({
    this.permissionGranted = false,
    this.preciseTimingGranted = false,
    this.initialized = false,
    this.message,
  });

  final bool permissionGranted;
  final bool preciseTimingGranted;
  final bool initialized;
  final String? message;

  NotificationHealth copyWith({
    bool? permissionGranted,
    bool? preciseTimingGranted,
    bool? initialized,
    String? message,
  }) => NotificationHealth(
    permissionGranted: permissionGranted ?? this.permissionGranted,
    preciseTimingGranted: preciseTimingGranted ?? this.preciseTimingGranted,
    initialized: initialized ?? this.initialized,
    message: message ?? this.message,
  );
}

abstract class ReminderScheduler {
  Future<void> initialize();
  Future<NotificationHealth> health();
  Future<NotificationHealth> requestPermissions();
  Future<void> reschedule(MizanState state);
  Future<DateTime> scheduleTestNotification({
    required NotificationSlot slot,
    required MizanState state,
  });
}

class NoopReminderScheduler implements ReminderScheduler {
  const NoopReminderScheduler();

  @override
  Future<NotificationHealth> health() async => const NotificationHealth(
    initialized: true,
    message: 'Bildirim servisi bu platformda etkin değil.',
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationHealth> requestPermissions() => health();

  @override
  Future<void> reschedule(MizanState state) async {}

  @override
  Future<DateTime> scheduleTestNotification({
    required NotificationSlot slot,
    required MizanState state,
  }) async => DateTime.now();
}

class LocalNotificationService implements ReminderScheduler {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    ReminderPlanBuilder? planBuilder,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _planBuilder = planBuilder ?? const ReminderPlanBuilder();

  NotificationDetails _detailsFor(ReminderKind kind, MizanState state) {
    final silent = state.notificationSoundMode == NotificationSoundMode.silent;
    final soundSuffix = silent ? 'silent' : 'system';
    final vibrationSuffix = state.notificationVibrationEnabled
        ? 'vibrate'
        : 'still';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        kind == ReminderKind.expense
            ? 'mizan_expense_notifications_v4_${soundSuffix}_$vibrationSuffix'
            : 'mizan_payment_notifications_v4_${soundSuffix}_$vibrationSuffix',
        kind == ReminderKind.expense
            ? 'Gider bildirimleri'
            : 'Ödeme bildirimleri',
        channelDescription: kind == ReminderKind.expense
            ? 'Günlük gider kaydı bildirimleri'
            : 'Tüm kayıt türlerinin son ödeme bildirimleri',
        importance: kind == ReminderKind.expense
            ? Importance.defaultImportance
            : Importance.high,
        priority: kind == ReminderKind.expense
            ? Priority.defaultPriority
            : Priority.high,
        playSound: !silent,
        enableVibration: state.notificationVibrationEnabled && !silent,
        audioAttributesUsage: AudioAttributesUsage.notification,
        autoCancel: true,
      ),
    );
  }

  final FlutterLocalNotificationsPlugin _plugin;
  final ReminderPlanBuilder _planBuilder;
  bool _initialized = false;
  bool _preciseTimingGranted = false;
  Future<void> _rescheduleTail = Future<void>.value();

  @override
  Future<void> initialize() async {
    if (_initialized || !Platform.isAndroid) return;
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } on Object {
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    }
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: initializationSettings);
    _initialized = true;
  }

  @override
  Future<NotificationHealth> health() async {
    if (!Platform.isAndroid) {
      return const NotificationHealth(
        initialized: true,
        message: 'Android dışında gerçek zamanlama yapılmaz.',
      );
    }
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final permission = await android?.areNotificationsEnabled() ?? false;
    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;
    return NotificationHealth(
      permissionGranted: permission,
      preciseTimingGranted: _preciseTimingGranted,
      initialized: true,
      message: !permission
          ? 'Bildirim izni kapalı.'
          : !_preciseTimingGranted
          ? 'Dakik bildirim izni kapalı. Saat ve dakika doğruluğu için izni açın.'
          : null,
    );
  }

  @override
  Future<NotificationHealth> requestPermissions() async {
    if (!Platform.isAndroid) return health();
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationPermission =
        await android?.requestNotificationsPermission() ?? false;
    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;
    if (!_preciseTimingGranted) {
      _preciseTimingGranted =
          await android?.requestExactAlarmsPermission() ?? false;
    }
    return NotificationHealth(
      permissionGranted: notificationPermission,
      preciseTimingGranted: _preciseTimingGranted,
      initialized: true,
      message: !notificationPermission
          ? 'Bildirim izni kapalı.'
          : !_preciseTimingGranted
          ? 'Dakik bildirim izni verilmedi.'
          : null,
    );
  }

  Future<void> _scheduleReminder(
    ScheduledReminder reminder,
    MizanState state,
  ) async {
    final local = reminder.scheduledAt;
    final scheduled = tz.TZDateTime(
      tz.local,
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
    await _plugin.zonedSchedule(
      id: reminder.id,
      title: reminder.title,
      body: reminder.message,
      scheduledDate: scheduled,
      notificationDetails: _detailsFor(reminder.kind, state),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '${reminder.kind.name}:${reminder.sourceId}',
      matchDateTimeComponents: reminder.repeatsDaily
          ? DateTimeComponents.time
          : null,
    );
  }

  bool _isManagedPending(PendingNotificationRequest request) {
    final payload = request.payload ?? '';
    return payload.startsWith('payment:') || payload.startsWith('expense:');
  }

  @override
  Future<void> reschedule(MizanState state) {
    if (!Platform.isAndroid) return Future<void>.value();
    final snapshot = MizanState.fromJson(state.toJson());
    final operation = _rescheduleTail.then<void>(
      (_) => _rescheduleNow(snapshot),
    );
    _rescheduleTail = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _rescheduleNow(MizanState state) async {
    await initialize();
    if (!state.notificationsEnabled) {
      await _plugin.cancelAllPendingNotifications();
      return;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final notificationsGranted =
        await android?.areNotificationsEnabled() ?? false;
    if (!notificationsGranted) {
      throw StateError('Bildirim izni kapalı. Yeni bildirimler oluşturulmadı.');
    }
    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;
    if (!_preciseTimingGranted) {
      throw StateError(
        'Dakik bildirim izni kapalı. Android mevcut dakik planları iptal eder; izin açıldığında plan yeniden kurulmalıdır.',
      );
    }

    final current = DateTime.now();
    final anchor = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute,
      current.second,
    );
    final plan = _planBuilder.build(state: state, now: anchor);
    final desiredIds = plan.map((item) => item.id).toSet();

    // Bellekteki varsayıma güvenilmez. Android tam zamanlama iznini iptal
    // ettiğinde gelecekteki exact alarm kayıtlarını silebilir. Bu nedenle her
    // senkronizasyonda işletim sistemindeki gerçek bekleyen bildirimler okunur,
    // eski MİZAN kayıtları kaldırılır ve istenen plan aynı kimliklerle yeniden
    // tescil edilir. Aynı kimlikle planlama Android tarafında güvenli bir replace
    // işlemidir ve uygulama kapalıyken çalışacak AlarmManager kaydını yeniler.
    final pendingBefore = await _plugin.pendingNotificationRequests();
    for (final request in pendingBefore) {
      if (_isManagedPending(request) && !desiredIds.contains(request.id)) {
        await _plugin.cancel(id: request.id);
      }
    }

    final failures = <String>[];
    for (final reminder in plan) {
      try {
        await _scheduleReminder(reminder, state);
      } on Object catch (error) {
        failures.add('${reminder.id}: $error');
      }
    }
    if (failures.isNotEmpty) {
      throw StateError(
        'Bildirim planındaki ${failures.length} kayıt Android sistemine yazılamadı. İlk hata: ${failures.first}',
      );
    }

    final pendingAfter = await _plugin.pendingNotificationRequests();
    final actualIds = pendingAfter
        .where(_isManagedPending)
        .map((item) => item.id)
        .toSet();
    final missing = desiredIds.difference(actualIds);
    if (missing.isNotEmpty) {
      throw StateError(
        'Bildirim planı doğrulanamadı; Android tarafında ${missing.length} kayıt eksik kaldı.',
      );
    }
  }

  @override
  Future<DateTime> scheduleTestNotification({
    required NotificationSlot slot,
    required MizanState state,
  }) async {
    if (!Platform.isAndroid) return DateTime.now();
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final permission = await android?.areNotificationsEnabled() ?? false;
    if (!permission) {
      throw StateError('Bildirim izni kapalı. Önce bildirim iznini açın.');
    }
    _preciseTimingGranted =
        await android?.canScheduleExactNotifications() ?? false;
    if (!_preciseTimingGranted) {
      _preciseTimingGranted =
          await android?.requestExactAlarmsPermission() ?? false;
    }
    if (!_preciseTimingGranted) {
      throw StateError(
        'Dakik bildirim izni verilmedi. Test yaklaşık zamanda çalıştırılmayacak.',
      );
    }
    final target = DateTime.now().add(const Duration(minutes: 1));
    final scheduled = tz.TZDateTime.from(target, tz.local);
    await _plugin.zonedSchedule(
      id: stableNotificationId('mizan-precise-test-${slot.id}'),
      title: 'MİZAN bildirim testi',
      body: 'Bu test, ayarlanan dakik bildirim sistemiyle oluşturuldu.',
      scheduledDate: scheduled,
      notificationDetails: _detailsFor(ReminderKind.payment, state),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'test:${slot.id}',
    );
    return target;
  }
}
