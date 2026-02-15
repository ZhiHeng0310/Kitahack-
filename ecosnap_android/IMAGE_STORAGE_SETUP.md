# 📸 Image Storage Setup - ImgBB Integration

EcoSnap uses **ImgBB** for FREE image hosting instead of Firebase Storage. This means **no paid Firebase plan required**!

---

## 📋 Table of Contents
1. [Why ImgBB?](#why-imgbb)
2. [Get Your API Key](#get-your-api-key)
3. [Configure the App](#configure-the-app)
4. [How It Works](#how-it-works)
5. [Usage Limits](#usage-limits)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Why ImgBB?

### Benefits
- ✅ **100% FREE** - No credit card required
- ✅ **Unlimited Storage** - No storage limits
- ✅ **Permanent URLs** - Images never expire
- ✅ **Fast CDN** - Quick global delivery
- ✅ **No Firebase Upgrade** - Stay on Spark (free) plan
- ✅ **Simple API** - Easy integration

### vs Firebase Storage
| Feature | ImgBB | Firebase Storage |
|---------|-------|------------------|
| Cost | FREE | Requires Blaze plan ($) |
| Storage Limit | Unlimited | 5GB free, then paid |
| Bandwidth | Unlimited | 1GB/day free, then paid |
| Setup | Just API key | Complex config |
| Best For | Small-medium apps | Enterprise apps |

**Perfect for:**
- Hackathons and competitions
- Student projects
- MVP development
- Apps with <1000 users

---

## 🔑 Get Your API Key

### Step-by-Step

#### 1. Visit ImgBB Website
Go to: [https://api.imgbb.com/](https://api.imgbb.com/)

#### 2. Sign Up
- Click **"Get API Key"** button
- Click **"Sign up"**
- Choose one:
  - Sign up with Google
  - Sign up with Facebook
  - Sign up with Email

#### 3. Get Your Key
After signing in:
1. You'll see: **"Your API Key"**
2. Copy the key (looks like: `1234567890abcdef1234567890abcdef`)
3. **Save it somewhere safe!**

#### 4. Key Features
- **Free tier**: Unlimited uploads
- **Rate limit**: Reasonable for app usage
- **Expiration**: Images stored permanently (with free account)
- **Max file size**: 32MB per image

---

## 🔧 Configure the App

### Step 1: Open the Service File

Navigate to:
```
lib/services/imgbb_service.dart
```

### Step 2: Add Your API Key

Find this line (around line 7):
```dart
static const String _apiKey = 'YOUR_IMGBB_API_KEY_HERE';
```

Replace with your actual key:
```dart
static const String _apiKey = '1234567890abcdef1234567890abcdef';
```

### Step 3: Save the File

Save and you're done! 🎉

### ⚠️ Security Note

For production apps, use environment variables instead:
```dart
// Option 1: Use --dart-define
flutter run --dart-define=IMGBB_API_KEY=your_key_here

// Then in code:
static const String _apiKey = String.fromEnvironment('IMGBB_API_KEY');
```
```dart
// Option 2: Use flutter_dotenv package
// .env file:
IMGBB_API_KEY=your_key_here

// In code:
import 'package:flutter_dotenv/flutter_dotenv.dart';
static final String _apiKey = dotenv.env['IMGBB_API_KEY']!;
```

**Don't commit API keys to public repositories!**

---

## 🔄 How It Works

### Image Upload Flow
```
User selects/captures image
         ↓
Read image as bytes
         ↓
Convert to Base64
         ↓
POST to ImgBB API
         ↓
Receive permanent URL
         ↓
Save URL to Firestore
         ↓
Display image from URL
```

### Where Images Are Used

1. **Profile Pictures**
   - `EditProfileScreen` → Upload on selection
   - Stored in user document: `photoUrl` field

2. **Marketplace Products**
   - `CreateProductScreen` → Up to 4 images
   - Stored in product document: `imageUrls` array

3. **Community Posts**
   - `CreatePostScreen` → Up to 4 images
   - Stored in post document: `imageUrls` array

4. **Scan Results**
   - `ScanScreen` → Item photo
   - Stored in scan document: `imagePath` field

### Code Example
```dart
// Upload single image
final imageUrl = await imgbbService.uploadImage(
  File(imagePath),
  'folder_name',
);

// Result: "https://i.ibb.co/abc123/image.jpg"
```

---

## 📊 Usage Limits

### Free Tier Limits
- **Storage**: Unlimited
- **Bandwidth**: Unlimited
- **Uploads**: No daily limit
- **API Calls**: Reasonable rate limiting

### Rate Limiting
ImgBB has some rate limiting to prevent abuse:
- **Normal usage**: No issues
- **Bulk uploads**: Might hit rate limits
- **Solution**: Add small delays between uploads if needed

### Best Practices

#### 1. Image Optimization
```dart
// Already implemented in image pickers:
maxWidth: 1024,
maxHeight: 1024,
imageQuality: 85,  // 85% quality is good balance
```

#### 2. Limit Image Count
```dart
// Maximum 4 images per product/post
final remainingSlots = 4 - _imagePaths.length;
```

#### 3. Show Upload Progress
```dart
// User feedback during upload
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Row(
      children: [
        CircularProgressIndicator(),
        SizedBox(width: 12),
        Text('Uploading images...'),
      ],
    ),
  ),
);
```

---

## 🐛 Troubleshooting

### Error: "Upload failed"

**Symptom**: Images don't upload, error message shown

**Possible Causes & Solutions**:

1. **Invalid API Key**
   - Check if key is correct in `imgbb_service.dart`
   - Re-copy from ImgBB dashboard
   - No extra spaces or quotes

2. **No Internet Connection**
   - Verify device has internet
   - Try uploading again
   - Check phone's WiFi/data

3. **Image Too Large**
   - Max size: 32MB
   - Reduce image quality in picker
   - Already optimized to 1024x1024

4. **Rate Limited**
   - Wait a few seconds
   - Try again
   - Add delay between uploads

### Error: "Image not loading"

**Symptom**: Upload succeeds but image doesn't display

**Solutions**:

1. **Check URL format**
```dart
   // Should start with http:// or https://
   if (imageUrl.startsWith('http')) {
     // Use Image.network()
   }
```

2. **Use NetworkOrFileImage widget**
```dart
   // Already implemented in the app
   NetworkOrFileImage(
     imagePath: imageUrl,
     fit: BoxFit.cover,
   )
```

3. **Check console logs**
   - Look for network errors
   - Check if URL is valid
   - Verify ImgBB API response

### Error: "API key not found"

**Symptom**: Build error or runtime error about missing key

**Solutions**:
1. Make sure you replaced `'YOUR_IMGBB_API_KEY_HERE'`
2. Check for typos in the key
3. Rebuild the app: `flutter clean && flutter run`

---

## 🧪 Testing

### Test Image Upload

1. **Profile Picture Test**:
```
   Login → Profile → Edit → Upload picture → Save
```
   - Should upload to ImgBB
   - URL saved to Firestore
   - Image displays on profile

2. **Product Image Test**:
```
   Marketplace → + → Upload images → Create
```
   - Multiple images upload
   - URLs saved in array
   - Images display in gallery

3. **Console Check**:
```
   ✅ Image uploaded: https://i.ibb.co/...
   ✅ ImgBB upload successful
```

---

## 📈 Monitoring Usage

### Check Your Usage

1. Log in to [ImgBB Dashboard](https://imgbb.com/)
2. View your uploaded images
3. Check storage used (unlimited!)

### Delete Old Images (Optional)

**Note**: ImgBB free tier doesn't support API deletion

To manage images:
1. Go to ImgBB dashboard
2. View your uploads
3. Manually delete if needed

**Tip**: Not necessary for small apps, storage is unlimited!

---

## 🔄 Switching to Firebase Storage Later

If you need to switch to Firebase Storage in the future:

1. **Enable Firebase Storage** in console
2. **Update** `database_service.dart`:
```dart
   // Replace ImgBB calls with Firebase Storage
   final ref = FirebaseStorage.instance.ref().child(path);
   await ref.putFile(imageFile);
   final downloadUrl = await ref.getDownloadURL();
```
3. **Migrate existing images** (script needed)

---

## ✅ Verification Checklist

Before running the app:
- [ ] ImgBB account created
- [ ] API key copied
- [ ] API key added to `imgbb_service.dart`
- [ ] No `YOUR_IMGBB_API_KEY_HERE` in code
- [ ] File saved
- [ ] App rebuilt: `flutter clean && flutter pub get`

---

## 🎉 You're Ready!

Once configured:
- Upload profile pictures ✅
- List products with images ✅
- Share posts with photos ✅
- All images hosted for FREE ✅

Next steps:
- Run the app: `flutter run`
- Test image uploads
- See [QUICK_START.md](QUICK_START.md) for full setup

---

## 📞 Resources

- **ImgBB API Docs**: [https://api.imgbb.com/](https://api.imgbb.com/)
- **ImgBB Dashboard**: [https://imgbb.com/](https://imgbb.com/)
- **Support**: Check their help center

---

## 💡 Pro Tips

1. **Test with small images first** (< 1MB)
2. **Check console logs** for upload status
3. **Keep API key private** (don't commit to Git)
4. **Monitor uploads** in ImgBB dashboard
5. **Optimize images** before upload (already done in code)

---