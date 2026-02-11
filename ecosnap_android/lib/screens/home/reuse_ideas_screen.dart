import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';

class ReuseIdeasScreen extends StatelessWidget {
  final ScanResult scanResult;

  const ReuseIdeasScreen({super.key, required this.scanResult});

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
                  ? Image.file(
                      File(scanResult.imagePath),
                      fit: BoxFit.cover,
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
                    'Material: ${scanResult.material}',
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
                        '${ideas.length} Reuse Ideas',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Ideas List
                  ...ideas.map((idea) => _IdeaCard(idea: idea)),
                  
                  const SizedBox(height: 24),
                  
                  // Call to Action
                  Card(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Ready to Transform?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Share your creation with the community and inspire others!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigate to community post creation
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

  const _IdeaCard({required this.idea});

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
            const SizedBox(height: 12),
            
            // Action Button
            OutlinedButton.icon(
              onPressed: () {
                // Navigate to tutorials or marketplace
              },
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('View Tutorials'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                side: const BorderSide(color: AppTheme.primaryGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
