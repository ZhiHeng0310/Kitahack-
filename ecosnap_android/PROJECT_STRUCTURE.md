# 📂 EcoSnap - Project Structure Guide

Comprehensive guide to understanding the project's file organization and architecture.

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Root Directory](#root-directory)
3. [lib/ Directory](#lib-directory)
4. [android/ Directory](#android-directory)
5. [assets/ Directory](#assets-directory)
6. [Key Files Explained](#key-files-explained)

---

## 🌳 Overview
```
ecosnap/
├── android/              # Android-specific configuration
├── assets/               # Static assets (images, models)
├── lib/                  # Flutter application code (main source)
├── test/                 # Unit and widget tests
├── .gitignore           # Git ignore rules
├── pubspec.yaml         # Flutter dependencies
├── README.md            # Main documentation
└── [Other docs]         # Documentation files
```

---

## 📁 Root Directory

### Configuration Files
```
ecosnap/
├── .gitignore                    # Files to ignore in Git
├── .metadata                     # Flutter project metadata
├── pubspec.yaml                  # Dependencies & assets
├── pubspec.lock                  # Locked dependency versions
└── analysis_options.yaml         # Linter rules (optional)
```

#### pubspec.yaml
**Purpose**: Defines app dependencies and assets

**Key sections**:
```yaml
name: ecosnap
description: Smart Waste Management App
version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  # ... other dependencies

assets:
  - assets/models/
  - assets/images/
```

### Documentation Files
```
ecosnap/
├── README.md                    # Main overview
├── QUICK_START.md               # Fast setup guide
├── INSTALLATION.md              # Detailed install steps
├── FIREBASE_SETUP.md            # Firebase configuration
├── IMAGE_STORAGE_SETUP.md       # ImgBB setup
├── ARCHITECTURE.md              # Technical architecture
├── FEATURES.md                  # Feature documentation
├── PROJECT_STRUCTURE.md         # This file
├── BUILD_DEPLOY.md              # Build & deployment
├── TROUBLESHOOTING.md           # Common issues
├── ANDROID_SETUP.md             # Preparation for android
├── CONTRIBUTING.md              # Contribution guide
├── CHANGELOG.md                 # Version history
├── DEMO_GUIDE.md                # Presentation guide
└── PITCH_POINTS.md              # Competition highlights
```

---

## 📱 lib/ Directory

### Main Structure
```
lib/
├── main.dart                    # App entry point
├── models/
│   └── models.dart              # Data models
├── screens/                     # UI screens
│   ├── auth/                    # Authentication
│   └── home/                    # Main app features
├── services/                    # Business logic
├── widgets/                     # Reusable UI components
└── utils/                       # Utilities & constants
```

### Detailed Breakdown

#### 1. main.dart
**Purpose**: Application entry point

**Key code**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}
```

**Responsibilities**:
- Initialize Firebase
- Setup providers
- Configure app theme
- Handle auth state routing

---

#### 2. models/models.dart
**Purpose**: Data structures for the entire app

**Models included**:
```dart
// User data
class UserModel { ... }
class UserStats { ... }

// Scanning
class ScanResult { ... }
class ReuseIdea { ... }

// Marketplace
class Product { ... }

// Community
class CommunityPost { ... }

// Chat
class ChatMessage { ... }
class ChatConversation { ... }
```

**Usage**:
```dart
import 'package:ecosnap/models/models.dart';

final user = UserModel(
  uid: '123',
  email: 'user@example.com',
  // ...
);
```

---

#### 3. screens/ Directory
```
screens/
├── auth/
│   ├── login_screen.dart
│   └── signup_screen.dart
└── home/
    ├── community_screen.dart          # Community posts feed
    ├── find_centers_screen.dart       # Find nearby recycling centers (map/list)
    ├── home_screen.dart               # Main navigation & bottom navigation controller
    ├── marketplace_screen.dart        # Buy/sell marketplace listings
    ├── profile_screen.dart            # User profile overview & settings
    ├── recycle_info_screen.dart       # Recycling guides & material information
    ├── reuse_ideas_screen.dart        # Reuse suggestions based on scanned items
    ├── scan_screen.dart               # Camera & waste scanning interface
    ├── scan_result_screen.dart        # Classification results & reuse options
    ├── marketplace/
    │   ├── create_product_screen.dart
    │   └── product_detail_screen.dart
    ├── community/
    │   ├── create_post_screen.dart
    │   └── post_detail_screen.dart
    ├── chat/
    │   ├── chat_screen.dart
    │   └── chat_list_screen.dart
    ├── user/
    │   ├── search_users_screen.dart
    │   └── user_profile_screen.dart
    └── profile/
        ├── profile_screen.dart
        ├── edit_profile_screen.dart
        ├── my_listings_screen.dart
        ├── saved_items_screen.dart
        └── scan_history_screen.dart
```

##### Screen Responsibilities

**Auth Screens**:
- `login_screen.dart`: Email/password login form
- `signup_screen.dart`: New user registration

**Home Screen**:
- `home_screen.dart`: Bottom navigation (Scan, Marketplace, Community, Profile)

**Scanning**:
- `scan_screen.dart`: Camera capture, gallery picker, AI classification
- `scan_result_screen.dart`: Display classification results
- `reuse_ideas_screen.dart`: Show reuse suggestions from scan
- `search_reuse_ideas_screen.dart`: Manual search for ideas
- `find_centers_screen.dart`: Recycling center locations

**Marketplace**:
- `marketplace_screen.dart`: Browse products, category filter
- `create_product_screen.dart`: List new product, image upload
- `product_detail_screen.dart`: Full product view, contact seller
- `saved_products_screen.dart`: Bookmarked products

**Community**:
- `community_screen.dart`: Browse posts by category
- `create_post_screen.dart`: Create new post, image upload
- `post_detail_screen.dart`: Full post, comments, likes

**Chat**:
- `chat_list_screen.dart`: All conversations
- `chat_screen.dart`: Individual chat, messages, read receipts

**User**:
- `search_users_screen.dart`: Find friends by name
- `user_profile_screen.dart`: View other user's profile

**Profile**:
- `profile_screen.dart`: Own profile, stats dashboard
- `edit_profile_screen.dart`: Update name, bio, picture
- `my_listings_screen.dart`: User's marketplace products
- `saved_items_screen.dart`: Saved community posts
- `scan_history_screen.dart`: Past scans

---

#### 4. services/ Directory
```
services/
├── auth_service.dart           # Firebase Authentication
├── database_service.dart       # Firestore operations
├── imgbb_service.dart         # Image hosting
├── chat_service.dart          # Messaging
├── user_service.dart          # User interactions
└── classifier_service.dart    # TensorFlow Lite ML
```

---

#### 5. widgets/ Directory
```
widgets/
└── network_or_file_image.dart    # Reusable image widget
```

**Purpose**: Handles both network URLs (ImgBB) and local file paths

**Usage**:
```dart
NetworkOrFileImage(
  imagePath: imageUrl, // http://... or file://...
  fit: BoxFit.cover,
  width: 100,
  height: 100,
  borderRadius: BorderRadius.circular(8),
)
```

**Features**:
- Automatic detection (network vs file)
- Loading indicators
- Error handling
- Fallback placeholders

---

#### 6. utils/ Directory
```
utils/
└── constants.dart              # App-wide constants
```

**Contains**:
```dart
// Theme colors
class AppTheme {
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF52B788);
  // ...
}

// App constants
class AppConstants {
  static const String appName = 'EcoSnap';
  static const String helpFormUrl = 'https://forms.gle/...';
  
  // Reuse ideas data
  static const Map<String, List<Map<String, dynamic>>> reuseIdeas = {
    'Glass Bottle': [...],
    'Plastic Container': [...],
    // ...
  };
  
  // Recycling centers
  static const List<Map<String, String>> recyclingCenters = [
    {
      'name': 'KL Recycling Hub',
      'address': '...',
      // ...
    },
  ];
}
```

---

## 🤖 android/ Directory
```
android/
├── app/
│   ├── build.gradle                  # App-level config
│   ├── google-services.json          # Firebase config (YOU ADD THIS)
│   ├── proguard-rules.pro           # Code obfuscation
│   └── src/main/
│       ├── AndroidManifest.xml       # App permissions
│       ├── kotlin/com/ecosnap/app/
│       │   └── MainActivity.kt       # Main activity
│       └── res/
│           ├── values/
│           │   └── styles.xml        # Light theme
│           ├── values-night/
│           │   └── styles.xml        # Dark theme
│           ├── drawable/
│           │   └── launch_background.xml
│           ├── drawable-v21/
│           │   └── launch_background.xml
│           └── mipmap-*/
│               └── ic_launcher.png   # App icons
├── gradle/wrapper/
│   └── gradle-wrapper.properties    # Gradle version
├── build.gradle                      # Project-level config
├── gradle.properties                 # Gradle settings
└── settings.gradle                   # Gradle modules
```

### Key Android Files

#### AndroidManifest.xml
**Purpose**: App configuration and permissions

**Key sections**:
```xml
<manifest>
  <!-- Permissions -->
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.CAMERA"/>
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
  
  <application
    android:label="EcoSnap"
    android:icon="@mipmap/ic_launcher">
    
    <activity android:name=".MainActivity">
      <!-- Launch intent -->
    </activity>
  </application>
</manifest>
```

#### app/build.gradle
**Purpose**: App-level build configuration

**Key sections**:
```gradle
android {
    namespace "com.ecosnap.app"
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.ecosnap.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}

apply plugin: 'com.google.gms.google-services'
```

---

## 🎨 assets/ Directory
```
assets/
├── models/
│   ├── waste_classifier.tflite     # TensorFlow Lite model
│   └── labels.txt                   # Classification labels
└── images/
    └── (app images if any)
```

### TensorFlow Lite Model

**waste_classifier.tflite**:
- Input: 224x224 RGB image
- Output: Classification probabilities
- Size: < 5 MB optimized

**labels.txt**:
```
Glass Bottle:Glass:Clean
Plastic Container:Plastic:Clean
Cardboard Box:Cardboard:Clean
...
```

---

## 🔑 Key Files Explained

### 1. main.dart
**Location**: `lib/main.dart`
**Lines**: ~150
**Purpose**: App initialization

**Flow**:
```
main() → Initialize Firebase → Setup Providers → Run App
         ↓
MyApp → MaterialApp → Theme Config
         ↓
StreamBuilder(authStateChanges)
         ↓
User logged in? → HomeScreen : LoginScreen
```

### 2. home_screen.dart
**Location**: `lib/screens/home/home_screen.dart`
**Purpose**: Main navigation

**Structure**:
```dart
BottomNavigationBar [
  0: ScanScreen,
  1: MarketplaceScreen,
  2: CommunityScreen,
  3: ProfileScreen
]
```

### 3. scan_screen.dart
**Location**: `lib/screens/home/scan_screen.dart`
**Key features**:
- Camera integration
- Gallery picker
- TensorFlow Lite classification
- Result navigation

### 4. marketplace_screen.dart
**Location**: `lib/screens/home/marketplace/marketplace_screen.dart`
**Key features**:
- Product grid
- Category filtering
- Real-time updates (StreamBuilder)
- Message icon with badge

### 5. community_screen.dart
**Location**: `lib/screens/home/community/community_screen.dart`
**Key features**:
- Tabbed interface
- Post cards
- Like functionality
- Category filtering

### 6. profile_screen.dart
**Location**: `lib/screens/home/profile/profile_screen.dart`
**Key features**:
- Impact dashboard
- Menu items
- User stats
- Settings access

---

## 📊 File Size Reference

| File/Directory | Approx Size | Purpose |
|----------------|-------------|---------|
| `lib/` | ~50 KB | Application code |
| `android/` | ~500 KB | Android config |
| `assets/models/` | ~5 MB | ML model |
| `build/` | ~100 MB | Build artifacts (not in Git) |
| Total (with dependencies) | ~300 MB | Full project |

---

## 🔄 Data Flow Example

### Scan Flow
```
User taps camera
    ↓
scan_screen.dart → Opens camera
    ↓
User captures image
    ↓
classifier_service.dart → Processes with TFLite
    ↓
Result returned
    ↓
scan_result_screen.dart → Displays result
    ↓
If reusable → reuse_ideas_screen.dart
If not → find_centers_screen.dart
```

### Marketplace Flow
```
User creates product
    ↓
create_product_screen.dart → Form input
    ↓
imgbb_service.dart → Upload images
    ↓
database_service.dart → Save to Firestore
    ↓
marketplace_screen.dart → Shows in feed
    ↓
User taps product
    ↓
product_detail_screen.dart → Full details
    ↓
User taps "Contact Seller"
    ↓
chat_service.dart → Create/get conversation
    ↓
chat_screen.dart → Chat interface
```

---

## 🎯 Navigation Map
```
LoginScreen / SignupScreen
         ↓ (after auth)
    HomeScreen (Bottom Nav)
         ↓
    ┌────┴────┬────────────┬──────────┐
    ↓         ↓            ↓          ↓
ScanScreen  Marketplace  Community  Profile
    ↓         ↓            ↓          ↓
ScanResult Products     Posts      Settings
    ↓         ↓            ↓          ↓
ReuseIdeas Details      Detail    MyListings
    ↓         ↓            ↓          ↓
           Chat        Comments   History
```

---

## 📝 Adding New Features

### Where to add code:

**New Screen**:
```
lib/screens/[category]/[feature]_screen.dart
```

**New Service**:
```
lib/services/[feature]_service.dart
```

**New Model**:
Add to `lib/models/models.dart`

**New Widget**:
```
lib/widgets/[widget_name].dart
```

**New Assets**:
```
assets/[category]/[file]
```
Then update `pubspec.yaml`:
```yaml
assets:
  - assets/[category]/
```

---

## ✅ File Organization Best Practices

1. **One screen per file**: Don't combine multiple screens
2. **Group related features**: Use subdirectories (marketplace/, community/)
3. **Reusable widgets**: Extract to widgets/ directory
4. **Services are singletons**: One instance handles all operations
5. **Models in one file**: Easier imports and maintenance
6. **Constants centralized**: One source of truth in utils/constants.dart

---

## 📞 Need Help?

- **Can't find a file?** Use your IDE's search (Ctrl+P in VS Code)
- **Unclear structure?** Check [ARCHITECTURE.md](ARCHITECTURE.md)

---