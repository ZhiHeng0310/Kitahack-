import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import 'package:ecosnap/screens/home/community/post_detail_screen.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<CommunityPost> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedPosts();
  }

  Future<void> _fetchSavedPosts() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      // Get saved post IDs from user's subcollection
      final savedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .orderBy('savedAt', descending: true)
          .get();

      final savedPostIds = savedSnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['postId'] as String)
          .toList();

      if (savedPostIds.isEmpty) {
        setState(() {
          _posts = [];
          _isLoading = false;
        });
        return;
      }

      // Firestore whereIn query batching (max 10)
      List<CommunityPost> allPosts = [];
      for (var i = 0; i < savedPostIds.length; i += 10) {
        final batchIds = savedPostIds.sublist(
          i,
          (i + 10) > savedPostIds.length ? savedPostIds.length : i + 10,
        );

        final postSnapshot = await FirebaseFirestore.instance
            .collection('community_posts')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        final batchPosts = postSnapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        allPosts.addAll(batchPosts);
      }

      // Maintain the order of saved posts
      allPosts.sort(
        (a, b) => savedPostIds.indexOf(a.id).compareTo(savedPostIds.indexOf(b.id)),
      );

      setState(() {
        _posts = allPosts;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching saved posts: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _unsavePost(String postId) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('saved_posts')
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _posts.removeWhere((post) => post.id == postId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post unsaved'), duration: Duration(seconds: 2)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error unsaving post: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Posts')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_outline, size: 80, color: AppTheme.darkGray.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text('No saved posts yet', style: TextStyle(fontSize: 16, color: AppTheme.darkGray.withOpacity(0.7))),
                      const SizedBox(height: 8),
                      const Text('Save community posts to view them here', textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _posts.length,
                  itemBuilder: (context, index) {
                    final post = _posts[index];
                    final avatarLetter = post.userName.isNotEmpty ? post.userName[0].toUpperCase() : '?';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                        ),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryGreen,
                                    radius: 20,
                                    child: Text(avatarLetter, style: const TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(post.userName.isNotEmpty ? post.userName : 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(DateFormat('MMM dd, yyyy').format(post.createdAt), style: TextStyle(fontSize: 12, color: AppTheme.darkGray.withOpacity(0.6))),
                                      ],
                                    ),
                                  ),
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
                                    onPressed: () => _unsavePost(post.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(post.content, style: const TextStyle(fontSize: 14), maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.favorite, size: 16, color: AppTheme.darkGray.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text('${post.likes}', style: TextStyle(fontSize: 12, color: AppTheme.darkGray.withOpacity(0.7))),
                                  const SizedBox(width: 16),
                                  Icon(Icons.comment, size: 16, color: AppTheme.darkGray.withOpacity(0.6)),
                                  const SizedBox(width: 4),
                                  Text('${post.comments}', style: TextStyle(fontSize: 12, color: AppTheme.darkGray.withOpacity(0.7))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}