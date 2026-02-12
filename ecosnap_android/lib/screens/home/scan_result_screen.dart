import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import 'recycle_info_screen.dart';
import 'reuse_ideas_screen.dart';
import 'find_centers_screen.dart';

class ScanResultScreen extends StatelessWidget {
  final ScanResult scanResult;

  const ScanResultScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Container(
              height: 250,
              color: Colors.grey[200],
              child: scanResult.imagePath.isNotEmpty
                  ? Image.file(
                      File(scanResult.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image, size: 80, color: Colors.grey),
                        );
                      },
                    )
                  : const Icon(Icons.image, size: 80, color: Colors.grey),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis Result
                  Card(
                    color: AppTheme.lightGreen.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.successGreen),
                              const SizedBox(width: 8),
                              const Text(
                                'Item Detected',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          _InfoRow(label: 'Item', value: scanResult.itemName),
                          _InfoRow(label: 'Material', value: scanResult.material),
                          _InfoRow(label: 'Condition', value: scanResult.condition),
                          _InfoRow(
                            label: 'Confidence',
                            value: '${(scanResult.confidence * 100).toStringAsFixed(1)}%',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Decision Path
                  if (!scanResult.isReusable) ...[
                    // Recycle Path
                    _buildRecyclePath(context),
                  ] else ...[
                    // Reuse Path
                    _buildReusePath(context),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    /// PATH A: Recycle Path
  Widget _buildRecyclePath(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.recycling, color: AppTheme.warningOrange, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❌ This item cannot be reused',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recommended Action: Recycling',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Recycling Options',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),

        // Recycle Info Preview
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist, color: AppTheme.accentGreen),
                    const SizedBox(width: 8),
                    const Text(
                      'Preparation Steps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PrepStep(number: '1', text: 'Clean the item thoroughly'),
                _PrepStep(number: '2', text: 'Remove labels and stickers'),
                _PrepStep(number: '3', text: 'Separate different materials'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FindCentersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.location_on),
            label: const Text('Find Recycling Centers'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// PATH B: Reuse Path
  Widget _buildReusePath(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✅ Great news!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'This item can be reused creatively',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Reuse Ideas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),

        if (scanResult.reuseIdeas != null && scanResult.reuseIdeas!.isNotEmpty)
          Column(
            children: scanResult.reuseIdeas!.take(2).map((idea) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getDifficultyColor(idea.difficulty),
                    child: Text(
                      idea.difficulty[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    idea.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(idea.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReuseIdeasScreen(scanResult: scanResult),
                ),
              );
            },
            icon: const Icon(Icons.lightbulb),
            label: const Text('View All Reuse Ideas'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        // Market Value Info
        if (scanResult.marketValue != null) ...[
          const SizedBox(height: 24),
          Card(
            color: AppTheme.accentGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: AppTheme.accentGreen),
                      const SizedBox(width: 8),
                      const Text(
                        'Estimated Market Value',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'RM ${scanResult.marketValue!['min']} - RM ${scanResult.marketValue!['max']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'After transformation',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
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

/// Reusable Info Row
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Preparation Step Widget
class _PrepStep extends StatelessWidget {
  final String number;
  final String text;

  const _PrepStep({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}