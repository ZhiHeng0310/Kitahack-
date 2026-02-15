# 📝 Changelog

All notable changes to EcoSnap will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned Features
- AR preview for reuse ideas
- Barcode scanning for products
- Multi-language support (Bahasa Malaysia, Chinese)
- Dark mode
- Offline mode with local caching
- Push notifications
- Social media sharing

---

## [2.0.0] - 2025-01-XX

### Added - Social & Communication Features
- **User Profiles** - View and interact with other users
  - Follow/unfollow system
  - Followers and following counts
  - Bio section (150 character limit)
  - Impact stats display
  - User activity feed (posts and products)
  
- **Search Users** - Find friends feature
  - Search by display name or email
  - Partial match support
  - Profile picture in results
  - Tap to view full profile
  
- **Real-time Messaging** - Direct chat system
  - One-on-one conversations
  - Real-time message delivery
  - Read receipts with timestamps ("Seen 5m ago")
  - Product sharing in chats
  - Unread message badges
  - Chat list with latest messages
  
- **Contribution System** - Community engagement scoring
  - Automatic calculation: (likes + saves) ÷ 10
  - Displayed on user profiles
  - Encourages quality content creation

### Changed - Image Storage
- **Switched to ImgBB** from Firebase Storage
  - 100% free (no Firebase upgrade needed)
  - Unlimited storage
  - Permanent URLs
  - Faster uploads with CDN
  
### Changed - Profile System
- **Enhanced Profile Screen**
  - Added bio field
  - Profile picture upload
  - Real-time stats updates
  - Clickable usernames throughout app
  
### Improved - User Experience
- **Navigation**
  - Tap usernames in posts → View profile
  - Tap seller name in marketplace → View profile
  - Tap avatar in chat → View profile
  - Search icon on home screen
  
- **Message Notifications**
  - Red badge on marketplace message icon
  - Shows unread count (1-9+)
  - Real-time updates
  - Disappears after reading
  
- **Profile Updates**
  - Instant reflection after editing
  - No need to logout/login
  - Image changes visible immediately
  
### Fixed
- Profile picture not updating after upload
- Signup screen loading forever
- Edit profile not saving changes
- Followers count not updating immediately
- Community posts not showing in user profiles
- Saved posts not displaying correctly
- Image loading issues (network vs local paths)
- Character encoding in scan history

---

## [1.0.0] - 2025-01-XX

### Added - Core Features
- **Authentication System**
  - Email/password signup
  - Email/password login
  - Logout functionality
  - User profile creation in Firestore
  
- **AI Scanning**
  - Camera integration
  - Gallery image selection
  - On-device TensorFlow Lite classification
  - Confidence scoring
  - Scan history
  
- **Decision Paths**
  - Reusable item path with creative ideas
  - Non-reusable path with recycling info
  - Market value estimation
  - YouTube tutorial integration
  
- **Marketplace**
  - Product listing creation (up to 4 images)
  - Category filtering
  - Product detail view
  - Save products
  - My listings management
  - Seller information display
  
- **Community Platform**
  - Four categories: Reuse Ideas, Exchange, Success Stories, Tutorials
  - Create posts with images
  - Like posts
  - Comment system
  - Save posts
  - Category filtering
  
- **Profile & Stats**
  - Impact dashboard
  - Items Reused counter
  - Items Recycled counter
  - Contribution score
  - Total Posts counter
  - Scan history
  - Saved items
  
- **Recycling Centers**
  - Static list of Malaysia recycling centers
  - Contact information
  - Operating hours
  - Map integration (placeholder)

### Technical
- **Firebase Integration**
  - Firebase Authentication
  - Cloud Firestore
  - Security rules
  
- **Image Handling**
  - Image compression (1024x1024, 85% quality)
  - ImgBB API integration
  - NetworkOrFileImage widget for flexibility
  
- **State Management**
  - Provider for auth state
  - StreamBuilder for real-time data
  
- **UI/UX**
  - Material Design 3
  - Green eco-friendly theme
  - Responsive layouts
  - Loading states
  - Error handling

---

## Version History

| Version | Release Date | Highlights |
|---------|-------------|------------|
| 2.0.0 | 2025-01-XX | Social features, messaging, ImgBB |
| 1.0.0 | 2025-01-XX | Initial release |

---

## Migration Guides

### Upgrading from 1.0.0 to 2.0.0

**Database Changes**:
- Added `bio`, `followers`, `following` fields to user documents
- Added `chats` collection for messaging
- Added subcollections: `users/{id}/saved_products`

**Required Actions**:
1. Update Firestore security rules
2. Get ImgBB API key
3. Update `imgbb_service.dart` with API key
4. Run `flutter pub get` for new dependencies
5. Clean build: `flutter clean && flutter pub get`

**Breaking Changes**:
- Image storage moved from local to ImgBB URLs
- Old local image paths will not work (users need to re-upload)

---

## Contributors

- **Lead Developer** - Initial work and v1.0.0
- **Team Members** - v2.0.0 features

---

## Support

For questions about specific versions or upgrade help:
- Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- Open an issue on GitHub

---