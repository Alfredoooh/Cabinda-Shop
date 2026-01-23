plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cabinda_shop"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.cabinda_shop"
        minSdk = 24  // Aumenta para permitir mais otimizações
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // SÓ arm64 - reduz 50% do tamanho
        ndk {
            abiFilters.clear()
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            
            // ProGuard - remove código não usado
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            
            // Compressão MÁXIMA
            ndk {
                debugSymbolLevel = "NONE"
            }
            
            isZipAlignEnabled = true
            isCrunchPngs = true
        }
    }
    
    // Remove arquivos desnecessários do APK
    packagingOptions {
        resources {
            excludes += setOf(
                "META-INF/**",
                "kotlin/**",
                "**.properties",
                "**.bin",
                "DebugProbesKt.bin"
            )
        }
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}