# 🌱 EcoSnap - Project Overview

## 📱 Application Architecture

### Tech Stack (100% Google Tools)
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Suite
  - Authentication: Firebase Auth
  - Database: Cloud Firestore
  - Storage: Firebase Storage
  - Analytics: Firebase Analytics
- **AI/ML**: TensorFlow Lite (On-device)
- **State Management**: Provider
- **Navigation**: Built-in Flutter Navigation

---

## 🏗️ Project Structure

```
ecosnap_android/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/
│   │   └── models.dart           # Data models (User, Product, Post, etc.)
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   └── home/
│   │       ├── home_screen.dart         # Main navigation
│   │       ├── scan_screen.dart         # Camera & scanning
│   │       ├── scan_result_screen.dart  # Classification results
│   │       ├── reuse_ideas_screen.dart  # Reuse suggestions
│   │       ├── recycle_info_screen.dart # Recycling centers
│   │       ├── marketplace_screen.dart  # Buy/sell marketplace
│   │       ├── community_screen.dart    # Community posts
│   │       └── profile_screen.dart      # User profile & stats
│   ├── services/
│   │   ├── auth_service.dart       # Firebase Authentication
│   │   ├── database_service.dart   # Firestore operations
│   │   └── classifier_service.dart # TensorFlow Lite ML
│   ├── widgets/
│   │   └── (reusable UI components)
│   └── utils/
│       └── constants.dart          # App constants & theme
├── assets/
│   ├── models/
│   │   ├── waste_classifier.tflite  # TensorFlow Lite model
│   │   └── labels.txt               # Classification labels
│   └── images/
│       └── (app images)
├── android/
│   └── app/
│       ├── build.gradle
│       ├── google-services.json     # Firebase config
│       └── src/main/AndroidManifest.xml
├── ml_model/
│   ├── train_model.py              # Model training script
│   └── requirements.txt            # Python dependencies
├── pubspec.yaml                    # Flutter dependencies
├── README.md                       # Setup guide
└── setup.sh                        # Quick setup script
```

---

## 🔄 Data Flow

### 1. Image Scanning Flow
```
User taps camera → Capture image → Send to TFLite classifier
                                          ↓
                                    Classification result
                                          ↓
                               ┌──────────┴──────────┐
                               ↓                      ↓
                        Reusable?                 Not reusable?
                               ↓                      ↓
                    Show reuse ideas          Show recycle info
                    + Market value            + Centers
                    + Sell option
```

### 2. Firebase Data Structure

```
Firestore Collections:
├── users/
│   └── {userId}/
│       ├── email
│       ├── displayName
│       ├── stats (reused, recycled, co2Saved)
│       └── badges[]
│
├── scan_results/
│   └── {scanId}/
│       ├── userId
│       ├── itemName
│       ├── material
│       ├── confidence
│       ├── isReusable
│       ├── reuseIdeas[]
│       └── timestamp
│
├── products/
│   └── {productId}/
│       ├── sellerId
│       ├── title
│       ├── price
│       ├── imageUrls[]
│       ├── category
│       └── isActive
│
└── community_posts/
    └── {postId}/
        ├── userId
        ├── content
        ├── category
        ├── imageUrls[]
        ├── likes
        └── likedBy[]
```

---

## 🎨 UI/UX Design System

### Color Palette
```dart
Primary Green:   #2D6A4F
Light Green:     #52B788
Accent Green:    #74C69D
Background:      #FFFFFF
Light Gray:      #F8F9FA
Text Dark:       #495057
Success:         #40916C
Warning:         #FF9800
Error:           #DC3545
```

### Typography
- **Font Family**: Inter (Google Fonts)
- **Headings**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Captions**: Regular, 11-13px

### Components
- **Cards**: 16px border radius, 2px elevation
- **Buttons**: 12px border radius, prominent primary action
- **Input Fields**: 12px border radius, subtle borders
- **Icons**: Material Design icons

---

## 🤖 Machine Learning Model

### Model Specifications
- **Architecture**: Convolutional Neural Network (CNN)
- **Input Size**: 224x224x3 (RGB image)
- **Output**: Softmax probabilities for 20 classes
- **Format**: TensorFlow Lite (.tflite)
- **Size**: < 5 MB (optimized for mobile)

### Classification Labels
The model classifies waste into:
1. **Item Type**: Glass Bottle, Plastic Container, etc.
2. **Material**: Glass, Plastic, Metal, Paper, etc.
3. **Condition**: Clean, Damaged, Contaminated, etc.

Format: `ItemType:Material:Condition`

Example: `Glass Bottle:Glass:Clean`

### Decision Logic
```dart
if (condition == "Contaminated" || condition == "Broken") {
    → Not Reusable → Show Recycling Path
} else if (condition == "Clean" || condition == "Good") {
    → Reusable → Show Reuse Ideas + Market Value
}
```

---

## 🔐 Security Considerations

### Firebase Security Rules

#### Firestore
- Users can only read/write their own data
- Community posts are readable by all authenticated users
- Products visible to all, editable only by owner

