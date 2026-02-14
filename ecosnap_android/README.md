# 🌱 EcoSnap - Android App Setup Guide

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Setup](#project-setup)
3. [Firebase Configuration](#firebase-configuration)
4. [TensorFlow Lite Model Setup](#tensorflow-lite-model-setup)
5. [Building the App](#building-the-app)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## ✅ Prerequisites

### Required Software
- **Flutter SDK**: 3.0.0 or higher ([Download](https://flutter.dev/docs/get-started/install))
- **Android Studio**: Latest version with Android SDK
- **Java Development Kit (JDK)**: 11 or higher
- **Git**: For version control

### Verify Installation
```bash
flutter doctor
```

---

## 🚀 Project Setup

### 1. Clone the Project
```bash
cd ecosnap_android
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Enable Android Platform
```bash
flutter config --enable-android
```

---

## 🔥 Firebase Configuration

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `ecosnap` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create Project"

### Step 2: Add Android App to Firebase
1. In Firebase Console, click "Add App" → Android icon
2. Enter package name: `com.ecosnap.app`
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`

### Step 3: Enable Firebase Services

#### Authentication
1. Go to Authentication → Get Started
2. Enable **Email/Password** sign-in method

#### Cloud Firestore
1. Go to Firestore Database → Create Database
2. Start in **Test Mode** (for development)
3. Select region: `asia-southeast1` (Singapore) or closest to Malaysia
4. Click "Enable"

#### Firestore Security Rules (Initial Setup)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Scan results
    match /scan_results/{scanId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    
    // Products
    match /products/{productId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.sellerId;
    }
    
    // Community posts
    match /community_posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

**✨ Important: Image Storage**

We're using **local device storage** for images instead of Firebase Storage to avoid the paid upgrade requirement!

- ✅ **100% Free** - No Firebase Blaze plan needed
- ✅ **Faster** - No internet upload required  
- ✅ **Privacy** - Images stay on device
- ✅ **Works Offline** - Full functionality without internet

See **`LOCAL_STORAGE_GUIDE.md`** for complete details!

---

### Step 4: Update Android Configuration

#### android/build.gradle
```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2'
        classpath 'com.google.gms:google-services:4.3.15'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

#### android/app/build.gradle
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

android {
    namespace "com.ecosnap.app"
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.ecosnap.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'androidx.multidex:multidex:2.0.1'
}

apply plugin: 'com.google.gms.google-services'
```

#### android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    
    <application
        android:label="EcoSnap"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

## 🤖 TensorFlow Lite Model Setup

### Creating a Simple Waste Classification Model

Since you need an on-device model without using external AI APIs, you'll need to create or download a TensorFlow Lite model.

### Train Custom Model with TensorFlow

For a production app, you should train a custom model. Here's a basic guide:

#### Step 1: Collect Dataset
- Gather images of different waste items
- Categorize them by: item type, material, condition
- Minimum 100 images per category recommended

#### Step 2: Train Model (Python)
```python
import tensorflow as tf
from tensorflow import keras
import tensorflow_datasets as tfds

# Load your dataset
# ... (dataset loading code)

# Create model
model = keras.Sequential([
    keras.layers.Conv2D(32, (3,3), activation='relu', input_shape=(224, 224, 3)),
    keras.layers.MaxPooling2D(2, 2),
    keras.layers.Conv2D(64, (3,3), activation='relu'),
    keras.layers.MaxPooling2D(2, 2),
    keras.layers.Flatten(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(num_classes, activation='softmax')
])

model.compile(optimizer='adam',
              loss='categorical_crossentropy',
              metrics=['accuracy'])

# Train model
model.fit(train_dataset, epochs=10, validation_data=val_dataset)

# Convert to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save
with open('waste_classifier.tflite', 'wb') as f:
    f.write(tflite_model)
```

#### Step 3: Test Model
```python
import tensorflow as tf
import numpy as np
from PIL import Image

# Load TFLite model
interpreter = tf.lite.Interpreter(model_path="waste_classifier.tflite")
interpreter.allocate_tensors()

# Get input and output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Load and preprocess image
image = Image.open("test_image.jpg").resize((224, 224))
input_data = np.array(image, dtype=np.float32) / 255.0
input_data = np.expand_dims(input_data, axis=0)

# Run inference
interpreter.set_tensor(input_details[0]['index'], input_data)
interpreter.invoke()
output_data = interpreter.get_tensor(output_details[0]['index'])

print("Prediction:", output_data)
```

---

## 🏗️ Building the App

### Development Build
```bash
# Run on connected device/emulator
flutter run

# Run with hot reload
flutter run --debug
```

### Release Build (APK)
```bash
# Build release APK
flutter build apk --release

# Build split APKs (smaller size)
flutter build apk --split-per-abi
```

### Release Build (App Bundle for Play Store)
```bash
flutter build appbundle --release
```

The output will be in: `build/app/outputs/`

---

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Manual Testing Checklist
- [ ] User authentication (sign up, login, logout)
- [ ] Image capture from camera
- [ ] Image selection from gallery
- [ ] AI classification accuracy
- [ ] Firestore data persistence
- [ ] Marketplace listings
- [ ] Community posts
- [ ] Profile statistics

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Firebase Not Initialized
**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**: Ensure `google-services.json` is in `android/app/` and Firebase is initialized in `main.dart`

#### 2. TFLite Model Not Loading
**Error**: `Unable to load asset: assets/models/waste_classifier.tflite`

**Solution**: 
- Verify model file exists in `assets/models/`
- Check `pubspec.yaml` has correct asset paths
- Run `flutter clean` and `flutter pub get`

#### 3. Camera Permission Denied
**Error**: Camera not accessible

**Solution**: Add permissions to `AndroidManifest.xml` and request at runtime

#### 4. Build Failed - Gradle Issues
**Error**: Gradle build failures

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

#### 5. Out of Memory Error
**Error**: `OutOfMemoryError` during build

**Solution**: Add to `android/gradle.properties`:
```
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

---

## 📱 App Features Overview

### ✅ Implemented Features
- User authentication (email/password)
- Camera integration for item scanning
- On-device AI classification (TensorFlow Lite)
- Scan history with Firebase
- Reuse ideas based on item type
- Market value estimation
- Recycling center suggestions
- Marketplace for selling upcycled items
- Community posts and engagement
- User impact tracking
- Real-time user messaging
- Community networking & collaboration

### 🎨 UI/UX
- Clean green and white theme
- Material Design 3
- Intuitive navigation
- Responsive layouts

---

## 📦 Deployment

### Google Play Store

1. **Prepare Release**
   - Update version in `pubspec.yaml`
   - Test thoroughly
   - Build app bundle

2. **Create Play Console Account**
   - Go to [Google Play Console](https://play.google.com/console)
   - Pay one-time fee ($25 USD)

3. **Create App Listing**
   - Upload screenshots
   - Write description
   - Add privacy policy

4. **Upload APK/Bundle**
   ```bash
   flutter build appbundle --release
   ```

5. **Submit for Review**

---

## 🤝 Contributing

This is a hackathon/competition project. Features to add:
- Advanced search and filters
- Push notifications
- Offline mode
- Multi-language support

---

## 📄 License

This project is created for educational and competition purposes.

---

## 📞 Support

For issues or questions, refer to:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [TensorFlow Lite Guide](https://www.tensorflow.org/lite/guide)

---

**Built with ❤️ using Google tools**
