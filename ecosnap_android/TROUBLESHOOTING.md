# 🔧 Troubleshooting Guide

Common issues and solutions for EcoSnap development.

---

## 📋 Table of Contents
1. [Installation Issues](#installation-issues)
2. [Firebase Issues](#firebase-issues)
3. [Build Issues](#build-issues)
4. [Runtime Issues](#runtime-issues)
5. [Image Upload Issues](#image-upload-issues)
6. [Chat & Messaging Issues](#chat--messaging-issues)
7. [Performance Issues](#performance-issues)
8. [Device-Specific Issues](#device-specific-issues)

---

## 🛠️ Installation Issues

### Flutter Doctor Shows Errors

**Issue**: `flutter doctor` shows red X marks

#### Android toolchain not found
```bash
# Solution: Accept Android licenses
flutter doctor --android-licenses

# Press 'y' for each license
```

#### Android Studio not detected
```bash
# Solution: Set ANDROID_HOME
# Windows
setx ANDROID_HOME "C:\Users\YourName\AppData\Local\Android\Sdk"

# Mac/Linux
export ANDROID_HOME=$HOME/Library/Android/sdk  # Mac
export ANDROID_HOME=$HOME/Android/Sdk          # Linux
```

#### Command-line tools not found
```bash
# Open Android Studio
# Tools → SDK Manager → SDK Tools
# Check "Android SDK Command-line Tools"
# Click Apply
```

### Dependencies Won't Install

**Issue**: `flutter pub get` fails
```bash
# Solution 1: Clean and retry
flutter clean
flutter pub get

# Solution 2: Delete pub cache
flutter pub cache repair

# Solution 3: Update Flutter
flutter upgrade
```

### Git Clone Issues

**Issue**: Permission denied or authentication failed
```bash
# Solution: Use HTTPS instead of SSH
git clone https://github.com/username/ecosnap.git

# Or configure Git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## 🔥 Firebase Issues

### "No Firebase App" Error

**Error**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solutions**:

1. **Check google-services.json exists**:
```bash
   ls android/app/google-services.json
```
   
2. **Verify package name matches**:
   - Firebase Console: `com.ecosnap.app`
   - `android/app/build.gradle`: `applicationId "com.ecosnap.app"`
   
3. **Clean and rebuild**:
```bash
   flutter clean
   rm -rf android/.gradle
   flutter pub get
   flutter run
```

### Firebase Initialization Fails

**Error**: Firebase services not working

**Check**:
```dart
// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Must be awaited!
  runApp(MyApp());
}
```

### Authentication Errors

**Error**: `[auth/email-already-in-use]`
- **Solution**: Email is already registered, use login instead

**Error**: `[auth/invalid-email]`
- **Solution**: Check email format is valid

**Error**: `[auth/weak-password]`
- **Solution**: Password must be at least 6 characters

**Error**: `[auth/user-not-found]`
- **Solution**: User doesn't exist, sign up first

**Error**: `[auth/wrong-password]`
- **Solution**: Incorrect password entered

### Firestore Permission Denied

**Error**: `[firestore/permission-denied]`

**Solutions**:

1. **Check security rules published**:
   - Firebase Console → Firestore → Rules
   - Make sure you clicked "Publish"

2. **Verify user is authenticated**:
```dart
   final user = FirebaseAuth.instance.currentUser;
   print('User: ${user?.email}'); // Should not be null
```

3. **Check rule syntax**:
```javascript
   // Correct
   allow read: if request.auth != null;
   
   // Wrong
   allow read: if request.auth.uid != null;
```

4. **Temporarily test with open rules** (DEVELOPMENT ONLY):
```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;  // ⚠️ INSECURE - TESTING ONLY
       }
     }
   }
```

### Firestore Data Not Appearing

**Issue**: Data saved but doesn't show in app

**Debug steps**:

1. **Check Firebase Console**:
   - Go to Firestore Database → Data
   - Verify documents exist

2. **Check collection name**:
```dart
   // Correct
   .collection('community_posts')
   
   // Wrong (typo)
   .collection('comunity_posts')
```

3. **Add debug logging**:
```dart
   firestore.collection('users').snapshots().listen((snapshot) {
     print('Documents found: ${snapshot.docs.length}');
     for (var doc in snapshot.docs) {
       print('Doc ID: ${doc.id}, Data: ${doc.data()}');
     }
   });
```

---

## 🏗️ Build Issues

### Gradle Build Fails

**Error**: Various Gradle errors

**Solution 1: Clean Gradle cache**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Solution 2: Update Gradle wrapper**:
```bash
cd android
./gradlew wrapper --gradle-version=7.6.3
```

**Solution 3: Invalidate Android Studio cache**:
- Android Studio → File → Invalidate Caches → Invalidate and Restart

### Out of Memory Error

**Error**: `OutOfMemoryError: Java heap space`

**Solution**: Edit `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

### Google Services Error

**Error**: `File google-services.json is missing`

**Solution**:
```bash
# 1. Download from Firebase Console
# 2. Place in android/app/
cp ~/Downloads/google-services.json android/app/

# 3. Verify
ls android/app/google-services.json
```

### MultiDex Error

**Error**: `Cannot fit requested classes in a single dex file`

**Solution**: Already configured, but verify in `android/app/build.gradle`:
```gradle
defaultConfig {
    multiDexEnabled true
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### Build Stuck at "Running Gradle task"

**Issue**: Build hangs indefinitely

**Solutions**:
1. **Check internet connection** (first build downloads dependencies)
2. **Wait longer** (first build can take 5-10 minutes)
3. **Kill and restart**:
```bash
   flutter clean
   flutter run --verbose
```
4. **Clear Gradle cache**:
```bash
   rm -rf ~/.gradle/caches/
```

---

## 🏃 Runtime Issues

### App Crashes on Startup

**Error**: White screen or immediate crash

**Debug**:
```bash
# View logs
adb logcat | grep flutter

# Look for stack traces
adb logcat | grep -A 50 "Fatal Exception"
```

**Common causes**:
1. Firebase not initialized
2. Missing dependencies
3. Null safety violations
4. Invalid image paths

### Camera Not Working

**Error**: Camera doesn't open or crashes

**Solutions**:

1. **Check permissions in AndroidManifest.xml**:
```xml
   <uses-permission android:name="android.permission.CAMERA"/>
```

2. **Request runtime permissions**:
```dart
   // Already handled by image_picker package
```

3. **Test on real device** (emulator cameras are limited)

4. **Check camera availability**:
```dart
   final cameras = await availableCameras();
   print('Cameras found: ${cameras.length}');
```

### Images Not Displaying

**Issue**: Blank spaces where images should be

**Debug**:
```dart
// Add error logging
Image.network(
  imageUrl,
  errorBuilder: (context, error, stackTrace) {
    print('Image error: $error');
    return Icon(Icons.error);
  },
)
```

**Solutions**:

1. **Check URL format**:
```dart
   print('Image URL: $imageUrl');
   // Should start with http:// or https://
```

2. **Verify internet permission**:
```xml
   <uses-permission android:name="android.permission.INTERNET"/>
```

3. **Check ImgBB upload**:
```dart
   final url = await imgbbService.uploadImage(file);
   print('Uploaded URL: $url');
```

4. **Use NetworkOrFileImage widget** (already implemented)

### TensorFlow Lite Model Not Loading

**Error**: Classification fails or crashes

**Solutions**:

1. **Verify model file exists**:
```bash
   ls assets/models/waste_classifier.tflite
   ls assets/models/labels.txt
```

2. **Check pubspec.yaml**:
```yaml
   assets:
     - assets/models/
```

3. **Run flutter pub get**:
```bash
   flutter pub get
```

4. **Check model loading code**:
```dart
   try {
     await classifier.loadModel();
     print('Model loaded successfully');
   } catch (e) {
     print('Model loading failed: $e');
   }
```

---

## 📸 Image Upload Issues

### ImgBB Upload Fails

**Error**: Images don't upload

**Solutions**:

1. **Check API key**:
```dart
   // In imgbb_service.dart
   static const String _apiKey = 'YOUR_KEY_HERE';
   // Make sure it's replaced with actual key
```

2. **Verify internet connection**:
```bash
   adb shell ping -c 3 api.imgbb.com
```

3. **Check image size**:
```dart
   final file = File(imagePath);
   final bytes = await file.length();
   print('Image size: ${bytes / 1024 / 1024} MB'); // Should be < 32 MB
```

4. **Add debug logging**:
```dart
   // In imgbb_service.dart
   print('🔄 Uploading image...');
   final response = await http.post(...);
   print('📡 Response: ${response.statusCode}');
   print('📄 Body: ${response.body}');
```

### Upload Shows Success but Image Doesn't Display

**Issue**: Upload completes but image broken

**Debug**:
```dart
final imageUrl = await imgbbService.uploadImage(file);
print('Received URL: $imageUrl');
print('Starts with http: ${imageUrl.startsWith('http')}');

// Test URL
await canLaunchUrl(Uri.parse(imageUrl));
```

### Images Upload Slowly

**Issue**: Taking too long to upload

**Solutions**:

1. **Already optimized** in image pickers:
```dart
   maxWidth: 1024,
   maxHeight: 1024,
   imageQuality: 85,
```

2. **Reduce quality further** (if needed):
```dart
   imageQuality: 70,  // Lower quality, smaller file
```

3. **Check network speed**:
```bash
   # Test internet speed
   adb shell ping -c 10 google.com
```

---

## 💬 Chat & Messaging Issues

### Messages Not Sending

**Issue**: Send button doesn't work

**Debug**:
```dart
try {
  await chatService.sendMessage(...);
  print('✅ Message sent successfully');
} catch (e) {
  print('❌ Message send failed: $e');
}
```

**Solutions**:

1. **Check Firestore rules**:
```javascript
   match /chats/{chatId}/messages/{messageId} {
     allow create: if request.auth != null;
   }
```

2. **Verify user authenticated**:
```dart
   final user = FirebaseAuth.instance.currentUser;
   if (user == null) {
     print('❌ User not authenticated');
   }
```

### Unread Badge Not Updating

**Issue**: Red dot doesn't disappear after reading

**Debug**:
```dart
// Check if markMessagesAsRead is called
await chatService.markMessagesAsRead(chatId, userId);
print('✅ Marked messages as read');

// Check Firestore
final messages = await firestore
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('isRead', isEqualTo: false)
    .get();
print('Unread messages: ${messages.docs.length}');
```

**Solutions**:

1. **Ensure method is called** in `chat_screen.dart`:
```dart
   @override
   void initState() {
     super.initState();
     _markMessagesAsRead(); // Should be here
   }
```

2. **Check StreamBuilder** in `marketplace_screen.dart` is active

### Read Receipts Not Showing

**Issue**: "Seen" status not displayed

**Solutions**:

1. **Check readAt field** in Firestore:
```dart
   await messageRef.update({
     'isRead': true,
     'readAt': Timestamp.now(), // Must be set
   });
```

2. **Verify _MessageBubble** displays readAt:
```dart
   if (message.readAt != null) {
     Text('Seen ${_formatSeenTime(message.readAt!)}');
   }
```

---

## 🐌 Performance Issues

### App Feels Slow

**Solutions**:

1. **Enable performance overlay**:
```dart
   MaterialApp(
     showPerformanceOverlay: true, // Shows FPS
   )
```

2. **Check for unnecessary rebuilds**:
```dart
   // Use const constructors
   const Text('Hello');
   
   // Use keys for lists
   ListView.builder(
     itemBuilder: (context, index) {
       return MyWidget(key: ValueKey(items[index].id));
     },
   )
```

3. **Optimize images**:
```dart
   // Already done in image pickers
   maxWidth: 1024,
   maxHeight: 1024,
   imageQuality: 85,
```

4. **Use lazy loading**:
```dart
   // Already using StreamBuilder which is lazy
```

### High Battery Usage

**Solutions**:

1. **Limit polling**:
```dart
   // Use StreamBuilder instead of polling
   StreamBuilder<List<Message>>(
     stream: chatService.getMessages(chatId),
     // ...
   )
```

2. **Dispose resources**:
```dart
   @override
   void dispose() {
     controller.dispose();
     subscription.cancel();
     super.dispose();
   }
```

### App Uses Too Much Storage

**Solutions**:

1. **Clear image cache** (add to settings):
```dart
   await DefaultCacheManager().emptyCache();
```

2. **Limit cached images**:
```dart
   Image.network(
     imageUrl,
     cacheHeight: 300, // Limit cache size
   )
```

---

## 📱 Device-Specific Issues

### Works on Emulator but Not Real Device

**Solutions**:

1. **Check Android version**:
   - App requires Android 5.0 (API 21) minimum
   - Verify device meets requirement

2. **Enable USB debugging**:
   - Settings → About Phone
   - Tap "Build Number" 7 times
   - Settings → Developer Options
   - Enable "USB Debugging"

3. **Check device logs**:
```bash
   adb logcat | grep flutter
```

### Different Behavior on Different Devices

**Solutions**:

1. **Test on multiple devices**:
   - Different screen sizes
   - Different Android versions
   - Different manufacturers

2. **Use responsive layouts**:
```dart
   MediaQuery.of(context).size.width
   LayoutBuilder(...)
```

3. **Handle platform differences**:
```dart
   import 'dart:io';
   
   if (Platform.isAndroid) {
     // Android-specific code
   }
```

---

## 🆘 Getting More Help

### Enable Verbose Logging
```bash
# Run with verbose output
flutter run --verbose

# Or in code
debugPrint('Debug message');
print('Console log');
```

### Check Logs
```bash
# View all logs
adb logcat

# Filter Flutter logs
adb logcat | grep flutter

# Filter errors only
adb logcat *:E

# Save logs to file
adb logcat > logs.txt
```

### Report Issues

When reporting issues, include:
1. **Error message** (full stack trace)
2. **Steps to reproduce**
3. **Expected vs actual behavior**
4. **Device info** (model, Android version)
5. **App version**
6. **Screenshots** (if UI issue)

### Useful Commands
```bash
# Check Flutter version
flutter --version

# Check connected devices
flutter devices

# Clear all caches
flutter clean
flutter pub get

# Rebuild everything
flutter clean
rm -rf build/
flutter pub get
flutter run

# Check app size
flutter build apk --analyze-size

# Profile performance
flutter run --profile
```

---

## 📞 Resources

- **Flutter Docs**: [https://docs.flutter.dev/](https://docs.flutter.dev/)
- **Firebase Docs**: [https://firebase.google.com/docs](https://firebase.google.com/docs)
- **Stack Overflow**: [https://stackoverflow.com/questions/tagged/flutter](https://stackoverflow.com/questions/tagged/flutter)
- **Flutter GitHub**: [https://github.com/flutter/flutter/issues](https://github.com/flutter/flutter/issues)

---

## ✅ Quick Fixes Checklist

Before asking for help, try:
- [ ] `flutter clean && flutter pub get`
- [ ] Restart IDE
- [ ] Restart device/emulator
- [ ] Check internet connection
- [ ] Verify Firebase config
- [ ] Check console logs
- [ ] Update Flutter: `flutter upgrade`
- [ ] Read error message carefully
- [ ] Search error on Google/Stack Overflow

---