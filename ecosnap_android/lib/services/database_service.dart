import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';
import 'imgbb_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImgBBService _imgbbService = ImgBBService();

  // STORAGE - Upload to ImgBB instead of local/Firebase
  Future<String> uploadImage(File imageFile, String path) async {
    try {
      // Upload to ImgBB and get permanent URL
      final imageUrl = await _imgbbService.uploadImage(imageFile);
      return imageUrl;
    } catch (e) {
      print('❌ Error uploading image: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadImages(List<File> imageFiles, String folderPath) async {
    try {
      final urls = await _imgbbService.uploadImages(imageFiles);
      return urls;
    } catch (e) {
      print('❌ Error uploading images: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    await _imgbbService.deleteImage(imageUrl);
  }

  // SCAN RESULTS
  // Save scan result
  Future<void> saveScanResult(ScanResult result) async {
    try {
      await _firestore.collection('scan_results').add({
        ...result.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving scan result: $e');
      rethrow;
    }
  }


  // Get user's scan history
  Stream<List<ScanResult>> getUserScanHistory(String userId) {
    return _firestore
        .collection('scan_results')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanResult.fromMap(doc.data()))
            .toList());
  }

  // MARKETPLACE

  // Create product listing
  Future<void> createProduct(Product product) async {
  try {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap(), SetOptions(merge: false)); // Ensure full write
    
    print('Product created successfully: ${product.id}');
  } catch (e) {
    print('Error creating product: $e');
    rethrow;
    }
  }

  // Get all active products
  Stream<List<Product>> getActiveProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data()))
            .toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
  return _firestore
      .collection('products')
      .where('category', isEqualTo: category)
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Product.fromMap(doc.data()))
          .toList());
    }

  // Get user's products
  Stream<List<Product>> getUserProducts(String userId) {
    return _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromMap(doc.data()))
            .toList());
  }

  // Update product
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .update(updates);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .delete();
      print('✅ Product deleted: $productId');
    } catch (e) {
      print('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // COMMUNITY POSTS

  // Create community post
  Future<void> createCommunityPost(CommunityPost post) async {
    try {
      final data = post.toMap();

      // 🔒 Sanitize critical fields
      data['userName'] =
          (data['userName'] ?? '').toString().trim().isEmpty
              ? 'Anonymous'
              : data['userName'].toString().trim();

      data['imageUrls'] =
          data['imageUrls'] is List ? data['imageUrls'] : [];

      data['createdAt'] =
          data['createdAt'] ?? FieldValue.serverTimestamp();

      await _firestore
          .collection('community_posts')
          .doc(post.id)
          .set(data);
    } catch (e) {
      print('Error creating community post: $e');
      rethrow;
    }
  }

  // Get community posts by category
  Stream<List<CommunityPost>> getCommunityPosts(String category) {
    return _firestore
        .collection('community_posts')
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data()))
            .toList());
  }

  // Get all community posts
  Stream<List<CommunityPost>> getAllCommunityPosts() {
    return _firestore
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data()))
            .toList());
  }

  // Like/unlike post
  Future<void> toggleLikePost(String postId, String userId, bool isLiked) async {
    try {
      final postRef = _firestore.collection('community_posts').doc(postId);
      
      if (isLiked) {
        // Unlike
        await postRef.update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });
      } else {
        // Like
        await postRef.update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  // ADD these helper methods:

  Future<void> incrementItemsReused(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats.itemsReused': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing items reused: $e');
    }
  }

  Future<void> incrementRecycled(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats.itemsRecycled': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing recycled: $e');
    }
  }

  Future<void> incrementTotalPosts(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'stats.co2Saved': FieldValue.increment(1), // Using co2Saved field for Total Posts
      });
    } catch (e) {
      print('Error incrementing total posts: $e');
      }
    }

  Future<void> updateContribution(String userId, int totalLikesAndSaves) async {
    try {
      final contribution = (totalLikesAndSaves / 10).floor();
      await _firestore.collection('users').doc(userId).update({
        'stats.itemsExchanged': contribution, // Using itemsExchanged field for Contribution
      });
    } catch (e) {
      print('Error updating contribution: $e');
      }
  }
}
