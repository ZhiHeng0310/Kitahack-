# ✨ EcoSnap - Complete Feature Documentation

## 📋 Table of Contents
1. [Authentication](#authentication)
2. [AI Scanning & Classification](#ai-scanning--classification)
3. [Decision Paths](#decision-paths)
4. [Marketplace](#marketplace)
5. [Community Platform](#community-platform)
6. [Messaging System](#messaging-system)
7. [User Profiles & Social](#user-profiles--social)
8. [Impact Tracking](#impact-tracking)

---

## 🔐 Authentication

### Email/Password Authentication
- **Sign Up**: Create new account with email, password, and display name
- **Login**: Secure authentication via Firebase
- **Logout**: Clear session and return to login
- **Profile Creation**: Automatic user document in Firestore

### Security Features
- Password validation (min 6 characters)
- Email format verification
- Duplicate email prevention
- Secure password storage (Firebase handles hashing)

### User Experience
- Auto-navigation after successful signup
- Remember me functionality
- Error messages for invalid credentials
- Loading indicators during authentication

---

## 🤖 AI Scanning & Classification

### Image Input Methods
1. **Camera Capture**: Real-time photo capture
2. **Gallery Selection**: Choose existing photos
3. **Image Preview**: Review before classification

### TensorFlow Lite Classification
- **On-Device Processing**: No data sent to cloud
- **Model**: Custom-trained CNN
- **Input Size**: 224x224 RGB images
- **Output Format**: `ItemType:Material:Condition`
- **Confidence Score**: Accuracy percentage displayed

### Classification Results
Shows:
- Item name (e.g., "Glass Bottle")
- Material type (e.g., "Glass")
- Condition (e.g., "Clean", "Damaged", "Contaminated")
- Reusability status
- Confidence percentage

### Scan History
- Stores all past scans in Firestore
- Timestamp for each scan
- Accessible from profile menu
- Tap to view full scan details

---

## 🔄 Decision Paths

### Path A: Reusable Items
**Triggered when**: Item is clean and in good condition

**Shows**:
1. **Reuse Ideas**
   - Creative transformation suggestions
   - Difficulty level (Easy, Medium, Hard)
   - Step-by-step descriptions
   - Estimated value after transformation

2. **Tutorial Videos**
   - YouTube integration
   - Direct links to DIY tutorials
   - Copyable URLs as fallback

3. **Market Value**
   - Estimated price range (RM X - RM Y)
   - Based on similar marketplace listings

4. **Actions**
   - "List on Marketplace" button
   - "Share with Community" button
   - "Save for Later" option

### Path B: Non-Reusable Items
**Triggered when**: Item is contaminated, broken, or non-reusable

**Shows**:
1. **Recycling Information**
   - Recommended recycling method
   - Material-specific instructions
   - Preparation steps (wash, remove labels, etc.)

2. **Recycling Centers**
   - Static list for Malaysia
   - Name, address, contact info
   - Operating hours
   - Tap to view on map (placeholder)

3. **Impact Tracking**
   - "Mark as Recycled" button
   - Updates user stats

---

## 🛒 Marketplace

### Product Listings

#### Browse Products
- **Grid Layout**: 2-column product cards
- **Category Filtering**: 
  - All
  - Upcycled Home Decor
  - Furniture
  - Garden
  - Art & Crafts
  - Storage Solutions
  - Other
- **Real-time Updates**: StreamBuilder from Firestore
- **Image Preview**: First product image shown

#### Product Details
- **Image Gallery**: PageView with indicators (up to 4 images)
- **Product Info**:
  - Title
  - Price (RM)
  - Category
  - Condition
  - Description
  - Posted date
- **Seller Info**:
  - Profile picture
  - Name (clickable to view profile)
  - Listed date
- **Actions**:
  - "Contact Seller" → Opens chat
  - "Save Product" bookmark icon
  - Back navigation

#### Create Product Listing
- **Form Fields**:
  - Title (min 5 characters)
  - Description (min 20 characters)
  - Price (RM, must be > 0)
  - Category dropdown
  - Condition dropdown (New, Like New, Good, Fair, For Parts)
- **Image Upload**:
  - Up to 4 images
  - Upload to ImgBB
  - Image preview grid
  - Remove image option
- **Validation**: Required fields checked before submission
- **Auto-Stats**: Increments "Items Reused" on creation

### Saved Products
- Access from profile menu
- Lists all bookmarked products
- Tap to view details
- Remove from saved list

### My Listings
- View all user's active listings
- Edit product details
- Mark as sold/delete

---

## 👥 Community Platform

### Post Categories
1. **Reuse Ideas**: Creative transformations
2. **Exchange Requests**: Looking for/offering items
3. **Success Stories**: Completed projects
4. **Tutorial**: Step-by-step guides

### Feed Display
- **Category Tabs**: Filter by post type
- **Post Cards** show:
  - Author profile picture (clickable)
  - Author name (clickable)
  - Post content (preview)
  - Category badge
  - Like count
  - Comment count
  - Post date

### Post Interactions
- **Like**: Heart icon, counts visible
- **Save**: Bookmark for later viewing
- **Comment**: View and add comments

### Create Post
- **Text Input**: Multi-line description
- **Category Selection**: Dropdown menu
- **Image Upload**: Up to 4 images via ImgBB
- **Preview**: See images before posting
- **Auto-Stats**: Increments "Total Posts" on creation

### Post Detail View
- Full post content
- All images in gallery
- Author profile section
- Like/Save buttons
- Comment section:
  - Read all comments
  - Add new comment
  - Author profile pictures shown
- Contribution info tooltip

### Saved Posts
- Access from profile menu
- Lists all bookmarked posts
- Real-time updates
- Tap to view full post

---

## 💬 Messaging System

### Chat List
- All conversations displayed
- Sorted by last message time
- Shows:
  - Other user's profile picture
  - Name
  - Last message preview
  - Timestamp
  - Unread indicator (green dot)
  - Unread count badge

### Individual Chat
- **Header**:
  - Other user's profile picture (tap to view profile)
  - Name
- **Messages**:
  - Sender's profile picture (for received)
  - Message bubbles (green for sent, gray for received)
  - Timestamp
  - Read status ("Seen 5m ago", "Just now", etc.)
  - Product card if shared
- **Input**:
  - Text field
  - Send button
  - Emoji support

### Product Sharing
- Automatically sends product card when contacting seller
- Shows:
  - Product image
  - Title
  - Price
  - Tappable card (future: link to product)

### Real-time Features
- Instant message delivery
- Read receipts with timestamps
- Typing indicators (future enhancement)
- Message notifications

### Unread Badges
- Red dot on marketplace message icon
- Shows count (1-9+)
- Updates in real-time
- Disappears after reading messages

---

## 👤 User Profiles & Social

### View User Profiles
**Access from**:
- Tap username in community posts
- Tap seller name in marketplace
- Tap avatar in chat list
- Search users feature

**Profile Shows**:
1. **Header Section**:
   - Large profile picture
   - Display name
   - Bio (if set)
   - Followers/Following count

2. **Impact Stats**:
   - Items Reused
   - Items Recycled
   - Contribution Score
   - Total Posts

3. **Action Buttons** (for other users):
   - "Follow" / "Following" button
   - "Message" button

4. **Content Tabs**:
   - Community Posts: All posts by user
   - Products: All marketplace listings

### Own Profile
- View personal stats
- Access profile settings
- See scan history
- View saved items
- View my listings

### Edit Profile
- Update display name
- Add/change profile picture (ImgBB upload)
- Write bio (max 150 characters)
- Email shown (read-only)
- Save changes with validation

### Search Users
- Search icon on home screen (top-left)
- Search by:
  - Display name (partial match)
  - Email (partial match)
- Results show:
  - Profile picture
  - Name
  - Bio preview
- Tap to view full profile

### Follow System
- Follow/Unfollow button on profiles
- Followers list (count shown)
- Following list (count shown)
- Updates user document in Firestore
- Real-time count updates

### Contribution Score
**How it works**:
- Every 10 community post likes + saves = 1 contribution point
- Example: 6 likes + 4 saves = 10 total = 1 contribution
- Automatically calculated
- Displayed on profile
- Encourages quality content

---

## 📊 Impact Tracking

### User Statistics

#### Items Reused
- **Counts**: Marketplace products created
- **Increment**: When user lists a product
- **Display**: Profile dashboard

#### Items Recycled
- **Counts**: Recycling center interactions
- **Increment**: When user taps "Find Centers"
- **Display**: Profile dashboard

#### Contribution Score
- **Counts**: (Total likes + saves on posts) ÷ 10
- **Increment**: Auto-calculated from community engagement
- **Display**: Profile dashboard
- **Purpose**: Reward helpful content creators

#### Total Posts
- **Counts**: Community posts created
- **Increment**: When user creates a post
- **Display**: Profile dashboard

### Impact Dashboard
- Located on profile screen
- Visual cards for each metric
- Green eco-themed design
- Icons for each category:
  - ♻️ Recycling icon for Items Reused
  - 🗑️ Delete icon for Recycled
  - 🤝 Volunteer icon for Contribution
  - 📝 Post icon for Total Posts

### Future Enhancements
- CO₂ savings calculation
- Weekly/monthly progress
- Achievement badges
- Leaderboards
- Personal goals

---

## 🎯 Summary

EcoSnap provides a complete ecosystem for sustainable waste management:

1. **Scan** → AI identifies items
2. **Decide** → Reuse or recycle path
3. **Act** → List, share, or recycle
4. **Connect** → Message, follow, engage
5. **Track** → See your impact

All features work together to create a circular economy community focused on reducing waste and promoting sustainability.

---

**For technical implementation details, see [ARCHITECTURE.md](ARCHITECTURE.md)**
