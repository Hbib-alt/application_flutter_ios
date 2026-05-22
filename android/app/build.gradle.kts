plugins {

    id("com.android.application")

    id("kotlin-android")

    id("dev.flutter.flutter-gradle-plugin")

    // 🔥 Firebase
    id("com.google.gms.google-services")
}

android {

    namespace =
        "com.example.app_final_clean_v2"

    // ✅ FIX PRINTING APK
    compileSdk = 36

    ndkVersion =
        flutter.ndkVersion

    compileOptions {

        sourceCompatibility =
            JavaVersion.VERSION_17

        targetCompatibility =
            JavaVersion.VERSION_17

        // ✅ DESUGARING
        isCoreLibraryDesugaringEnabled =
            true
    }

    kotlinOptions {

        jvmTarget = "17"
    }

    defaultConfig {

    applicationId =
        "com.example.app_final_clean_v2"

    minSdk = flutter.minSdkVersion

    targetSdk = 36

    multiDexEnabled = true

    versionCode =
        flutter.versionCode

    versionName =
        flutter.versionName
}

    buildTypes {

        release {

            signingConfig =
                signingConfigs.getByName(
                    "debug"
                )
        }
    }
}

dependencies {

    // ✅ Java desugaring
    coreLibraryDesugaring(

        "com.android.tools:desugar_jdk_libs:2.0.4"
    )

    // 🔥 Firebase Messaging
    implementation(

        "com.google.firebase:firebase-messaging"
    )
}

flutter {

    source = "../.."
}
