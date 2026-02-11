# 🚀 EcoSnap - Quick Start Guide

## What You Have
A complete Flutter Android app for waste management using:
- ✅ Flutter for UI
- ✅ Firebase for backend
- ✅ TensorFlow Lite for on-device AI
- ✅ Clean green & white design
- ✅ All Google tools (no external AI APIs)

---

## ⚡ 5-Minute Setup

### 1. Install Flutter
```bash
# Download from: https://flutter.dev/docs/get-started/install
# Then verify:
flutter doctor
```

### 2. Set Up Firebase
1. Go to https://console.firebase.google.com/
2. Create project → Add Android app
3. Package name: `com.ecosnap.app`
4. Download `google-services.json`
5. Place in: `android/app/google-services.json`
6. Enable:
   - Authentication (Email/Password) ✅
   - Firestore Database ✅
   - ~~Firebase Storage~~ NOT NEEDED! (Using local storage 💾)

**💡 Tip**: See `LOCAL_STORAGE_GUIDE.md` to learn why we skip Firebase Storage!

### 3. Add ML Model
**Quick Option** (for testing):
- Use the included `labels.txt` with a placeholder model
- Download MobileNetV2 from TensorFlow
- Rename to `waste_classifier.tflite`
- Place in `assets/models/`

**Production Option**:
```bash
cd ml_model
pip install -r requirements.txt
python train_model.py
# Copy generated .tflite to assets/models/
```

### 4. Run the App
```bash
cd ecosnap_android
flutter pub get
flutter run
```

---

## 📁 Project Files

### Core Application
```
lib/
├── main.dart                      # App entry
├── models/models.dart             # Data structures
├── services/
│   ├── auth_service.dart          # Firebase Auth
│   ├── database_service.dart      # Firestore
│   └── classifier_service.dart    # TensorFlow Lite
├── screens/
│   ├── auth/                      # Login, Signup
│   └── home/                      # Main app screens
└── utils/constants.dart           # Theme & config
```

### Configuration
- `pubspec.yaml` - Dependencies
- `android/app/build.gradle` - Android config
- `android/app/google-services.json` - Firebase (add this!)

### Documentation
- `README.md` - Full setup guide
- `ARCHITECTURE.md` - Technical details
- `CHECKLIST.md` - Implementation tasks
- `QUICK_START.md` - This file!

### ML Model
- `ml_model/train_model.py` - Train custom model
- `assets/models/labels.txt` - Classification labels
- `assets/models/waste_classifier.tflite` - ML model (add this!)

---

## 🎯 Key Features

### Implemented ✅
1. **Authentication** - Email/password signup and login
2. **AI Scanning** - Camera/gallery image classification
3. **Smart Decision** - Reuse vs Recycle paths
4. **Reuse Ideas** - Creative transformation suggestions
5. **Market Value** - Price estimation for upcycled items
6. **Recycling Info** - Static center data for Malaysia
7. **Marketplace** - Buy/sell upcycled products
8. **Community** - Share ideas and success stories
9. **Impact Tracking** - CO₂ saved, items reused

### To Complete (Optional)
- Product detail pages
- Post creation UI
- Image uploads
- Comments system
- Push notifications

---

## 🎨 Design

### Colors
- Primary: #2D6A4F (Deep Green)
- Light: #52B788 (Light Green)
- Accent: #74C69D (Mint Green)
- Background: #FFFFFF (White)

### Font
- Inter from Google Fonts

### UI Philosophy
- Clean and minimal
- Eco-friendly green theme
- Easy navigation
- Clear call-to-actions

---

## 🔥 Firebase Setup Details

### Firestore Collections
```
users/
  - uid, email, displayName, stats{}

scan_results/
  - userId, itemName, material, confidence, isReusable

products/
  - sellerId, title, price, category, imageUrls[]

community_posts/
  - userId, content, category, likes, likedBy[]
```

### Security Rules
Already provided in README.md - copy them to Firebase Console

---

## 🤖 ML Model Details

### Input
- 224x224 RGB image
- Normalized to [0, 1]

### Output
- 20 classes (defined in labels.txt)
- Format: `ItemType:Material:Condition`
- Example: `Glass Bottle:Glass:Clean`

### Decision Logic
```
if Contaminated/Broken → Recycle Path
if Clean/Good → Reuse Path with ideas
```

---

## 📱 Testing

### Manual Test Flow
1. Sign up new user
2. Take photo of item (or select from gallery)
3. View classification result
4. Check reuse ideas (if reusable)
5. Check recycling centers (if not reusable)
6. Browse marketplace
7. View community posts
8. Check profile stats

### Device Requirements
- Android 5.0 (API 21) or higher
- Camera permission
- Internet connection
- ~100 MB storage

---

## 🚀 Build Commands

```bash
# Debug build
flutter run

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release

# Clean project
flutter clean && flutter pub get
```

---

## ❓ Troubleshooting

### "Firebase not initialized"
→ Check `google-services.json` is in `android/app/`

### "Model not found"
→ Verify `waste_classifier.tflite` is in `assets/models/`

### "Build failed"
→ Run: `flutter clean && flutter pub get`

### "Camera not working"
→ Check AndroidManifest.xml has camera permission

---

## 📊 For Competitions/Demos

### Highlights to Mention
1. **100% Google Tools** - Flutter + Firebase + TensorFlow Lite
2. **On-Device AI** - Privacy-focused, no data sent to cloud
3. **Environmental Impact** - Tracks CO₂ saved
4. **Community Driven** - Share ideas, inspire others
5. **Circular Economy** - Reuse before recycle

### Demo Tips
- Have sample images ready
- Pre-load some community posts
- Show complete scan → decision → action flow
- Highlight the green, clean UI
- Mention scalability with Firebase

---

## 📞 Need Help?

Check these resources:
- Flutter Docs: https://docs.flutter.dev/
- Firebase Docs: https://firebase.google.com/docs
- TensorFlow Lite: https://www.tensorflow.org/lite

---

## 🎉 You're Ready!

Run this to start:
```bash
./setup.sh  # Automated setup
# OR
flutter pub get && flutter run
```

**Happy Coding! 🌱**
