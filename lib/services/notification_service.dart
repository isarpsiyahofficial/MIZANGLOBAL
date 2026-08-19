import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/mizan_models.dart';
import 'reminder_engine.dart';

class MizanNotificationService {
  MizanNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!Platform.isAndroid) {
      _initialized = true;
      return;
    }
    tzdata.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } on Object {
      tz.setLocalLocation(tz.getLocation('Etc/UTC'));
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (!Platform.isAndroid) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> cancelAll() async {
    await initialize();
    if (!Platform.isAndroid) return;
    await _plugin.cancelAll();
  }

  Future<void> replaceAll({
    required List<ScheduledReminder> reminders,
    required NotificationSoundMode soundMode,
    required bool vibrationEnabled,
  }) async {
    await initialize();
    if (!Platform.isAndroid) return;
    await _plugin.cancelAll();
    final now = DateTime.now();
    for (final reminder in reminders
        .where((item) => item.scheduledAt.isAfter(now))
        .take(safeMaximumConcurrentNotifications)) {
      final playSound = soundMode == NotificationSoundMode.system;
      final channelId = _channelId(
        playSound: playSound,
        vibrationEnabled: vibrationEnabled,
      );
      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'MİZAN',
          importance: Importance.high,
          priority: Priority.high,
          playSound: playSound,
          enableVibration: vibrationEnabled,
        ),
      );
      final scheduledAt = tz.TZDateTime(
        tz.local,
        reminder.scheduledAt.year,
        reminder.scheduledAt.month,
        reminder.scheduledAt.day,
        reminder.scheduledAt.hour,
        reminder.scheduledAt.minute,
      );
      await _plugin.zonedSchedule(
        id: reminder.id & 0x7fffffff,
        title: reminder.title,
        body: reminder.message,
        scheduledDate: scheduledAt,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '${reminder.kind.name}:${reminder.sourceId}',
        matchDateTimeComponents:
            reminder.kind == ReminderKind.expense && reminder.repeatsDaily
            ? DateTimeComponents.time
            : null,
      );
    }
  }

  String _channelId({
    required bool playSound,
    required bool vibrationEnabled,
  }) =>
      'mizan_reminders_${playSound ? 'sound' : 'silent'}_'
      '${vibrationEnabled ? 'vibrate' : 'steady'}';
}
