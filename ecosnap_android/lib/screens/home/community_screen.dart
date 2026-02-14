import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import '../../widgets/network_or_file_image.dart';
import 'community/create_post_screen.dart';
import 'community/post_detail_screen.dart';
import 'user/user_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _selectedCategory = 'all';

  final Map<String, String> _categories = {
    'all': 'All Posts',
    'reuse_ideas': 'Reuse Ideas',
    'exchange': 'Exchange Requests',
    'success': 'Success Stories',
    'tutorial': 'Tutorials & Tips',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreatePostScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs
          Container(
            height: 50,
            color: AppTheme.backgroundWhite,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories.keys.elementAt(index);
                final label = _categories[category]!;
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: AppTheme.backgroundWhite,
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Posts List
          Expanded(
            child: StreamBuilder<List<CommunityPost>>(
              stream: _selectedCategory == 'all'
                  ? _dbService.getAllCommunityPosts()
                  : _dbService.getCommunityPosts(_selectedCategory),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 80,
                          color: AppTheme.darkGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreatePostScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Post'),
                        ),
                      ],
                    ),
                  );
                }
                
                final posts = snapshot.data!;
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return _PostCard(post: posts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
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
                                post.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserProfileScreen(userId: post.userId),
                                  ),
                                );
                              },
                              child: Text(
                                post.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(post.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.darkGray.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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

              // Stats (live likes and comments)
              Row(
                children: [
                  const Icon(Icons.favorite, size: 16, color: AppTheme.errorRed),
                  const SizedBox(width: 4),
                  Text('${post.likes}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 16),
                  const Icon(Icons.comment, size: 16, color: AppTheme.primaryGreen),
                  const SizedBox(width: 4),

                  // LIVE comment count
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('community_posts')
                        .doc(post.id)
                        .collection('comments')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final commentCount = snapshot.hasData ? snapshot.data!.docs.length : post.comments;
                      return Text('$commentCount', style: const TextStyle(fontSize: 12));
                    },
                  ),
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
}
