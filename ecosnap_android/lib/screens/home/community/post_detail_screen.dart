import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import 'package:ecosnap/screens/home/community/create_post_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  String _currentUserId = '';
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStatus();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    _currentUserId = authService.currentUser?.uid ?? '';

    if (_currentUserId.isNotEmpty) {
      final savedDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .collection('saved_posts')
          .doc(widget.post.id)
          .get();

      if (mounted) {
        setState(() {
          _isSaved = savedDoc.exists; // ✅ check if document exists
        });
      }
    }
  }


  Future<void> _toggleSave() async {
    if (_currentUserId.isEmpty) return;

    final postId = widget.post.id;
    final savedRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUserId)
        .collection('saved_posts')
        .doc(postId);

    setState(() => _isSaved = !_isSaved);

    try {
      if (_isSaved) {
        // Save
        await savedRef.set({
          'userId': _currentUserId,
          'postId': postId,
          'savedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Unsave
        await savedRef.delete();
      }
    } catch (e) {
      setState(() => _isSaved = !_isSaved);
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



  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userData = await authService.getUserDocument(_currentUserId);

      // ✅ Define safe username BEFORE Firestore map
      String safeUserName = 'User';

      if (userData?.displayName != null &&
          userData!.displayName!.trim().isNotEmpty) {
        safeUserName = userData.displayName!.trim();
      }

      await FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.post.id,
        'userId': _currentUserId,
        'userName': safeUserName,
        'userPhotoUrl': userData?.photoUrl,
        'content': commentText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('community_posts')
          .doc(widget.post.id)
          .update({
        'comments': FieldValue.increment(1),
      });

      _commentController.clear();

      if (mounted) {
        FocusScope.of(context).unfocus();
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


  Future<void> _toggleLike(bool isLiked) async {
    try {
      await DatabaseService().toggleLikePost(
        widget.post.id,
        _currentUserId,
        isLiked,
      );

      // Update contribution stat (every 10 likes/saves)
      if (!isLiked) {
        // User just liked
        final authService = Provider.of<AuthService>(context, listen: false);
        final userData = await authService.getUserDocument(_currentUserId);

        if (userData != null) {
          final totalEngagement = userData.stats.itemsExchanged;
          if ((totalEngagement + 1) % 10 == 0) {
            // Increment contribution
            final updatedStats = userData.stats.copyWith(
              itemsExchanged: totalEngagement + 1,
            );
            await authService.updateUserStats(_currentUserId, updatedStats);
          }
        }
      }
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

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(widget.post.id)
            .delete();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post deleted successfully'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting post: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'reuse_ideas':
        return 'Reuse Idea';
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

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'reuse_ideas':
        return AppTheme.accentGreen;
      case 'exchange':
        return AppTheme.lightGreen;
      case 'success':
        return AppTheme.successGreen;
      case 'tutorial':
        return AppTheme.primaryGreen;
      default:
        return AppTheme.darkGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwnPost = _currentUserId == widget.post.userId;
    final isLiked = widget.post.likedBy.contains(_currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_outline,
              color: _isSaved ? AppTheme.primaryGreen : null,
            ),
            onPressed: _toggleSave,
          ),
          if (isOwnPost)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePostScreen(post: widget.post),
                    ),
                  );
                } else if (value == 'delete') {
                  _deletePost();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: AppTheme.errorRed),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Info
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.primaryGreen,
                              radius: 24,
                              child: Text(
                                (widget.post.userName.isNotEmpty
                                  ? widget.post.userName[0]
                                  : '?')
                                  .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
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
                                    DateFormat('MMM dd, yyyy • h:mm a')
                                        .format(widget.post.createdAt),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.darkGray.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(widget.post.category)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryLabel(widget.post.category),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getCategoryColor(widget.post.category),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Content
                        Text(
                          widget.post.content,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Images
                        if (widget.post.imageUrls.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: widget.post.imageUrls.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(widget.post.imageUrls[index]),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 16),

                        // Actions
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_outline,
                                color: isLiked ? Colors.red : AppTheme.darkGray,
                              ),
                              onPressed: () => _toggleLike(isLiked),
                            ),
                            Text('${widget.post.likes}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.comment_outlined),
                            const SizedBox(width: 4),
                            Text('${widget.post.comments}'),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.share_outlined),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share feature coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  // Comments Section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comments',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('comments')
                              .where('postId', isEqualTo: widget.post.id)
                              .orderBy('timestamp', descending: false)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    'No comments yet. Be the first to comment!',
                                    style: TextStyle(
                                      color: AppTheme.darkGray.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final comments = snapshot.data!.docs;

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index].data()
                                    as Map<String, dynamic>;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: AppTheme.primaryGreen,
                                        radius: 16,
                                        child: Text(
                                          (
                                            (comment['userName'] ?? '').toString().trim().isNotEmpty
                                              ? comment['userName'].toString().trim()[0]
                                              : 'U'
                                          ).toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              comment['content'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
}