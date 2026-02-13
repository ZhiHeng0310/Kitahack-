import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';
import 'package:ecosnap/screens/home/community/post_detail_screen.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    // We keep the Scaffold here so the background is white/theme-correct
    // and the header is visible.
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Posts'),
        elevation: 0,
      ),
      body: userId.isEmpty
          ? const Center(child: Text('Please log in to see saved posts'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('saved_posts')
                  .orderBy('savedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final savedDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: savedDocs.length,
                  itemBuilder: (context, index) {
                    final data = savedDocs[index].data() as Map<String, dynamic>;
                    final postId = data['postId'] ?? '';

                    // THE LIVE SYNC: This reaches out to the original post
                   return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('community_posts')
                          .doc(postId)
                          .snapshots(),
                      builder: (context, postSnapshot) {
                        if (!postSnapshot.hasData || !postSnapshot.data!.exists) {
                          return const SizedBox.shrink();
                        }

                        final liveData = postSnapshot.data!.data() as Map<String, dynamic>;
                        
                        // CRITICAL: Ensure the ID is included
                        final post = CommunityPost.fromMap({
                          ...liveData,
                          'id': liveData['id'] ?? postId, // Use document ID if field is missing
                        });

                        return SavedPostCard(post: post, userId: userId);
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 80, color: AppTheme.darkGray.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text('No saved posts yet', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class SavedPostCard extends StatelessWidget {
  final CommunityPost post;
  final String userId;

  const SavedPostCard({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with profile picture
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(post.userId)
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
                        radius: 20,
                        child: photoUrl != null
                            ? ClipOval(
                                child: NetworkOrFileImage(
                                  imagePath: photoUrl,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Text(
                                post.userName.isNotEmpty 
                                    ? post.userName[0].toUpperCase() 
                                    : 'U',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(post.createdAt),
                              style: TextStyle(
                                color: AppTheme.darkGray.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(post.category).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryLabel(post.category),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(post.category),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark, color: AppTheme.primaryGreen),
                        onPressed: () => _unsavePost(context),
                        tooltip: 'Unsave',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Content
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              
              // Stats - Now showing live data
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${post.comments}', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _unsavePost(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .doc(post.id)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post unsaved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error unsaving post: $e');
    }
  }
}