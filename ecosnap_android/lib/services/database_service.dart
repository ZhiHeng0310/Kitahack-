import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SCAN RESULTS
  
  // Save scan result
  Future<void> saveScanResult(ScanResult result) async {
    try {
      await _firestore
          .collection('scan_results')
          .doc(result.id)
          .set(result.toMap());
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
          .set(product.toMap());
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
          .update({'isActive': false});
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // COMMUNITY POSTS

  // Create community post
  Future<void> createCommunityPost(CommunityPost post) async {
    try {
      await _firestore
          .collection('community_posts')
          .doc(post.id)
          .set(post.toMap());
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

  // LOCAL STORAGE (No Firebase Storage needed!)

  // Save image to local device storage
  Future<String> saveImageLocally(File imageFile, String fileName) async {
    try {
      // Get app's document directory
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/$fileName';
      
      // Copy file to app directory
      final savedImage = await imageFile.copy(imagePath);
      
      // Return local file path
      return savedImage.path;
    } catch (e) {
      print('Error saving image locally: $e');
      rethrow;
    }
  }

  // Save multiple images locally
  Future<List<String>> saveImagesLocally(List<File> imageFiles, String folderName) async {
    final paths = <String>[];
    
    for (int i = 0; i < imageFiles.length; i++) {
      final fileName = '$folderName/image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final path = await saveImageLocally(imageFiles[i], fileName);
      paths.add(path);
    }
    
    return paths;
  }

  // Delete local image
  Future<void> deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting local image: $e');
    }
  }
  
  // Get local image as File
  File getLocalImage(String path) {
    return File(path);
  }
}
