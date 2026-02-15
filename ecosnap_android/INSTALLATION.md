# 🛠️ EcoSnap - Complete Installation Guide

Detailed installation instructions for setting up EcoSnap on your development machine.

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Install Flutter](#install-flutter)
3. [Install Android Studio](#install-android-studio)
4. [Setup Android SDK](#setup-android-sdk)
5. [Clone Project](#clone-project)
6. [Install Dependencies](#install-dependencies)
7. [Verify Installation](#verify-installation)

---

## ✅ Prerequisites

### System Requirements

**Operating System:**
- Windows 10/11 (64-bit)
- macOS 10.14 (Mojave) or later
- Linux (64-bit)

**Hardware:**
- At least 8GB RAM (16GB recommended)
- 10GB free disk space
- Internet connection

**Software:**
- Git for version control
- Text editor/IDE (VS Code or Android Studio recommended)

---

## 📱 Install Flutter

### For Windows

1. **Download Flutter SDK**
   - Go to [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
   - Download the latest stable release ZIP file

2. **Extract Flutter**
```
   Extract to: C:\src\flutter
   (or any location WITHOUT spaces or special characters)
```

3. **Add to PATH**
   - Search "Environment Variables" in Windows
   - Edit "Path" variable
   - Add: `C:\src\flutter\bin`
   - Click OK

4. **Verify Installation**
```bash
   flutter --version
   flutter doctor
```

### For macOS

1. **Download Flutter SDK**
```bash
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip
   unzip flutter_macos_3.16.0-stable.zip
```

2. **Add to PATH**
```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Add to shell config permanently
   echo 'export PATH="$PATH:'$HOME'/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
```

3. **Verify Installation**
```bash
   flutter --version
   flutter doctor
```

### For Linux

1. **Download Flutter SDK**
```bash
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
   tar xf flutter_linux_3.16.0-stable.tar.xz
```

2. **Add to PATH**
```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Add to shell config
   echo 'export PATH="$PATH:'$HOME'/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
```

3. **Verify Installation**
```bash
   flutter --version
   flutter doctor
```

---

## 🔧 Install Android Studio

### Download and Install

1. **Download**
   - Go to [https://developer.android.com/studio](https://developer.android.com/studio)
   - Download for your OS
   - File size: ~1GB

2. **Install**
   - **Windows**: Run `.exe` installer
   - **macOS**: Drag to Applications folder
   - **Linux**: Extract and run `studio.sh`

3. **First Launch Setup**
   - Choose "Standard" installation
   - Download Android SDK components
   - Wait for downloads to complete (~2GB)

---

## 📦 Setup Android SDK

### Install Required Components

1. **Open Android Studio**
2. Click **"More Actions"** → **"SDK Manager"**
3. In **"SDK Platforms"** tab, check:
   - ✅ Android 14.0 (API 34) - Latest
   - ✅ Android 5.0 (API 21) - Minimum supported

4. In **"SDK Tools"** tab, check:
   - ✅ Android SDK Build-Tools 34
   - ✅ Android SDK Command-line Tools
   - ✅ Android SDK Platform-Tools
   - ✅ Android Emulator
   - ✅ Intel x86 Emulator Accelerator (if Intel CPU)

5. Click **"Apply"** and wait for downloads

### Set Environment Variables

#### Windows
```
ANDROID_HOME = C:\Users\YourName\AppData\Local\Android\Sdk
Path += %ANDROID_HOME%\platform-tools
Path += %ANDROID_HOME%\tools
Path += %ANDROID_HOME%\tools\bin
```

#### macOS/Linux
```bash
# Add to ~/.zshrc or ~/.bashrc
export ANDROID_HOME=$HOME/Library/Android/sdk  # macOS
export ANDROID_HOME=$HOME/Android/Sdk          # Linux
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

Apply changes:
```bash
source ~/.zshrc  # or ~/.bashrc
```

### Accept Android Licenses
```bash
flutter doctor --android-licenses
```
Type `y` for each license prompt.

---

## 📥 Clone Project

### Using Git
```bash
# Clone the repository
git clone https://github.com/yourusername/ecosnap.git

# Navigate to project
cd ecosnap
```

### Or Download ZIP

1. Go to repository URL
2. Click **"Code"** → **"Download ZIP"**
3. Extract to your preferred location
4. Open terminal in extracted folder

---

## 📦 Install Dependencies

### 1. Get Flutter Packages
```bash
# Install all dependencies from pubspec.yaml
flutter pub get
```

### 2. Verify pubspec.yaml

Make sure these dependencies are present:
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  
  # State Management
  provider: ^6.1.1
  
  # UI
  image_picker: ^1.0.5
  intl: ^0.18.1
  
  # ML
  tflite_flutter: ^0.10.3
  image: ^4.1.3
  
  # Networking
  http: ^1.1.0
  url_launcher: ^6.2.1
  
  # Other
  uuid: ^4.2.2
  path_provider: ^2.1.1
```

### 3. Clean Build (if needed)
```bash
flutter clean
flutter pub get
```

---

## ✅ Verify Installation

### Run Flutter Doctor
```bash
flutter doctor -v
```

**Expected Output** (all should have ✓):
```
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, 3.16.0)
[✓] Android toolchain - develop for Android devices
[✓] Android Studio (version 2023.1)
[✓] VS Code (version 1.85) [optional]
[✓] Connected device (1 available)
[✓] Network resources
```

### Common Issues

#### ❌ Android toolchain issues
**Solution:**
```bash
flutter doctor --android-licenses
```

#### ❌ Android Studio not detected
**Solution:** Make sure ANDROID_HOME is set correctly

#### ❌ No devices available
**Solution:** 
- Connect physical device with USB debugging enabled
- OR create Android emulator (see below)

---

## 📱 Create Android Emulator (Optional)

### Using Android Studio

1. **Open Android Studio**
2. Click **"More Actions"** → **"Virtual Device Manager"**
3. Click **"Create Device"**
4. Select **"Pixel 6"** (recommended)
5. Click **"Next"**
6. Select **System Image**: "Tiramisu" (API 34)
7. Click **"Next"** → **"Finish"**

### Using Command Line
```bash
# List available system images
sdkmanager --list | grep system-images

# Install system image
sdkmanager "system-images;android-34;google_apis;x86_64"

# Create AVD
avdmanager create avd -n EcoSnap_Emulator \
  -k "system-images;android-34;google_apis;x86_64" \
  -d "pixel_6"

# Start emulator
emulator -avd EcoSnap_Emulator
```

---

## 🎯 Test Installation

### 1. Connect Device

**Physical Device:**
```bash
# Enable USB debugging on phone
# Connect via USB
adb devices
```

**Emulator:**
```bash
# Start emulator
emulator -avd EcoSnap_Emulator

# Or use Android Studio GUI
```

### 2. Run Test App
```bash
# Navigate to project
cd ecosnap

# Run app
flutter run

# Or specify device
flutter devices
flutter run -d <device-id>
```

### 3. Expected Result

App should:
- ✅ Build successfully
- ✅ Install on device/emulator
- ✅ Launch and show login screen
- ✅ No red error screen

---

## 🔧 IDE Setup (Optional but Recommended)

### VS Code

1. **Install VS Code**: [https://code.visualstudio.com/](https://code.visualstudio.com/)

2. **Install Extensions**:
   - Flutter (by Dart Code)
   - Dart (by Dart Code)
   - Flutter Widget Snippets
   - Awesome Flutter Snippets

3. **Open Project**:
```bash
   code ecosnap
```

4. **Run App**: Press `F5` or click "Run" → "Start Debugging"

### Android Studio

1. **Open Project**: File → Open → Select ecosnap folder

2. **Install Flutter Plugin**:
   - File → Settings → Plugins
   - Search "Flutter"
   - Install Flutter plugin
   - Restart Android Studio

3. **Run App**: Click green play button ▶️

---

## 🐛 Troubleshooting

### Flutter doctor shows warnings

**Issue**: Command line tools not found
```bash
# Download from Android Studio SDK Manager
# Or via command line:
sdkmanager "cmdline-tools;latest"
```

### ADB not recognized

**Solution**: Add platform-tools to PATH
```bash
# Windows
set PATH=%PATH%;C:\Users\YourName\AppData\Local\Android\Sdk\platform-tools

# Mac/Linux
export PATH=$PATH:$ANDROID_HOME/platform-tools
```

### Gradle build fails

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Out of memory error

**Solution**: Edit `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m
```

---

## ✅ Installation Complete!

You should now have:
- ✅ Flutter SDK installed
- ✅ Android Studio setup
- ✅ Project dependencies installed
- ✅ Device/emulator ready
- ✅ Able to run `flutter doctor` successfully

Next steps:
1. **Firebase Setup**: See [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
2. **ImgBB Setup**: See [IMAGE_STORAGE_SETUP.md](IMAGE_STORAGE_SETUP.md)
3. **Run App**: See [QUICK_START.md](QUICK_START.md)

---

## 📞 Need Help?

- **Flutter Issues**: [https://docs.flutter.dev/](https://docs.flutter.dev/)
- **Android Studio**: [https://developer.android.com/studio/intro](https://developer.android.com/studio/intro)
- **Project Issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---