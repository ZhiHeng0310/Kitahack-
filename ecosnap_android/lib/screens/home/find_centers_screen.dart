import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/auth_service.dart';

class FindCentersScreen extends StatefulWidget {
  const FindCentersScreen({super.key});

  @override
  State<FindCentersScreen> createState() => _FindCentersScreenState();
}

class _FindCentersScreenState extends State<FindCentersScreen> {
  String? selectedState;
  List<Map<String, dynamic>> filteredCenters = [];

  @override
  void initState() {
    super.initState();
    // Default to first state
    if (AppConstants.malaysianStates.isNotEmpty) {
      selectedState = AppConstants.malaysianStates.first;
      _filterCenters();
    }
  }

  void _filterCenters() {
    if (selectedState != null) {
      setState(() {
        filteredCenters = AppConstants.recyclingCentersByState[selectedState!] ?? [];
      });
    }
  }

  Future<void> _incrementRecycledCount() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    
    if (userId != null) {
      final userData = await authService.getUserDocument(userId);
      if (userData != null) {
        final updatedStats = userData.stats.copyWith(
          itemsRecycled: userData.stats.itemsRecycled + 1,
        );
        await authService.updateUserStats(userId, updatedStats);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Recycling Centers'),
      ),
      body: Column(
        children: [
          // State Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.backgroundWhite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select State',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedState,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  items: AppConstants.malaysianStates.map((state) {
                    return DropdownMenuItem(
                      value: state,
                      child: Text(state),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                      _filterCenters();
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Centers List
          Expanded(
            child: filteredCenters.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: AppTheme.darkGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No centers found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredCenters.length,
                    itemBuilder: (context, index) {
                      final center = filteredCenters[index];
                      return _CenterCard(
                        center: center,
                        onTap: () async {
                          await _incrementRecycledCount();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Recycled count increased! 🌱'),
                                backgroundColor: AppTheme.successGreen,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
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

class _CenterCard extends StatelessWidget {
  final Map<String, dynamic> center;
  final VoidCallback onTap;

  const _CenterCard({
    required this.center,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final acceptedItems = center['acceptedItems'] as List<dynamic>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.recycling,
                      color: AppTheme.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppTheme.darkGray.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                center['address'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.darkGray.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    size: 14,
                    color: AppTheme.darkGray.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    center['phone'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Accepted Items:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: acceptedItems.map((item) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.lightGreen.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to mark as visited',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}