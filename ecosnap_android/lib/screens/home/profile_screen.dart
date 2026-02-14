import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../widgets/network_or_file_image.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/scan_history_screen.dart';
import 'profile/my_listing_screen.dart';
import 'profile/saved_products_screen.dart';
import 'package:flutter/services.dart';
import 'profile/saved_posts_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    
    // Force reload the current user
    await authService.currentUser?.reload();
    
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final userData = await authService.getUserDocument(userId);
      if (mounted) {
        setState(() {
          _userModel = userData;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
    }
  }

  Future<void> _openHelpSupport() async {
  // Show dialog with information
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Help & Support'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Any inquiries can be filled in the Google Form:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final uri = Uri.parse(AppConstants.helpSupportUrl);
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open link. Please copy the URL.'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not open link. Please copy the URL.'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: Text(
              AppConstants.helpSupportUrl,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                decoration: TextDecoration.underline,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Copy to clipboard
                  Clipboard.setData(ClipboardData(text: AppConstants.helpSupportUrl));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Link copied to clipboard!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                },
                child: const Text('Copy Link'),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _userModel?.stats ?? UserStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(userModel: _userModel),
                ),
              );
              
              // Reload data if profile was updated
              if (result == true) {
                await _loadUserData();
                setState(() {}); // Force rebuild
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(userModel: _userModel),
                    ),
                  ).then((_) => _loadUserData());
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryGreen,
                  child: _userModel?.photoUrl != null && _userModel!.photoUrl!.isNotEmpty
                      ? ClipOval(
                          child: _userModel!.photoUrl!.startsWith('http')
                              ? Image.network(
                                  _userModel!.photoUrl!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                )
                              : Image.file(
                                  File(_userModel!.photoUrl!),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                ),
                        )
                      : _buildDefaultAvatar(),
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                _userModel?.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              
              Text(
                _userModel?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.darkGray.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              // Impact Stats
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.eco, color: AppTheme.primaryGreen),
                          const SizedBox(width: 8),
                          const Text(
                            'Your Impact',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.recycling,
                              value: '${stats.itemsReused}',
                              label: 'Items Reused',
                              color: AppTheme.lightGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.delete_outline,
                              value: '${stats.itemsRecycled}',
                              label: 'Recycled',
                              color: AppTheme.accentGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.volunteer_activism,
                              value: '${stats.itemsExchanged}',
                              label: 'Contribution',
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.post_add,
                              value: '${stats.co2Saved.toInt()}',
                              label: 'Total Posts',
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Badges
              if (stats.badges.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars, color: AppTheme.accentGreen),
                            const SizedBox(width: 8),
                            const Text(
                              'Badges',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: stats.badges.map((badge) {
                            return Chip(
                              avatar: const Icon(Icons.emoji_events, size: 16),
                              label: Text(badge),
                              backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Menu Items
              Card(
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.history,
                      title: 'Scan History',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ScanHistoryScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.store,
                      title: 'My Listings',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MyListingsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.bookmark,
                      title: 'Saved Posts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>  SavedPostsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.shopping_bag,
                      title: 'Saved Products',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedProductsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: _openHelpSupport,
                    ),
                    const Divider(height: 1),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationIcon: const Icon(Icons.eco, size: 40, color: AppTheme.primaryGreen),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final name = _userModel?.displayName?.trim() ?? '';

    final initial = name.isNotEmpty
        ? name[0].toUpperCase()
        : 'U';

    return Text(
      initial,
      style: const TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.darkGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class ContributionProgress extends StatelessWidget {
  final int totalEngagement; // itemsExchanged

  const ContributionProgress({super.key, required this.totalEngagement});

  @override
  Widget build(BuildContext context) {
    // Calculate progress (0 to 9)
    int currentProgress = totalEngagement % 10;
    // Calculate percentage for the progress bar (0.0 to 1.0)
    double percent = currentProgress / 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Contribution Progress",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "$currentProgress / 10 actions",
              style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Perform ${10 - currentProgress} more actions to earn +1 Contribution!",
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}