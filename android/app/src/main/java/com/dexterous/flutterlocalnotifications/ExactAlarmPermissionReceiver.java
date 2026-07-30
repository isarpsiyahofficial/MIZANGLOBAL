package com.dexterous.flutterlocalnotifications;

import android.app.AlarmManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Build;

import androidx.annotation.Keep;

@Keep
public final class ExactAlarmPermissionReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S || intent == null) return;
        if (!AlarmManager.ACTION_SCHEDULE_EXACT_ALARM_PERMISSION_STATE_CHANGED.equals(intent.getAction())) return;
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager != null && alarmManager.canScheduleExactAlarms()) {
            FlutterLocalNotificationsPlugin.rescheduleNotifications(context);
        }
    }
}
