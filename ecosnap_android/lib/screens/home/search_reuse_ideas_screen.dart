import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class SearchReuseIdeasScreen extends StatefulWidget {
  const SearchReuseIdeasScreen({super.key});

  @override
  State<SearchReuseIdeasScreen> createState() => _SearchReuseIdeasScreenState();
}

class _SearchReuseIdeasScreenState extends State<SearchReuseIdeasScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  String searchedItem = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchItem() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an item to search'),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }

    setState(() {
      searchedItem = query;
      searchResults = [];
    });

    // Search through all reuse ideas
    for (final entry in AppConstants.reuseIdeas.entries) {
      if (entry.key.toLowerCase().contains(query.toLowerCase()) ||
          query.toLowerCase().contains(entry.key.toLowerCase())) {
        searchResults = entry.value;
        print('✅ Found ${searchResults.length} ideas for: ${entry.key}');
        break;
      }
    }

    // If no exact match, show generic ideas with proper YouTube URLs
    if (searchResults.isEmpty) {
      final encodedQuery = Uri.encodeComponent(query);
      searchResults = [
        {
          'title': 'Storage Container',
          'difficulty': 'Easy',
          'description': 'Use for organizing small items',
          'estimatedValue': {'min': 5, 'max': 10},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$encodedQuery+reuse+ideas',
        },
        {
          'title': 'DIY Project',
          'difficulty': 'Medium',
          'description': 'Get creative with your own design',
          'estimatedValue': {'min': 10, 'max': 25},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$encodedQuery+diy+upcycle',
        },
        {
          'title': 'Upcycled Art',
          'difficulty': 'Hard',
          'description': 'Transform into decorative piece',
          'estimatedValue': {'min': 15, 'max': 40},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$encodedQuery+craft+tutorial',
        },
      ];
    }
  }

  Future<void> _openYouTube(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No YouTube URL available'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    try {
      print('🎥 Attempting to open: $url'); // Debug
      
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        print('✅ Launch result: $launched'); // Debug
        
        if (!launched && context.mounted) {
          _showUrlDialog(url);
        }
      } else {
        print('❌ Cannot launch URL: $url'); // Debug
        if (context.mounted) {
          _showUrlDialog(url);
        }
      }
    } catch (e) {
      print('❌ Error opening YouTube: $e'); // Debug
      if (context.mounted) {
        _showUrlDialog(url);
      }
    }
  }

  void _showUrlDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('YouTube Tutorial'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Copy this URL to watch the tutorial:'),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL copied to clipboard!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Copy URL'),
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reuse Ideas'),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What would you like to reuse?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Glass Bottle, Plastic Bag, Clothing...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchResults = [];
                          searchedItem = '';
                        });
                      },
                    ),
                  ),
                  onSubmitted: (_) => _searchItem(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _searchItem,
                    icon: const Icon(Icons.search),
                    label: const Text('Search Ideas'),
                  ),
                ),
              ],
            ),
          ),

          // Popular Items
          if (searchResults.isEmpty && searchedItem.isEmpty)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Popular Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.reuseIdeas.keys.map((item) {
                        return ActionChip(
                          label: Text(item),
                          backgroundColor: AppTheme.lightGreen.withOpacity(0.2),
                          onPressed: () {
                            _searchController.text = item;
                            _searchItem();
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'How it works:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _HowItWorksItem(
                      number: 1,
                      text: 'Enter the item you want to reuse',
                      icon: Icons.edit,
                    ),
                    _HowItWorksItem(
                      number: 2,
                      text: 'Browse creative reuse ideas',
                      icon: Icons.lightbulb,
                    ),
                    _HowItWorksItem(
                      number: 3,
                      text: 'Watch YouTube tutorials',
                      icon: Icons.play_circle,
                    ),
                    _HowItWorksItem(
                      number: 4,
                      text: 'Create and share your project!',
                      icon: Icons.share,
                    ),
                  ],
                ),
              ),
            ),

          // Search Results
          if (searchResults.isNotEmpty)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Reuse Ideas for "$searchedItem"',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${searchResults.length} ideas found',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...searchResults.map((idea) {
                    // CRITICAL: Extract YouTube URL here
                    final youtubeUrl = idea['youtubeUrl'] as String? ?? '';
                    
                    return _IdeaCard(
                      idea: idea,
                      onTutorialTap: () {
                        print('🎬 Button clicked, URL: $youtubeUrl'); // Debug
                        if (youtubeUrl.isNotEmpty) {
                          _openYouTube(youtubeUrl);
                        } else {
                          print('❌ Empty YouTube URL'); // Debug
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('YouTube URL not available'),
                              backgroundColor: AppTheme.errorRed,
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                ],
              ),
            ),

          // No Results
          if (searchResults.isEmpty && searchedItem.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 80,
                      color: AppTheme.darkGray.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No specific ideas found for "$searchedItem"',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkGray.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching: Glass Bottle, Plastic Bag,\nClothing, Magazine, etc.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
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

class _IdeaCard extends StatelessWidget {
  final Map<String, dynamic> idea;
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
    final title = idea['title'] as String? ?? 'Unknown';
    final difficulty = idea['difficulty'] as String? ?? 'Medium';
    final description = idea['description'] as String? ?? '';
    final estimatedValue = idea['estimatedValue'] as Map<String, dynamic>? ?? {'min': 0, 'max': 0};

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
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
                    color: _getDifficultyColor(difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getDifficultyColor(difficulty),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.darkGray.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
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
                  'RM ${estimatedValue['min']} - RM ${estimatedValue['max']}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onTutorialTap,
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch YouTube Tutorial'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksItem extends StatelessWidget {
  final int number;
  final String text;
  final IconData icon;

  const _HowItWorksItem({
    required this.number,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: AppTheme.accentGreen, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}