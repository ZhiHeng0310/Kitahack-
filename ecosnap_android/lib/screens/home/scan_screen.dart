import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../services/classifier_service.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _dbService = DatabaseService();
  bool _isProcessing = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isProcessing = true);

      // Classify the image
      final result = await WasteClassifier.classifyImage(image.path);

      if (!mounted) return;

      // Get reuse ideas if item is reusable
      List<ReuseIdea>? reuseIdeas;
      Map<String, dynamic>? marketValue;

      if (result['isReusable'] == true) {
        final ideas = WasteClassifier.getReuseIdeas(result['itemName']);
        reuseIdeas = ideas
            .map((idea) => ReuseIdea.fromMap(idea))
            .toList();

        marketValue = WasteClassifier.calculateMarketValue(
          result['itemName'],
          result['condition'],
          ideas,
        );
      }

      // Create scan result
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.currentUser?.uid ?? '';

      final scanResult = ScanResult(
        id: const Uuid().v4(),
        userId: userId,
        itemName: result['itemName'],
        material: result['material'],
        condition: result['condition'],
        confidence: result['confidence'],
        isReusable: result['isReusable'],
        imagePath: image.path,
        timestamp: DateTime.now(),
        reuseIdeas: reuseIdeas,
        marketValue: marketValue,
      );

      // Save to Firestore
      if (userId.isNotEmpty) {
        await _dbService.saveScanResult(scanResult);
      }

      setState(() => _isProcessing = false);

      // Navigate to result screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(scanResult: scanResult),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing image: $e'),
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
        title: const Text('Scan Item'),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Analyzing your item...',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'Scan Your Item',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'Take a photo or select from gallery to discover reuse ideas and recycling options',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Camera Button
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Gallery Button
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      side: const BorderSide(color: AppTheme.primaryGreen),
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Tips Card
                  Card(
                    color: AppTheme.lightGray,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppTheme.accentGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Tips for Best Results',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _TipItem(text: 'Ensure good lighting'),
                          _TipItem(text: 'Center the item in frame'),
                          _TipItem(text: 'Clean the item if possible'),
                          _TipItem(text: 'Capture the whole item'),
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

class _TipItem extends StatelessWidget {
  final String text;

  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.darkGray.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
