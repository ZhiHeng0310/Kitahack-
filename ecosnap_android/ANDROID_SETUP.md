# 📱 Android Configuration Guide

## ✅ Android Files Included

Your project now has the complete Android setup:

```
android/
├── build.gradle                          # Root build configuration
├── settings.gradle                       # Gradle settings
├── gradle.properties                     # Gradle properties
├── gradle/wrapper/
│   └── gradle-wrapper.properties        # Gradle wrapper config
└── app/
    ├── build.gradle                     # App build configuration
    ├── google-services.json.PLACEHOLDER # Firebase config (REPLACE THIS!)
    └── src/main/
        ├── AndroidManifest.xml          # App manifest
        ├── kotlin/com/ecosnap/app/
        │   └── MainActivity.kt          # Main activity
        └── res/
            ├── values/
            │   └── styles.xml           # Light theme
            ├── values-night/
            │   └── styles.xml           # Dark theme
            ├── drawable/
            │   └── launch_background.xml
            └── drawable-v21/
                └── launch_background.xml
```

## 🔥 Firebase Setup (CRITICAL!)

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name: `ecosnap` (or your choice)
4. Disable Google Analytics (optional for now)
5. Click **"Create project"**

### Step 2: Add Android App

1. In Firebase Console, click **"Add app"** → Select **Android**
2. Enter these details:
   - **Android package name**: `com.ecosnap.app` (MUST match exactly!)
   - **App nickname**: EcoSnap (optional)
   - **Debug signing certificate**: Leave blank for now
3. Click **"Register app"**

### Step 3: Download Configuration File

1. Download the `google-services.json` file
2. **IMPORTANT**: Replace the placeholder file with this downloaded file
3. Location: `android/app/google-services.json`

```bash
# Delete the placeholder
rm android/app/google-services.json.PLACEHOLDER

# Copy your downloaded file here
cp ~/Downloads/google-services.json android/app/
```

### Step 4: Enable Firebase Services

#### Enable Authentication
1. In Firebase Console → **Authentication**
2. Click **"Get started"**
3. Select **"Email/Password"**
4. Enable it and click **"Save"**

#### Enable Firestore Database
1. In Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Start in **"Test mode"** (for development)
4. Select region: **asia-southeast1** (Singapore) or closest
5. Click **"Enable"**

**Note**: We're using **local device storage** for images, so you DON'T need Firebase Storage! This keeps your app 100% free. See `LOCAL_STORAGE_GUIDE.md` for details.

### Step 5: Security Rules

#### Firestore Rules
Go to **Firestore Database** → **Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
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
      allow update: if request.auth != null;
    }
  }
}
```

Click **"Publish"**

**💡 Good News**: No Firebase Storage setup needed! We're using local device storage for images, which keeps your app 100% free! See `LOCAL_STORAGE_GUIDE.md` for details.

## 📱 Android SDK Setup

### Required Tools

1. **Android Studio**: Latest version
2. **Android SDK**: API 21 (Lollipop) to API 34
3. **Android SDK Build Tools**: 34.0.0
4. **Android SDK Platform Tools**
5. **Android SDK Command-line Tools**

### Install via Android Studio

1. Open Android Studio
2. Go to **Tools** → **SDK Manager**
3. In **SDK Platforms** tab:
   - Check **Android 14.0 (API 34)** ✓
   - Check **Android 5.0 (API 21)** ✓
4. In **SDK Tools** tab:
   - Check **Android SDK Build-Tools 34** ✓
   - Check **Android SDK Platform-Tools** ✓
   - Check **Android SDK Command-line Tools** ✓
5. Click **"Apply"** and wait for installation

### Set Environment Variables

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

Reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

## 🔧 Gradle Configuration

All Gradle files are already configured! Here's what they do:

### `android/build.gradle`
- Sets up Kotlin version
- Adds Firebase plugin
- Configures repositories

### `android/app/build.gradle`
- Sets app package name: `com.ecosnap.app`
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Adds Firebase dependencies
- Enables MultiDex

### `android/gradle.properties`
- Increases heap size (prevents out of memory)
- Enables AndroidX
- Enables Jetifier

## ✅ Verification Checklist

Before running, verify:

- [ ] Flutter installed: `flutter doctor`
- [ ] Android SDK installed
- [ ] `google-services.json` in `android/app/` (NOT the placeholder!)
- [ ] Firebase services enabled (Auth, Firestore, Storage)
- [ ] Security rules published
- [ ] Device/emulator connected: `flutter devices`

## 🚀 Build & Run

### First Time Setup
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Check for issues
flutter doctor -v
```

### Run on Device/Emulator
```bash
# List available devices
flutter devices

# Run app
flutter run

# Or specify device
flutter run -d <device-id>
```

### Build APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi
```

Output location: `build/app/outputs/flutter-apk/`

### Build App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

Output location: `build/app/outputs/bundle/release/`

## 🐛 Common Issues

### Issue: "google-services.json not found"
**Solution**: Make sure you replaced the placeholder file with the real one from Firebase Console

### Issue: "Default FirebaseApp is not initialized"
**Solution**: 
1. Check `google-services.json` is in correct location
2. Verify package name matches: `com.ecosnap.app`
3. Clean and rebuild: `flutter clean && flutter pub get`

### Issue: "Execution failed for task ':app:processDebugGoogleServices'"
**Solution**: Your `google-services.json` file is invalid. Download it again from Firebase Console

### Issue: "Could not resolve com.google.firebase:firebase-bom"
**Solution**: 
1. Check internet connection
2. Update Gradle: `cd android && ./gradlew wrapper --gradle-version=7.6.3`
3. Sync project

### Issue: "Manifest merger failed"
**Solution**: Check AndroidManifest.xml syntax. The file is already correct, so this shouldn't happen.

## 📊 Package Name Explanation

**Package Name**: `com.ecosnap.app`

This is your app's unique identifier. It MUST match:
- ✅ Firebase Console configuration
- ✅ `android/app/build.gradle` → applicationId
- ✅ `AndroidManifest.xml` → package (auto-added)
- ✅ `MainActivity.kt` → package declaration

**DO NOT CHANGE** unless you:
1. Update it everywhere listed above
2. Create new Firebase Android app with new package name
3. Download new `google-services.json`

## 🎯 Quick Test

After setup, test the app:

```bash
# 1. Connect device or start emulator
adb devices

# 2. Run app
flutter run

# 3. Try these:
# - Sign up new user
# - Take photo (if on real device)
# - View profile
```

## 📱 Creating Emulator (if needed)

```bash
# List available system images
sdkmanager --list | grep system-images

# Install system image (example)
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create emulator
avdmanager create avd -n EcoSnap_Emulator -k "system-images;android-34;google_apis;x86_64"

# Start emulator
emulator -avd EcoSnap_Emulator
```

Or use Android Studio:
**Tools** → **Device Manager** → **Create Device**

## 🎉 You're Ready!

Once you have:
- ✅ Valid `google-services.json` file
- ✅ Firebase services enabled
- ✅ Device/emulator running

Run:
```bash
flutter run
```

And your app should launch! 🚀
