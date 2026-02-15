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
│   │       ├── community_screen.dart          # Community posts
│   │       ├── find_centers_screen.dart       # Find recycling centers 
│   │       ├── home_screen.dart               # Main navigation
│   │       ├── marketplace_screen.dart        # Buy/sell marketplace
│   │       ├── profile_screen.dart            # User profile and settings
│   │       ├── recycle_info_screen.dart       # Recycling centers
│   │       ├── reuse_ideas_screen.dart        # Reuse suggestions
│   │       ├── scan_screen.dart               # Camera & scanning
│   │       ├── scan_result_screen.dart        # Classification results
│   │       └── chat/
│   │       │   ├── chat_list_screen.dart      # List of user conversations
│   │       │   └── chat_screen.dart           # Individual chat messaging screen
│   │       └── community/
│   │       │   ├── create_post_screen.dart    # Create new community post
│   │       │   └── post_detail_screen.dart    # View post details & comments
│   │       └── marketplace/
│   │       │   ├── create_product_screen.dart # Create new marketplace listing
│   │       │   └── product_detail_screen.dart # View product details & contact seller
│   │       └── profile/
│   │       │   ├── edit_profile_screen.dart   # Edit user profile information
│   │       │   ├── my_listing_screen.dart     # User’s marketplace listings
│   │       │   ├── saved_posts_screen.dart    # Bookmarked community posts
│   │       │   ├── saved_products_screen.dart # Bookmarked marketplace products
│   │       │   └── scan_history_screen.dart   # User scan history
│   │       └── user/
│   │           ├── search_users_screen.dart   # Search users by username
│   │           └── user_profile_screen.dart   # View other user's public profile
│   ├── services/
│   │   ├── auth_service.dart       # Firebase Authentication
│   │   ├── chat_service.dart       # Real-time chat (Firestore-based)
│   │   ├── classifier_service.dart # TensorFlow Lite waste classification logic
│   │   ├── database_service.dart   # Firestore CRUD operations
│   │   ├── imgbb_service.dart      # Image upload service (ImgBB API)
│   │   └── user_service.dart       # User profile & user-related operations
│   ├── utils/
│   │   └── constants.dart          # App constants, themes, and static values
│   └── widgets/
│       └── network_or_file_image.dart # Handles both local file & network images
├── assets/
│   ├── models/
│   │   ├── waste_classifier.tflite  # TensorFlow Lite model
│   │   └── labels.txt               # Classification labels
│   └── images/
│       └── app_icon.png (app images)
├── android/
│   └── app/
│       ├── build.gradle
│       ├── google-services.json     # Firebase config
│       └── src/main/AndroidManifest.xml
├── ml_model/
│   ├── train_model.py              # Model training script
│   └── requirements.txt            # Python dependencies for ML training
├── pubspec.yaml            # Flutter dependencies & asset configuration
├── FEATURES.md             # Complete feature documentation
├── FIREBASE_SETUP.md       # Firebase configuration guide
├── IMAGE_STORAGE_SETUP.md  # ImgBB setup guide
├── INSTALLATION.md         # Detailed installation steps
├── PROJECT_STRUCTURE.md    # File organization guide
├── BUILD_DEPLOY.md         # Build and deployment guide
├── TROUBLESHOOTING.md      # Common issues & solutions
├── CHANGELOG.md            # Version history
├── DEMO_GUIDE.md           # Presentation & demo guide
├── ANDROID_SETUP.md        # Android-specific configuration guide
├── ARCHITECTURE.md         # System architecture & design explanation
└── QUICK_START.md          # Quick setup instructions for developers
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
- **Output**: Softmax probabilities for 9 classes
- **Format**: TensorFlow Lite (.tflite)
- **Size**: < 5 MB (optimized for mobile)

### Classification Labels
The model classifies waste into:
1. **Item Type**: Glass Bottle, Plastic Container, etc.
2. **Material**: Glass, Plastic, Paper, etc.
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
- Firebase config in `google-services.json`
- On-device ML (no data sent to external servers)

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
- ✅ Messages

#### Community
- ✅ Post categories (Reuse, Exchange, Success, Tutorial)
- ✅ Like functionality
- ✅ Post creation (UI ready)
- ✅ Category filtering

#### Profile
- ✅ User statistics
- ✅ Impact tracking
- ✅ Badge system
- ✅ Settings menu

### 🔄 Future Enhancements

#### Short-term
- [ ] Video tutorials integration (YouTube API)
- [ ] Push notifications

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
1. Staged rollout (10% → 50% → 100%)
2. Monitor analytics and crashes
3. Iterative improvements

---

## 📈 Success Metrics

### User Engagement
- Daily Active Users (DAU)
- Scan frequency
- Community post engagement
- Marketplace transactions

### Environmental Impact
- Total items reused
- Total contributions made
- Recycling center visits
- User retention rate

### Technical Metrics
- App crash rate < 1%
- ML model accuracy > 70%
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
```

---

## 🎯 Competition/Hackathon Considerations

### Judges Will Look For
- ✅ Innovation (AI-powered waste management)
- ✅ Technical implementation (100% Google tools)
- ✅ User experience (clean, intuitive UI)
- ✅ Social impact (environmental sustainability)
- ✅ Scalability (Firebase backend)
