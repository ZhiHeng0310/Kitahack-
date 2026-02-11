import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class RecycleInfoScreen extends StatelessWidget {
  final String itemName;
  final String material;

  const RecycleInfoScreen({
    super.key,
    required this.itemName,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Information'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info
            Card(
              color: AppTheme.warningOrange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.recycling, color: AppTheme.warningOrange, size: 40),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Material: $material',
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
            ),
            const SizedBox(height: 24),
            
            // Preparation Steps
            const Text(
              'Preparation Steps',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            
            _PreparationStep(
              number: 1,
              text: 'Clean the item thoroughly',
              icon: Icons.cleaning_services,
            ),
            _PreparationStep(
              number: 2,
              text: 'Remove any labels or stickers',
              icon: Icons.label_off,
            ),
            _PreparationStep(
              number: 3,
              text: 'Separate different materials if applicable',
              icon: Icons.splitscreen,
            ),
            _PreparationStep(
              number: 4,
              text: 'Check local recycling guidelines',
              icon: Icons.rule,
            ),
            
            const SizedBox(height: 24),
            
            // Recycling Centers
            const Text(
              'Nearby Recycling Centers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            
            ...AppConstants.recyclingCenters.map((center) {
              final acceptsMaterial = (center['acceptedItems'] as List<String>)
                  .any((item) => material.toLowerCase().contains(item.toLowerCase()) ||
                      item.toLowerCase().contains(material.toLowerCase()));
              
              return _RecyclingCenterCard(
                center: center,
                acceptsThisMaterial: acceptsMaterial,
              );
            }),
            
            const SizedBox(height: 24),
            
            // Environmental Impact
            Card(
              color: AppTheme.successGreen.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.eco, color: AppTheme.successGreen),
                        const SizedBox(width: 8),
                        const Text(
                          'Environmental Impact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By recycling this item, you\'re helping reduce waste and conserve natural resources. Every small action makes a difference!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.darkGray.withOpacity(0.8),
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
  }
}

class _PreparationStep extends StatelessWidget {
  final int number;
  final String text;
  final IconData icon;

  const _PreparationStep({
    required this.number,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(width: 16),
            Icon(icon, color: AppTheme.accentGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecyclingCenterCard extends StatelessWidget {
  final Map<String, dynamic> center;
  final bool acceptsThisMaterial;

  const _RecyclingCenterCard({
    required this.center,
    required this.acceptsThisMaterial,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    center['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                if (acceptsThisMaterial)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Accepts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: AppTheme.accentGreen),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    center['address'],
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: AppTheme.accentGreen),
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
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (center['acceptedItems'] as List<String>).map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
