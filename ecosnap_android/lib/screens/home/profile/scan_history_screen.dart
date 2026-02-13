import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';
import 'package:ecosnap/screens/home/scan_result_screen.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: DatabaseService().getUserScanHistory(userId),
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
                    Icons.history,
                    size: 80,
                    color: AppTheme.darkGray.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No scan history yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start scanning items to see them here',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final scans = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              return _ScanHistoryCard(scan: scan);
            },
          );
        },
      ),
    );
  }
}

class _ScanHistoryCard extends StatelessWidget {
  final ScanResult scan;

  const _ScanHistoryCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ScanResultScreen(scanResult: scan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image Thumbnail
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: scan.imagePath.isNotEmpty
                    ? NetworkOrFileImage(
                        imagePath: scan.imagePath,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : const Icon(Icons.image, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Name
                    Text(
                      scan.itemName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Material & Condition
                    Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 14,
                          color: AppTheme.darkGray.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scan.material,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: AppTheme.darkGray.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          scan.condition,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Status Badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: scan.isReusable
                                ? AppTheme.successGreen.withOpacity(0.2)
                                : AppTheme.warningOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                scan.isReusable
                                    ? Icons.check_circle
                                    : Icons.recycling,
                                size: 12,
                                color: scan.isReusable
                                    ? AppTheme.successGreen
                                    : AppTheme.warningOrange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                scan.isReusable ? 'Reusable' : 'Recycle',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: scan.isReusable
                                      ? AppTheme.successGreen
                                      : AppTheme.warningOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        
                        // Timestamp
                        Text(
                          DateFormat('MMM dd, yyyy').format(scan.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.darkGray.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.darkGray.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}