#### Storage
- Images organized by userId
- Read access for authenticated users
- Write access only to own folders

### App Security
- No API keys hardcoded in source
- Firebase config in `google-services.json`
- On-device ML (no data sent to external servers)
- Email verification recommended for production

---

## 📊 Features Breakdown

### ✅ Completed Features

#### Authentication
- ✅ Email/password signup
- ✅ Email/password login
- ✅ Logout
- ✅ User profile creation

#### Scanning & Analysis
- ✅ Camera integration
- ✅ Gallery image selection
- ✅ On-device classification (TFLite)
- ✅ Confidence scoring
- ✅ Scan history

#### Decision Paths
- ✅ Reusable path with ideas
- ✅ Non-reusable path with recycling info
- ✅ Market value estimation
- ✅ Static recycling center data

#### Marketplace
- ✅ Product listings
- ✅ Category filtering
- ✅ Product creation (UI ready)
- ✅ Seller information

#### Community
- ✅ Post categories (Reuse, Exchange, Success, Tutorial)
- ✅ Like functionality
- ✅ Post creation (UI ready)
- ✅ Category filtering

#### Profile
- ✅ User statistics
- ✅ Impact tracking (CO₂ saved)
- ✅ Badge system
- ✅ Settings menu

### 🔄 Future Enhancements

#### Short-term
- [ ] Video tutorials integration (YouTube API)
- [ ] In-app messaging for marketplace
- [ ] Push notifications
- [ ] Image upload for posts/products
- [ ] Comments on community posts

#### Medium-term
- [ ] Advanced search & filters
- [ ] Location-based recycling centers (Google Maps)
- [ ] QR code sharing
- [ ] Offline mode with local storage
- [ ] Multi-language support

#### Long-term
- [ ] AR preview for reuse ideas
- [ ] Gamification & challenges
- [ ] Corporate partnerships
- [ ] Carbon credit system
- [ ] Social media integration

---

## 🚀 Deployment Strategy

### Development Phase
1. Local testing on emulators
2. Firebase test environment
3. Internal testing with team

### Beta Phase
1. Closed beta via Firebase App Distribution
2. Collect user feedback
3. Fix bugs and optimize

### Production Phase
1. Google Play Store submission
2. Staged rollout (10% → 50% → 100%)
3. Monitor analytics and crashes
4. Iterative improvements

---

## 📈 Success Metrics

### User Engagement
- Daily Active Users (DAU)
- Scan frequency
- Community post engagement
- Marketplace transactions

### Environmental Impact
- Total items reused
- Total CO₂ saved
- Recycling center visits
- User retention rate

### Technical Metrics
- App crash rate < 1%
- ML model accuracy > 80%
- Average response time < 2s
- Firebase costs within budget

---

## 🛠️ Development Workflow

### Git Workflow
```
main (production)
  └── develop (staging)
       ├── feature/auth
       ├── feature/scanning
       ├── feature/marketplace
       └── feature/community
```

### Testing Strategy
1. Unit tests for services
2. Widget tests for UI components
3. Integration tests for flows
4. Manual testing checklist

### Code Quality
- Follow Flutter style guide
- Use linter (flutter_lints)
- Code reviews before merge
- Documentation for complex logic

---

## 💡 Technical Decisions

### Why Flutter?
- Single codebase for Android & iOS
- Fast development with hot reload
- Rich widget library
- Strong community support

### Why Firebase?
- Seamless Google integration
- Scalable backend
- Real-time database
- Free tier for development

### Why TensorFlow Lite?
- On-device inference (privacy)
- Fast predictions (< 100ms)
- No internet required
- Official Google tool

---

## 📝 Notes for Developers

### Before Starting
1. Install Flutter SDK
2. Set up Android Studio
3. Create Firebase project
4. Download google-services.json

### Development Tips
1. Use `flutter run` with hot reload
2. Test on real devices for camera/ML
3. Monitor Firebase console for errors
4. Keep dependencies updated

### Common Commands
```bash
# Run app
flutter run

# Build APK
flutter build apk

# Run tests
flutter test

# Clean build
flutter clean

# Get dependencies
flutter pub get
```

---

## 🎯 Competition/Hackathon Considerations

### Judges Will Look For
- ✅ Innovation (AI-powered waste management)
- ✅ Technical implementation (100% Google tools)
- ✅ User experience (clean, intuitive UI)
- ✅ Social impact (environmental sustainability)
- ✅ Scalability (Firebase backend)

### Demo Preparation
1. Pre-loaded test data in Firebase
2. Sample images for scanning
3. Smooth navigation flow
4. Highlight key features:
   - On-device ML classification
   - Decision path logic
   - Community engagement
   - Impact tracking

### Presentation Points
- Problem: Waste management and sustainability
- Solution: AI-powered app for reuse/recycle decisions
- Tech Stack: 100% Google tools (Flutter + Firebase + TFLite)
- Impact: Reduce waste, promote circular economy
- Future: Scale to larger communities, partnerships

---

**Last Updated**: 2025
**Version**: 1.0.0
**License**: Educational/Competition Use
