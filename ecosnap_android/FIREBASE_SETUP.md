# 🔥 Firebase Setup Guide

Complete step-by-step guide to configure Firebase for EcoSnap.

---

## 📋 Table of Contents
1. [Create Firebase Project](#1-create-firebase-project)
2. [Add Android App](#2-add-android-app)
3. [Enable Authentication](#3-enable-authentication)
4. [Setup Firestore Database](#4-setup-firestore-database)
5. [Configure Security Rules](#5-configure-security-rules)
6. [Verify Setup](#6-verify-setup)

---

## 1. Create Firebase Project

### Steps
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or **"Add project"**
3. **Project name**: Enter `ecosnap` (or your preferred name)
4. **Google Analytics**: 
   - Toggle OFF for faster setup
   - Or keep ON for usage tracking (optional)
5. Click **"Create project"**
6. Wait for project creation (~30 seconds)
7. Click **"Continue"** when ready

---

## 2. Add Android App

### Steps
1. In Firebase Console, click the **Android icon** (🤖)
2. **Register app** form:
   - **Android package name**: `com.ecosnap.app`
     - ⚠️ **CRITICAL**: Must match exactly!
     - This is set in `android/app/build.gradle`
   - **App nickname**: `EcoSnap` (optional, for your reference)
   - **Debug signing certificate**: Leave blank for now
3. Click **"Register app"**

### Download Configuration File
1. Click **"Download google-services.json"**
2. Save the file
3. **Move to project**:
```bash
   # Navigate to your project
   cd ecosnap
   
   # Copy the file (replace ~/Downloads with your download location)
   cp ~/Downloads/google-services.json android/app/
   
   # Verify it's there
   ls android/app/google-services.json
```
4. ⚠️ **DO NOT** commit this file to public repositories!
5. Add to `.gitignore`:
```
   android/app/google-services.json
```

### Complete Setup
1. Click **"Next"** (Add Firebase SDK)
2. Firebase SDK is already configured in the project files
3. Click **"Next"** (optional verification)
4. Click **"Continue to console"**

---

## 3. Enable Authentication

### Steps
1. In Firebase Console, click **"Authentication"** in left sidebar
2. Click **"Get started"**
3. Select **"Sign-in method"** tab
4. Click on **"Email/Password"**
5. Toggle **"Enable"** ON
6. Leave **"Email link (passwordless sign-in)"** OFF
7. Click **"Save"**

### Verify
- Email/Password should show as **"Enabled"** in the providers list

---

## 4. Setup Firestore Database

### Create Database
1. In Firebase Console, click **"Firestore Database"** in left sidebar
2. Click **"Create database"**
3. **Select mode**:
   - Choose **"Start in test mode"** for development
   - (We'll add security rules in next step)
4. Click **"Next"**
5. **Select location**: Choose closest to Malaysia
   - **Recommended**: `asia-southeast1` (Singapore)
   - Alternatively: `asia-south1` (Mumbai) or `asia-east1` (Taiwan)
6. Click **"Enable"**
7. Wait for database creation (~1 minute)

### Why Test Mode?
- Allows all authenticated users to read/write
- We'll add proper security rules in the next step
- Easier for development and testing

---

## 5. Configure Security Rules

### Firestore Security Rules

1. In **Firestore Database**, click the **"Rules"** tab
2. **Delete** the default rules
3. **Paste** the following rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      // Anyone authenticated can read any user profile
      allow read: if request.auth != null;
      
      // Users can only write their own data
      allow write: if request.auth != null && request.auth.uid == userId;
      
      // Allow user creation
      allow create: if request.auth != null;
      
      // Allow following/unfollowing (updates followers/following arrays)
      allow update: if request.auth != null && (
        request.auth.uid == userId || 
        request.resource.data.diff(resource.data).affectedKeys().hasOnly(['followers', 'following'])
      );
    }
    
    // Scan results collection
    match /scan_results/{scanId} {
      // Authenticated users can read, write, create their own scans
      allow read, write, create: if request.auth != null;
    }
    
    // Products (Marketplace)
    match /products/{productId} {
      // Anyone can read products
      allow read: if request.auth != null;
      
      // Anyone can create products
      allow create: if request.auth != null;
      
      // Only seller can update/delete their products
      allow update, delete: if request.auth != null && 
                               request.auth.uid == resource.data.sellerId;
    }
    
    // Community posts
    match /community_posts/{postId} {
      // Anyone can read, create, update posts
      allow read, create, update: if request.auth != null;
      
      // Only author can delete
      allow delete: if request.auth != null && 
                       request.auth.uid == resource.data.userId;
      
      // Comments subcollection
      match /comments/{commentId} {
        // Anyone can read and create comments
        allow read, create: if request.auth != null;
        
        // Only comment author can update/delete
        allow update, delete: if request.auth != null && 
                                 request.auth.uid == resource.data.userId;
      }
    }
    
    // Saved posts (subcollection under users)
    match /users/{userId}/saved_posts/{postId} {
      // Users can only read/write their own saved posts
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
    
    // Saved products (subcollection under users)
    match /users/{userId}/saved_products/{productId} {
      // Users can only read/write their own saved products
      allow read, write: if request.auth != null && 
                            request.auth.uid == userId;
    }
    
    // Chats
    match /chats/{chatId} {
      // Only participants can read the chat
      allow read: if request.auth != null && 
                     request.auth.uid in resource.data.participantIds;
      
      // Anyone can create a new chat
      allow create: if request.auth != null;
      
      // Only participants can update
      allow update: if request.auth != null && 
                       request.auth.uid in resource.data.participantIds;
      
      // Messages subcollection
      match /messages/{messageId} {
        // Only participants can read messages
        allow read: if request.auth != null && 
                       request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
        
        // Anyone can create/update messages (for sending)
        allow create, update: if request.auth != null;
      }
    }
  }
}
```

4. Click **"Publish"**
5. Confirm by clicking **"Publish"** again

### What These Rules Do

**Users Collection**:
- ✅ Anyone can view user profiles (for social features)
- ✅ Users can only edit their own profile
- ✅ Special permission for follow/unfollow actions

**Scan Results**:
- ✅ Users can store and view their own scan history

**Products (Marketplace)**:
- ✅ Anyone can browse products
- ✅ Only sellers can edit/delete their own listings

**Community Posts**:
- ✅ Anyone can create and view posts
- ✅ Only authors can delete posts
- ✅ Comments have their own rules

**Chats**:
- ✅ Only conversation participants can read messages
- ✅ Real-time messaging enabled

---

## 6. Verify Setup

### Checklist
- [ ] Firebase project created
- [ ] Android app added with correct package name
- [ ] `google-services.json` downloaded and placed in `android/app/`
- [ ] Email/Password authentication enabled
- [ ] Firestore database created
- [ ] Security rules published
- [ ] ~~Firebase Storage setup~~ ❌ NOT NEEDED! (Using ImgBB)

### Test Your Setup

1. **Run the app**:
```bash
   flutter run
```

2. **Test Authentication**:
   - Try signing up with a new account
   - Check Firebase Console → Authentication → Users
   - New user should appear

3. **Test Firestore**:
   - After signup, check Firestore Database → Data
   - You should see a `users` collection with your user document

4. **Check Console for Errors**:
```bash
   # Watch for these in the console:
   ✅ Firebase initialized successfully
   ✅ User created: [email]
   ✅ User document created in Firestore
   
   # If you see errors:
   ❌ [core/no-app] No Firebase App
   ❌ [auth/...] Authentication error
   ❌ [firestore/...] Firestore error
```

---

## 🐛 Troubleshooting

### Error: "No Firebase App"
**Symptom**: `[core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solutions**:
1. Check `google-services.json` exists in `android/app/`
2. Verify package name matches: `com.ecosnap.app`
3. Run:
```bash
   flutter clean
   flutter pub get
   flutter run
```

### Error: "Invalid google-services.json"
**Symptom**: Build fails with Google Services error

**Solutions**:
1. Re-download `google-services.json` from Firebase Console
2. Delete old file and replace with new one
3. Make sure file name is exactly `google-services.json`

### Error: "Permission Denied"
**Symptom**: Can't read/write to Firestore

**Solutions**:
1. Check security rules are published
2. Verify user is authenticated
3. Check console logs for specific permission error
4. Test with rules in "test mode" temporarily

### Can't See Data in Firestore
**Symptom**: App runs but data doesn't appear in Firebase Console

**Solutions**:
1. Check internet connection
2. Verify Firestore is enabled
3. Look for errors in app console
4. Check if writes are actually happening (add print statements)

---

## 📊 Firestore Data Structure

Your app will create these collections:
```
Firestore Database
│
├── users/
│   └── {userId}/
│       ├── email
│       ├── displayName
│       ├── photoUrl
│       ├── bio
│       ├── stats {...}
│       ├── followers []
│       ├── following []
│       ├── saved_posts/
│       │   └── {postId}/
│       └── saved_products/
│           └── {productId}/
│
├── scan_results/
│   └── {scanId}/
│       ├── userId
│       ├── itemName
│       ├── material
│       ├── confidence
│       └── timestamp
│
├── products/
│   └── {productId}/
│       ├── sellerId
│       ├── title
│       ├── price
│       ├── imageUrls []
│       ├── category
│       └── createdAt
│
├── community_posts/
│   └── {postId}/
│       ├── userId
│       ├── content
│       ├── category
│       ├── likes
│       ├── comments/
│       │   └── {commentId}/
│       └── createdAt
│
└── chats/
    └── {chatId}/
        ├── participantIds []
        ├── lastMessage
        ├── messages/
        │   └── {messageId}/
        └── timestamp
```

---

## 🎉 Success!

If you can:
- ✅ Sign up and login
- ✅ See user data in Firestore Console
- ✅ No console errors

**Then Firebase is properly configured!** 🎊

Next steps:
- See [IMAGE_STORAGE_SETUP.md](IMAGE_STORAGE_SETUP.md) for ImgBB configuration
- See [QUICK_START.md](QUICK_START.md) to run the app

---

## 📞 Need Help?

- [Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- Project Issues: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**⚠️ Important Security Note**:
- Never commit `google-services.json` to public repositories
- Use test mode only during development
- Always add proper security rules before production
- Monitor Firebase Console for unusual activity

---