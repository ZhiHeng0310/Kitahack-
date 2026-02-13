import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';
import 'create_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLiked = false;
  bool _isSaved = false;
  int _currentLikes = 0;

  @override
  void initState() {
    super.initState();
    _currentLikes = widget.post.likes;
    _checkIfLiked();
    _checkIfSaved();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Stream of comments for this post
  Stream<QuerySnapshot> commentsStream() {
    return FirebaseFirestore.instance
        .collection('community_posts')
        .doc(widget.post.id)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _addComment() async {
    print("Writing comment to POST ID: ${widget.post.id}");
    if (_commentController.text.trim().isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final userData = await authService.getUserDocument(user!.uid);

    try {
      // Save comment and get the DocumentReference
      final docRef = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .collection('comments')
          .add({
        'userId': user.uid,
        'userName': userData?.displayName ?? 'User',
        'comment': _commentController.text.trim(),
        'timestamp': Timestamp.now(),
      });

      print("Added comment doc ID: ${docRef.id}");

      // Increment comment count
      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.increment(1),
      });

      _commentController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added!'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _checkIfLiked() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    setState(() {
      _isLiked = widget.post.likedBy.contains(userId);
    });
  }

  Future<void> _checkIfSaved() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .doc(widget.post.id)
          .get();

      if (mounted) {
        setState(() {
          _isSaved = doc.exists;
        });
      }
    } catch (e) {
      print('Error checking saved status: $e');
    }
  }

  Future<void> _toggleLike() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    try {
      if (_isLiked) {
        // Unlike
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(widget.post.id)
            .update({
          'likes': FieldValue.increment(-1),
          'likedBy': FieldValue.arrayRemove([userId]),
        });

        setState(() {
          _isLiked = false;
          _currentLikes--;
        });
      } else {
        // Like
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(widget.post.id)
            .update({
          'likes': FieldValue.increment(1),
          'likedBy': FieldValue.arrayUnion([userId]),
        });

        setState(() {
          _isLiked = true;
          _currentLikes++;
        });
      }

      // UPDATE CONTRIBUTION FOR POST OWNER
      await _updateContribution();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _toggleSave() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    try {
      if (_isSaved) {
        // Unsave
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('saved_posts')
            .doc(widget.post.id)
            .delete();

        setState(() => _isSaved = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post removed from saved'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Save
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('saved_posts')
            .doc(widget.post.id)
            .set({
          'postId': widget.post.id,
          'savedAt': Timestamp.now(),
        });

        setState(() => _isSaved = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post saved!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      // UPDATE CONTRIBUTION FOR POST OWNER
      await _updateContribution();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  // CRITICAL: Update contribution based on likes + saves
  Future<void> _updateContribution() async {
    try {
      // Get updated post data
      final postDoc = await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .get();

      if (!postDoc.exists) return;

      final postData = postDoc.data()!;
      final totalLikes = postData['likes'] ?? 0;

      // Count total saves
      final savesSnapshot = await FirebaseFirestore.instance
          .collectionGroup('saved_posts')
          .where('postId', isEqualTo: widget.post.id)
          .get();

      final totalSaves = savesSnapshot.docs.length;

      // Calculate contribution: Every 10 likes+saves = 1 contribution
      final totalEngagement = totalLikes + totalSaves;
      final contribution = (totalEngagement / 10).floor();

      // Get post owner's current stats
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.post.userId)
          .get();

      if (ownerDoc.exists) {
        // Update the user's contribution
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.post.userId)
            .update({
          'stats.itemsExchanged': contribution, // Using itemsExchanged field for Contribution
        });

        print('✅ Contribution updated: $contribution (from $totalEngagement engagements)');
      }
    } catch (e) {
      print('Error updating contribution: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppTheme.primaryGreen : null,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Header
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.post.userId)
                        .get(),
                    builder: (context, snapshot) {
                      String? photoUrl;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        photoUrl = userData['photoUrl'];
                      }

                      return Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primaryGreen,
                            radius: 24,
                            child: photoUrl != null
                                ? ClipOval(
                                    child: NetworkOrFileImage(
                                      imagePath: photoUrl,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    widget.post.userName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _getCategoryLabel(widget.post.category),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.darkGray.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Post Content
                  Text(
                    widget.post.content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Images
                  if (widget.post.imageUrls.isNotEmpty)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: widget.post.imageUrls.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            widget.post.imageUrls[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),

                  // Like & Save Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleLike,
                        icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                        label: Text('$_currentLikes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isLiked ? AppTheme.primaryGreen : AppTheme.lightGray,
                          foregroundColor: _isLiked ? Colors.white : AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _toggleSave,
                        icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isSaved ? AppTheme.primaryGreen : AppTheme.lightGray,
                          foregroundColor: _isSaved ? Colors.white : AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.accentGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Every 10 likes + saves help the author earn 1 Contribution point!',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- COMMENTS SECTION ---
                  const Divider(),
                  const SizedBox(height: 16),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('community_posts')
                        .doc(widget.post.id)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final comments = snapshot.data?.docs ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.comment, color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Comments (${comments.length})',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (comments.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Text('No comments yet. Be the first!'),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final commentData = comments[index].data() as Map<String, dynamic>;
                                return _CommentCard(comment: commentData);
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Comment Input Field
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.lightGray,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _addComment,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'reuse_ideas':
        return 'Reuse Ideas';
      case 'exchange':
        return 'Exchange';
      case 'success':
        return 'Success Story';
      case 'tutorial':
        return 'Tutorial';
      default:
        return 'Post';
    }
  }
}

class _CommentCard extends StatelessWidget {
  final Map<String, dynamic> comment;

  const _CommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    final userId = comment['userId'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture for commenter
          FutureBuilder<DocumentSnapshot>(
            future: userId.isNotEmpty
                ? FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .get()
                : null,
            builder: (context, snapshot) {
              String? photoUrl;
              if (snapshot.hasData && snapshot.data!.exists) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                photoUrl = userData['photoUrl'];
              }

              return CircleAvatar(
                backgroundColor: AppTheme.lightGreen,
                radius: 18,
                child: photoUrl != null
                    ? ClipOval(
                        child: NetworkOrFileImage(
                          imagePath: photoUrl,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        (comment['userName'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment['userName'] ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment['comment'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}