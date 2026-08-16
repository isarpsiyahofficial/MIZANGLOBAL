package com.lefferionprime.mizanglobal

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deviceIdentityChannel =
        "com.lefferionprime.mizanglobal/device_identity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceIdentityChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidId" -> {
                    val androidId = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID,
                    )
                    if (androidId.isNullOrBlank()) {
                        result.error(
                            "ANDROID_ID_UNAVAILABLE",
                            "Android device identifier is unavailable.",
                            null,
                        )
                    } else {
                        result.success(androidId)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
