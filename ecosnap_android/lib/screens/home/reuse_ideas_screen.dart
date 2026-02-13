import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../widgets/network_or_file_image.dart';
import 'package:flutter/services.dart';
import 'package:ecosnap/screens/home/community/create_post_screen.dart';

class ReuseIdeasScreen extends StatelessWidget {
  final ScanResult scanResult;

  const ReuseIdeasScreen({super.key, required this.scanResult});

  Future<void> _openYouTube(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ideas = scanResult.reuseIdeas ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reuse Ideas'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Image
            Container(
              height: 200,
              color: Colors.grey[200],
              child: scanResult.imagePath.isNotEmpty
                  ? NetworkOrFileImage(
                      imagePath: scanResult.imagePath,
                      fit: BoxFit.cover,
                      height: 200,
                    )
                  : const Icon(Icons.image, size: 60, color: Colors.grey),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Info
                  Text(
                    scanResult.itemName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Material: ${scanResult.material} • Condition: ${scanResult.condition}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Ideas Count
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, color: AppTheme.accentGreen),
                      const SizedBox(width: 8),
                      Text(
                        '${ideas.length} Creative Reuse Ideas',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ideas List
                  if (ideas.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 60,
                              color: AppTheme.darkGray.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No specific ideas found for this item',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.darkGray.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...ideas.map((idea) => _IdeaCard(
                      idea: idea,
                      onTutorialTap: () {
                        // Get YouTube URL from constants
                        final itemKey = AppConstants.reuseIdeas.keys.firstWhere(
                          (key) => scanResult.itemName.toLowerCase().contains(key.toLowerCase()),
                          orElse: () => '',
                        );
                        
                        if (itemKey.isNotEmpty) {
                          final allIdeas = AppConstants.reuseIdeas[itemKey]!;
                          final matchingIdea = allIdeas.firstWhere(
                            (i) => i['title'] == idea.title,
                            orElse: () => {'youtubeUrl': 'https://www.youtube.com/results?search_query=${idea.title}+diy'},
                          );
                          _openYouTube(context, matchingIdea['youtubeUrl']);
                        }
                      },
                    )),
                  
                  const SizedBox(height: 24),
                  
                  // Call to Action
                  Card(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.share,
                            color: AppTheme.primaryGreen,
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ready to Transform?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Share your creation with the community and inspire others!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to create post screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CreatePostScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.people),
                            label: const Text('Share with Community'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  final ReuseIdea idea;
  final VoidCallback onTutorialTap;

  const _IdeaCard({
    required this.idea,
    required this.onTutorialTap,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.successGreen;
      case 'medium':
        return AppTheme.accentGreen;
      case 'hard':
        return AppTheme.warningOrange;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Difficulty
            Row(
              children: [
                Expanded(
                  child: Text(
                    idea.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(idea.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    idea.difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(idea.difficulty),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Description
            Text(
              idea.description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            
            // Estimated Value
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: AppTheme.accentGreen),
                const SizedBox(width: 4),
                Text(
                  'Estimated Value: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.darkGray.withOpacity(0.7),
                  ),
                ),
                Text(
                  'RM ${idea.estimatedValue['min']} - RM ${idea.estimatedValue['max']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tutorial Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTutorialTap,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch YouTube Tutorial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}