import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import '../../../services/user_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';
import '../community/post_detail_screen.dart';
import '../marketplace/product_detail_screen.dart';
import '../chat/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _checkFollowStatus();
  }

  Future<void> _loadUser() async {
    final user = await _userService.getUserById(widget.userId);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFollowStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';
    
    if (currentUserId.isNotEmpty && currentUserId != widget.userId) {
      final following = await _userService.isFollowing(currentUserId, widget.userId);
      if (mounted) {
        setState(() => _isFollowing = following);
      }
    }
  }

  Future<void> _toggleFollow() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';

    if (currentUserId.isEmpty) return;

    try {
        await _userService.toggleFollow(currentUserId, widget.userId);
        
        // NEW: Reload user data to get updated follower count
        await _loadUser();
        
        setState(() => _isFollowing = !_isFollowing);

        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text(_isFollowing ? 'Following!' : 'Unfollowed'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
            ),
        );
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

  Future<void> _messageUser() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUser = authService.currentUser;
    final currentUserData = await authService.getUserDocument(currentUser!.uid);

    final chatId = await ChatService().getOrCreateConversation(
      userId1: currentUser.uid,
      userName1: currentUserData?.displayName ?? 'User',
      userId2: widget.userId,
      userName2: _user?.displayName ?? 'User',
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserName: _user?.displayName ?? 'User',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';
    final isOwnProfile = currentUserId == widget.userId;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User not found')),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_user!.displayName ?? 'Profile'),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Profile Header
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Profile Info
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Picture
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryGreen,
                            child: _user!.photoUrl != null
                                ? ClipOval(
                                    child: NetworkOrFileImage(
                                      imagePath: _user!.photoUrl!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    (_user!.displayName ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            _user!.displayName ?? _user!.email.split('@')[0],
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Bio
                          if (_user!.bio != null && _user!.bio!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                _user!.bio!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.darkGray.withOpacity(0.8),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _StatItem(
                                label: 'Followers',
                                value: '${_user!.followers.length}',
                              ),
                              const SizedBox(width: 24),
                              _StatItem(
                                label: 'Following',
                                value: '${_user!.following.length}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Action Buttons
                          if (!isOwnProfile)
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _toggleFollow,
                                    icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                                    label: Text(_isFollowing ? 'Following' : 'Follow'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isFollowing 
                                          ? AppTheme.lightGray 
                                          : AppTheme.primaryGreen,
                                      foregroundColor: _isFollowing 
                                          ? AppTheme.darkGray 
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _messageUser,
                                    icon: const Icon(Icons.message),
                                    label: const Text('Message'),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // Impact Stats
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.eco, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                const Text(
                                  'Impact Score',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _ImpactCard(
                                    icon: Icons.recycling,
                                    value: '${_user!.stats.itemsReused}',
                                    label: 'Items Reused',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ImpactCard(
                                    icon: Icons.delete_outline,
                                    value: '${_user!.stats.itemsRecycled}',
                                    label: 'Recycled',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: _ImpactCard(
                                    icon: Icons.volunteer_activism,
                                    value: '${_user!.stats.itemsExchanged}',
                                    label: 'Contribution',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _ImpactCard(
                                    icon: Icons.post_add,
                                    value: '${_user!.stats.co2Saved.toInt()}',
                                    label: 'Total Posts',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Sticky Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: AppTheme.primaryGreen,
                    unselectedLabelColor: AppTheme.darkGray,
                    indicatorColor: AppTheme.primaryGreen,
                    tabs: const [
                      Tab(text: 'Community Posts'),
                      Tab(text: 'Products'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _CommunityPostsTab(userId: widget.userId),
              _ProductsTab(userId: widget.userId),
            ],
          ),
        ),
      ),
    );
  }
}

// Sticky Tab Delegate
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Stat Item Widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.darkGray.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// Impact Card Widget
class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.darkGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// Community Posts Tab
class _CommunityPostsTab extends StatelessWidget {
  final String userId;

  const _CommunityPostsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CommunityPost>>(
      stream: UserService().getUserPosts(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.post_add,
                  size: 60,
                  color: AppTheme.darkGray.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No community posts yet',
                  style: TextStyle(
                    color: AppTheme.darkGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final posts = snapshot.data!;
        print('✅ Displaying ${posts.length} posts'); // Debug

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(
                  post.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.likes}'),
                    const SizedBox(width: 12),
                    const Icon(Icons.comment, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${post.comments}'),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PostDetailScreen(post: post),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Products Tab
class _ProductsTab extends StatelessWidget {
  final String userId;

  const _ProductsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: UserService().getUserProducts(userId),
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
                  Icons.inventory_2_outlined,
                  size: 60,
                  color: AppTheme.darkGray.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No products listed yet',
                  style: TextStyle(
                    color: AppTheme.darkGray.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        final products = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailScreen(product: product),
                  ),
                );
              },
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: product.imageUrls.isNotEmpty
                          ? NetworkOrFileImage(
                              imagePath: product.imageUrls.first,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image, size: 40),
                            ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'RM ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}