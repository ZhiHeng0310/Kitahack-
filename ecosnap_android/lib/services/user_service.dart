import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search users by name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _firestore
          .collection('users')
          .get();

      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) {
            final displayName = user.displayName?.toLowerCase() ?? '';
            final email = user.email.toLowerCase();
            final searchQuery = query.toLowerCase();
            
            return displayName.contains(searchQuery) || 
                   email.contains(searchQuery);
          })
          .toList();

      return users;
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Get user's community posts
  Stream<List<CommunityPost>> getUserPosts(String userId) {
    return _firestore
        .collection('community_posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
            print('📋 Found ${snapshot.docs.length} posts for user $userId'); // Debug
            return snapshot.docs.map((doc) {
            final data = doc.data();
            // Ensure the ID is included
            return CommunityPost.fromMap({
                ...data,
                'id': data['id'] ?? doc.id,
            });
            }).toList();
        });
    }

  // Get user's products
  Stream<List<Product>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data()))
            .toList());
  }

  // Follow/Unfollow user
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      final currentUserDoc = _firestore.collection('users').doc(currentUserId);
      final targetUserDoc = _firestore.collection('users').doc(targetUserId);

      final currentUserData = await currentUserDoc.get();
      final following = List<String>.from(currentUserData.data()?['following'] ?? []);

      if (following.contains(targetUserId)) {
        // Unfollow
        await currentUserDoc.update({
          'following': FieldValue.arrayRemove([targetUserId]),
        });
        await targetUserDoc.update({
          'followers': FieldValue.arrayRemove([currentUserId]),
        });
      } else {
        // Follow
        await currentUserDoc.update({
          'following': FieldValue.arrayUnion([targetUserId]),
        });
        await targetUserDoc.update({
          'followers': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      print('Error toggling follow: $e');
      rethrow;
    }
  }

  // Update bio
  Future<void> updateBio(String userId, String bio) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'bio': bio,
      });
    } catch (e) {
      print('Error updating bio: $e');
      rethrow;
    }
  }

  // Check if following
  Future<bool> isFollowing(String currentUserId, String targetUserId) async {
    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      final following = List<String>.from(doc.data()?['following'] ?? []);
      return following.contains(targetUserId);
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }
}