package com.lefferionprime.mizanglobal

import android.provider.Settings
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.StandardIntegrityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val deviceIdentityChannel =
        "com.lefferionprime.mizanglobal/device_identity"
    private val playIntegrityChannel =
        "com.lefferionprime.mizanglobal/play_integrity"

    private val standardIntegrityManager by lazy {
        IntegrityManagerFactory.createStandard(applicationContext)
    }
    private var integrityTokenProvider:
        StandardIntegrityManager.StandardIntegrityTokenProvider? = null
    private var preparedCloudProjectNumber: Long? = null

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            playIntegrityChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestStandardToken" -> {
                    val cloudProjectNumber = call.argument<Number>("cloudProjectNumber")?.toLong()
                    val requestHash = call.argument<String>("requestHash")?.trim()
                    if (cloudProjectNumber == null || cloudProjectNumber <= 0L || requestHash.isNullOrBlank()) {
                        result.error(
                            "INVALID_INTEGRITY_ARGUMENTS",
                            "Cloud project number and request hash are required.",
                            null,
                        )
                    } else {
                        requestIntegrityToken(cloudProjectNumber, requestHash, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun requestIntegrityToken(
        cloudProjectNumber: Long,
        requestHash: String,
        result: MethodChannel.Result,
    ) {
        val provider = integrityTokenProvider
        if (provider != null && preparedCloudProjectNumber == cloudProjectNumber) {
            requestWithProvider(provider, requestHash, result, allowReprepare = true)
            return
        }

        standardIntegrityManager.prepareIntegrityToken(
            StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
                .setCloudProjectNumber(cloudProjectNumber)
                .build(),
        )
            .addOnSuccessListener { preparedProvider ->
                integrityTokenProvider = preparedProvider
                preparedCloudProjectNumber = cloudProjectNumber
                requestWithProvider(preparedProvider, requestHash, result, allowReprepare = false)
            }
            .addOnFailureListener { error ->
                result.error(
                    "PLAY_INTEGRITY_PREPARE_FAILED",
                    error.message ?: "Play Integrity token provider could not be prepared.",
                    null,
                )
            }
    }

    private fun requestWithProvider(
        provider: StandardIntegrityManager.StandardIntegrityTokenProvider,
        requestHash: String,
        result: MethodChannel.Result,
        allowReprepare: Boolean,
    ) {
        provider.request(
            StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                .setRequestHash(requestHash)
                .build(),
        )
            .addOnSuccessListener { response ->
                result.success(response.token())
            }
            .addOnFailureListener { error ->
                if (allowReprepare) {
                    val project = preparedCloudProjectNumber
                    integrityTokenProvider = null
                    preparedCloudProjectNumber = null
                    if (project != null) {
                        requestIntegrityToken(project, requestHash, result)
                    } else {
                        result.error(
                            "PLAY_INTEGRITY_REQUEST_FAILED",
                            error.message ?: "Play Integrity token request failed.",
                            null,
                        )
                    }
                } else {
                    result.error(
                        "PLAY_INTEGRITY_REQUEST_FAILED",
                        error.message ?: "Play Integrity token request failed.",
                        null,
                    )
                }
            }
    }
}
