import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail(String email, String password, String displayName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // CRITICAL: Update display name in Firebase Auth FIRST
      await credential.user?.updateDisplayName(displayName);
      
      // Reload user to get updated profile
      await credential.user?.reload();
      
      // Get fresh user data
      final updatedUser = _auth.currentUser;

      if (updatedUser != null) {
        // Now create user document with the updated display name
        await _createUserDocument(updatedUser);
      }

      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user document exists, create if not
      if (credential.user != null) {
        final userDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (!userDoc.exists) {
          await _createUserDocument(credential.user!);
        }
      }
      
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> _createUserDocument(User user) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName ?? user.email!.split('@')[0], // Use displayName from Firebase Auth
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      stats: UserStats(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userModel.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      } else {
        // Create user document if it doesn't exist
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.uid == uid) {
          await _createUserDocument(currentUser);
          final newDoc = await _firestore.collection('users').doc(uid).get();
          if (newDoc.exists) {
            return UserModel.fromMap(newDoc.data()!);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  Future<void> updateUserStats(String uid, UserStats stats) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({'stats': stats.toMap()}, SetOptions(merge: true)); // CHANGED: Use set with merge
    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }

  // NEW: Update user profile
  Future<void> updateUserProfile(String uid, {String? displayName, String? photoUrl}) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      if (updates.isNotEmpty) {
        // Update Firestore
        await _firestore
            .collection('users')
            .doc(uid)
            .set(updates, SetOptions(merge: true));
            
        // Update Firebase Auth profile
        final user = _auth.currentUser;
        if (user != null) {
          // Update in separate calls to avoid type issues
          if (displayName != null) {
            await user.updateDisplayName(displayName);
          }
          if (photoUrl != null) {
            await user.updatePhotoURL(photoUrl);
          }
          
          // Reload to get fresh data
          await user.reload();
        }
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password.';
        default:
          return 'Authentication error: ${e.message}';
      }
    }
    return 'An unexpected error occurred.';
  }
}