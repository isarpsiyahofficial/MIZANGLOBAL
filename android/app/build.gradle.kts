plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val googleSampleAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val isReleaseTask = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}
val allowTestRelease =
    System.getenv("MIZAN_ALLOW_TEST_RELEASE")?.toBooleanStrictOrNull() ?: false
val useTestAds = System.getenv("MIZAN_TEST_ADS")?.toBooleanStrictOrNull() ?: !isReleaseTask
val productionAdMobAppId = (System.getenv("MIZAN_ADMOB_APP_ID") ?: "").trim()
val selectedAdMobAppId = if (useTestAds) {
    googleSampleAdMobAppId
} else {
    require(
        productionAdMobAppId.startsWith("ca-app-pub-") &&
            productionAdMobAppId.contains("~") &&
            !productionAdMobAppId.contains("3940256099942544"),
    ) {
        "MIZAN_ADMOB_APP_ID must contain the production AdMob app ID for a production release."
    }
    productionAdMobAppId
}

if (isReleaseTask && useTestAds && !allowTestRelease) {
    error(
        "Production release refused: test AdMob configuration is active. " +
            "Use production IDs, or set MIZAN_ALLOW_TEST_RELEASE=true only for an internal CI artifact.",
    )
}

val releaseKeystorePath = (System.getenv("MIZAN_RELEASE_KEYSTORE_PATH") ?: "").trim()
val releaseKeystorePassword = (System.getenv("MIZAN_RELEASE_KEYSTORE_PASSWORD") ?: "").trim()
val releaseKeyAlias = (System.getenv("MIZAN_RELEASE_KEY_ALIAS") ?: "").trim()
val releaseKeyPassword = (System.getenv("MIZAN_RELEASE_KEY_PASSWORD") ?: "").trim()
val hasReleaseSigning = listOf(
    releaseKeystorePath,
    releaseKeystorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { it.isNotEmpty() }

if (isReleaseTask && !hasReleaseSigning && !allowTestRelease) {
    error(
        "Production release refused: Play release signing credentials are missing. " +
            "MIZAN_ALLOW_TEST_RELEASE=true is permitted only for internal CI artifacts.",
    )
}

android {
    namespace = "com.lefferionprime.mizanglobal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("mizanRelease") {
                storeFile = file(releaseKeystorePath)
                storePassword = releaseKeystorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.lefferionprime.mizanglobal"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobApplicationId"] = selectedAdMobAppId
    }

    buildTypes {
        release {
            // A debug signature is allowed only for an explicitly marked
            // internal/test release. Normal release tasks fail above when the
            // Play signing credentials are absent.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("mizanRelease")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    implementation("com.google.android.play:integrity:1.6.0")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
