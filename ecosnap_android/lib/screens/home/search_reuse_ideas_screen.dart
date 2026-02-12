import 'package:flutter/material.dart';
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
        break;
      }
    }

    // If no exact match, show generic ideas
    if (searchResults.isEmpty) {
      searchResults = [
        {
          'title': 'Storage Container',
          'difficulty': 'Easy',
          'description': 'Use for organizing small items',
          'estimatedValue': {'min': 5, 'max': 10},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$query+reuse+ideas',
        },
        {
          'title': 'DIY Project',
          'difficulty': 'Medium',
          'description': 'Get creative with your own design',
          'estimatedValue': {'min': 10, 'max': 25},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$query+diy+tutorial',
        },
        {
          'title': 'Upcycled Art',
          'difficulty': 'Hard',
          'description': 'Transform into decorative piece',
          'estimatedValue': {'min': 15, 'max': 40},
          'youtubeUrl': 'https://www.youtube.com/results?search_query=$query+upcycle+craft',
        },
      ];
    }
  }

  Future<void> _openYouTube(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open YouTube'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
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
                    return _IdeaCard(
                      idea: idea,
                      onTutorialTap: () => _openYouTube(idea['youtubeUrl']),
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
    final estimatedValue = idea['estimatedValue'] as Map<String, dynamic>;
    final difficulty = idea['difficulty'] as String;

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
                    idea['title'],
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
              idea['description'],
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