# 🚀 Build & Deployment Guide

Complete guide for building, testing, and deploying EcoSnap to production.

---

## 📋 Table of Contents
1. [Development Builds](#development-builds)
2. [Testing](#testing)
3. [Release Builds](#release-builds)
4. [App Signing](#app-signing)
5. [Google Play Store](#google-play-store)
6. [Version Management](#version-management)

---

## 🛠️ Development Builds

### Debug Build

**Purpose**: For development and testing
```bash
# Run on connected device
flutter run

# Run on specific device
flutter devices
flutter run -d <device-id>

# Run with verbose logging
flutter run -v
```

**Features**:
- ✅ Hot reload enabled (press `r`)
- ✅ Hot restart (press `R`)
- ✅ DevTools available (press `d`)
- ✅ Debug logging visible
- ❌ Larger app size
- ❌ Slower performance

### Profile Build

**Purpose**: Performance testing
```bash
# Profile mode
flutter run --profile
```

**Features**:
- ✅ Performance profiling
- ✅ Close to release performance
- ✅ DevTools available
- ❌ No hot reload

### Clean Build

When things go wrong:
```bash
# Clean all build artifacts
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter run
```

---

## 🧪 Testing

### Manual Testing Checklist

Before any release, test:

**Authentication**:
- [ ] Sign up new user
- [ ] Login existing user
- [ ] Logout
- [ ] Error messages display correctly

**Scanning**:
- [ ] Camera capture works
- [ ] Gallery selection works
- [ ] Classification completes
- [ ] Results display correctly
- [ ] Reuse path works
- [ ] Recycle path works

**Marketplace**:
- [ ] Browse products
- [ ] Category filtering
- [ ] Create new listing
- [ ] Upload images
- [ ] View product details
- [ ] Contact seller (opens chat)
- [ ] Save products

**Community**:
- [ ] Browse posts
- [ ] Category tabs work
- [ ] Like posts
- [ ] Comment on posts
- [ ] Create new post
- [ ] Upload images
- [ ] Save posts

**Chat**:
- [ ] Send messages
- [ ] Receive messages
- [ ] Read receipts
- [ ] Unread badges
- [ ] Product sharing

**Profile**:
- [ ] View own profile
- [ ] Edit profile
- [ ] Upload profile picture
- [ ] Update bio
- [ ] View scan history
- [ ] View my listings
- [ ] View saved items

**Social**:
- [ ] Search users
- [ ] View user profiles
- [ ] Follow/unfollow
- [ ] View user's posts
- [ ] View user's products
- [ ] Message users

### Unit Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/auth_service_test.dart

# Run with coverage
flutter test --coverage
```

### Integration Tests
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Performance Testing
```bash
# Build profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Check:
# - Frame rendering time
# - Memory usage
# - Network requests
```

---

## 📦 Release Builds

### Build APK

**Single APK** (all architectures):
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`
Size: ~50-60 MB

**Split APKs** (smaller size, recommended):
```bash
flutter build apk --split-per-abi --release
```
Output:
- `app-armeabi-v7a-release.apk` (~20 MB) - 32-bit ARM
- `app-arm64-v8a-release.apk` (~25 MB) - 64-bit ARM
- `app-x86_64-release.apk` (~30 MB) - x86 64-bit

### Build App Bundle (For Play Store)

**Recommended for Play Store**:
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`
Size: ~30-40 MB

**Why App Bundle?**:
- ✅ Smaller download size for users
- ✅ Play Store handles device-specific APKs
- ✅ Supports Dynamic Delivery
- ✅ Required for new apps on Play Store

### Verify Build
```bash
# Check build folder
ls -lh build/app/outputs/flutter-apk/
ls -lh build/app/outputs/bundle/release/

# Install APK on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Test thoroughly!
```

---

## 🔐 App Signing

### Generate Keystore

**One-time setup**:
```bash
# Navigate to android/app
cd android/app

# Generate keystore (Windows/Mac/Linux)
keytool -genkey -v -keystore ~/ecosnap-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ecosnap

# Follow prompts:
# - Enter keystore password (SAVE THIS!)
# - Enter key password (SAVE THIS!)
# - Enter your details
```

**Save credentials securely**:
```
Keystore file: ~/ecosnap-key.jks
Keystore password: [your_password]
Key alias: ecosnap
Key password: [your_key_password]
```

### Configure Signing

**1. Create key.properties**:

File: `android/key.properties`
```properties
storePassword=[your_keystore_password]
keyPassword=[your_key_password]
keyAlias=ecosnap
storeFile=/Users/yourname/ecosnap-key.jks
```

⚠️ **Never commit this file to Git!**

Add to `.gitignore`:
```
android/key.properties
```

**2. Update app/build.gradle**:

File: `android/app/build.gradle`

Add before `android {`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Add inside `android {`:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        // ... other settings
    }
}
```

### Verify Signing
```bash
# Build signed APK
flutter build apk --release

# Verify signature
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Should show: "jar verified"
```

---

## 🏪 Google Play Store

### Prerequisites

- [ ] Google Play Console account ($25 one-time fee)
- [ ] Signed App Bundle (`.aab`)
- [ ] App screenshots (phone & tablet)
- [ ] Feature graphic (1024 x 500)
- [ ] App icon (512 x 512)
- [ ] Privacy policy URL
- [ ] App description

### Create App Listing

**1. Go to Play Console**:
- [https://play.google.com/console](https://play.google.com/console)
- Click "Create app"

**2. App Details**:
```
App name: EcoSnap
Default language: English
App or game: App
Free or paid: Free
```

**3. Store Listing**:

**Short description** (80 chars):
```
Scan waste, get AI recommendations, reuse items, and join eco community
```

**Full description** (4000 chars):
```
🌱 EcoSnap - Smart Waste Management

Make sustainable decisions about waste with AI-powered scanning and community support.

✨ KEY FEATURES:

🤖 AI-Powered Scanning
- Scan any item with your camera
- On-device AI classification
- Get instant reuse or recycle recommendations
- Works offline for privacy

♻️ Smart Recommendations
- Creative reuse ideas with difficulty ratings
- Video tutorial links
- Market value estimation
- Nearby recycling centers

🛒 Marketplace
- Buy and sell upcycled items
- Direct messaging with sellers
- Save favorite products
- Category filtering

👥 Community
- Share success stories
- Exchange ideas and tips
- Follow inspiring users
- Track your environmental impact

📊 Impact Dashboard
- See items reused
- Track recycling actions
- View contribution score
- Measure CO₂ savings

🔒 Privacy First
- On-device AI (no data sent to cloud)
- Secure authentication
- Private messaging
- Your data stays yours

Join thousands making a difference for the environment! 🌍
```

**4. Screenshots** (minimum 2, max 8):
- Take screenshots of:
  - Login/Signup
  - Scan feature
  - Scan results
  - Marketplace
  - Community
  - Profile stats
- Size: 1080 x 1920 (portrait) or 1920 x 1080 (landscape)

**5. Feature Graphic**:
- Size: 1024 x 500
- High quality banner image
- Shows app name and key feature

**6. App Icon**:
- Size: 512 x 512
- PNG format
- No transparency
- Same as in-app icon

**7. Categorization**:
```
Category: Lifestyle
Tags: sustainability, recycling, waste management, eco-friendly
Content rating: Everyone
```

**8. Contact Details**:
```
Email: your.support@email.com
Website: [optional]
Privacy Policy: [required - host on GitHub Pages or website]
```

### Upload Build

**1. Create Release**:
- Go to "Release" → "Production"
- Click "Create new release"

**2. Upload App Bundle**:
```bash
# Make sure you have the signed bundle
flutter build appbundle --release

# Upload: build/app/outputs/bundle/release/app-release.aab
```

**3. Release Notes**:
```
v1.0.0 - Initial Release

- AI-powered waste scanning
- Reuse and recycle recommendations
- Marketplace for upcycled items
- Community platform
- Real-time messaging
- Impact tracking dashboard
- User profiles and social features
```

**4. Review and Roll Out**:
- Review all information
- Click "Save"
- Click "Review release"
- Click "Start rollout to Production"

### Review Process

- **Timeline**: 1-7 days typically
- **Status**: Check Play Console dashboard
- **Possible outcomes**:
  - ✅ Approved → App goes live!
  - ❌ Rejected → Fix issues and resubmit

---

## 📊 Version Management

### Version Numbering

Format: `MAJOR.MINOR.PATCH+BUILD`

Example: `1.2.3+15`
- `1` = Major version (breaking changes)
- `2` = Minor version (new features)
- `3` = Patch version (bug fixes)
- `15` = Build number (increments with each build)

### Update Version

File: `pubspec.yaml`
```yaml
version: 1.0.0+1
```

**Increment for**:
- Bug fixes: `1.0.0+1` → `1.0.1+2`
- New features: `1.0.1+2` → `1.1.0+3`
- Major changes: `1.1.0+3` → `2.0.0+4`

### Version Code (Android)

**Automatically uses build number**:
```yaml
# pubspec.yaml
version: 1.2.3+15
```

Becomes:
```gradle
// android/app/build.gradle
versionCode 15
versionName "1.2.3"
```

### Release Checklist

Before each release:
- [ ] Update version in `pubspec.yaml`
- [ ] Update CHANGELOG.md
- [ ] Test all features
- [ ] Build signed bundle
- [ ] Test signed build on real device
- [ ] Update Play Store listing
- [ ] Upload new version
- [ ] Write release notes
- [ ] Tag release in Git: `git tag v1.0.0`

---

## 🔍 Post-Release

### Monitor

**Google Play Console**:
- Crashes and ANRs
- User ratings
- Install statistics
- User reviews

**Firebase Console**:
- Authentication stats
- Firestore usage
- Crash reports (if enabled)

### Update App

**For updates**:
```bash
# 1. Make changes
# 2. Update version
# 3. Test thoroughly
# 4. Build bundle
flutter build appbundle --release

# 5. Upload to Play Console
# 6. Roll out update
```

**Types of rollout**:
- **Staged rollout**: 10% → 50% → 100%
- **Full rollout**: 100% immediately
- **Closed testing**: Testers only

---

## 🐛 Common Build Issues

### Issue: Build fails with signing error
```bash
# Check key.properties exists
ls android/key.properties

# Verify paths are correct
# Rebuild
flutter clean
flutter build appbundle --release
```

### Issue: APK installs but crashes
```bash
# Check logs
adb logcat | grep flutter

# Build with debug symbols
flutter build apk --release --verbose
```

### Issue: Play Console rejects app
- Read rejection email carefully
- Fix specific issues mentioned
- Update version number
- Resubmit

---

## ✅ Pre-Launch Checklist

- [ ] All features working
- [ ] No hardcoded secrets
- [ ] Firebase configured for production
- [ ] ImgBB API key set
- [ ] Security rules published
- [ ] Signed with production keystore
- [ ] Version incremented
- [ ] CHANGELOG updated
- [ ] Screenshots ready
- [ ] Store listing complete
- [ ] Privacy policy live
- [ ] Tested on multiple devices
- [ ] Performance acceptable
- [ ] Battery usage reasonable

---

## 📞 Resources

- [Flutter Build Documentation](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Signing Guide](https://developer.android.com/studio/publish/app-signing)

---