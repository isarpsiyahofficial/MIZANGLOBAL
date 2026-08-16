plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val googleSampleAdMobAppId = "ca-app-pub-3940256099942544~3347511713"
val useTestAds = (System.getenv("MIZAN_TEST_ADS") ?: "true").toBooleanStrictOrNull() ?: true
val productionAdMobAppId = (System.getenv("MIZAN_ADMOB_APP_ID") ?: "").trim()
val selectedAdMobAppId = if (useTestAds) {
    googleSampleAdMobAppId
} else {
    require(
        productionAdMobAppId.startsWith("ca-app-pub-") &&
            productionAdMobAppId.contains("~") &&
            !productionAdMobAppId.contains("3940256099942544"),
    ) {
        "MIZAN_ADMOB_APP_ID must contain the production AdMob app ID when MIZAN_TEST_ADS=false."
    }
    productionAdMobAppId
}

android {
    namespace = "com.lefferionprime.mizanglobal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
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
            // Production signing must be switched to the Play release key before release.
            signingConfig = signingConfigs.getByName("debug")
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
