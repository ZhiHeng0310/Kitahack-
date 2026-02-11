import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../utils/constants.dart';

class WasteClassifier {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  // Initialize the TFLite model
  static Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      
      _interpreter = await Interpreter.fromAsset(
        AppConstants.modelFileName,
        options: options,
      );
      
      // Load labels
      final labelsData = await rootBundle.loadString('assets/models/${AppConstants.labelsFileName}');
      _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      
      print('Model loaded successfully with ${_labels!.length} labels');
    } catch (e) {
      print('Error loading model: $e');
      rethrow;
    }
  }

  // Classify image
  static Future<Map<String, dynamic>> classifyImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    try {
      // Read and preprocess image
      final imageData = File(imagePath).readAsBytesSync();
      final image = img.decodeImage(imageData);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image to model input size
      final resizedImage = img.copyResize(
        image,
        width: AppConstants.imageSize,
        height: AppConstants.imageSize,
      );

      // Convert to input format (normalized float32)
      final input = _imageToByteListFloat32(resizedImage);
      
      // Prepare output buffer
      final output = List.filled(1 * _labels!.length, 0.0).reshape([1, _labels!.length]);
      
      // Run inference
      _interpreter!.run(input, output);
      
      // Get results
      final probabilities = output[0] as List<double>;
      
      // Find highest confidence prediction
      double maxConfidence = 0.0;
      int maxIndex = 0;
      
      for (int i = 0; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      final predictedLabel = _labels![maxIndex];
      
      // Parse the label (format: "category:material:condition")
      final parts = predictedLabel.split(':');
      final itemName = parts.length > 0 ? parts[0] : 'Unknown';
      final material = parts.length > 1 ? parts[1] : 'Unknown';
      final condition = parts.length > 2 ? parts[2] : 'Unknown';
      
      // Determine if reusable based on condition and material
      final isReusable = _isItemReusable(condition, material);
      
      return {
        'itemName': itemName,
        'material': material,
        'condition': condition,
        'confidence': maxConfidence,
        'isReusable': isReusable,
        'allProbabilities': probabilities,
        'allLabels': _labels,
      };
    } catch (e) {
      print('Error classifying image: $e');
      rethrow;
    }
  }

  // Convert image to Float32 byte list
  static Uint8List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(1 * AppConstants.imageSize * AppConstants.imageSize * 3);
    final buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (int y = 0; y < AppConstants.imageSize; y++) {
      for (int x = 0; x < AppConstants.imageSize; x++) {
        final pixel = image.getPixel(x, y);
        
        // Normalize to [0, 1]
        buffer[pixelIndex++] = (pixel.r / 255.0);
        buffer[pixelIndex++] = (pixel.g / 255.0);
        buffer[pixelIndex++] = (pixel.b / 255.0);
      }
    }

    return convertedBytes.buffer.asUint8List();
  }

  // Determine if item is reusable
  static bool _isItemReusable(String condition, String material) {
    final cleanCondition = condition.toLowerCase();
    final cleanMaterial = material.toLowerCase();
    
    // Non-reusable conditions
    if (cleanCondition.contains('contaminated') ||
        cleanCondition.contains('broken') ||
        cleanCondition.contains('damaged')) {
      return false;
    }
    
    // Non-reusable materials (typically)
    if (cleanMaterial.contains('food waste') ||
        cleanMaterial.contains('hazardous')) {
      return false;
    }
    
    // Default to reusable for clean/good condition items
    return cleanCondition.contains('clean') ||
           cleanCondition.contains('good') ||
           cleanCondition.contains('reusable');
  }

  // Get reuse ideas based on item classification
  static List<Map<String, dynamic>> getReuseIdeas(String itemName) {
    // Check if we have predefined ideas for this item
    for (final key in AppConstants.reuseIdeas.keys) {
      if (itemName.toLowerCase().contains(key.toLowerCase())) {
        return AppConstants.reuseIdeas[key]!;
      }
    }
    
    // Generic ideas for unknown items
    return [
      {
        'title': 'Storage Container',
        'difficulty': 'Easy',
        'description': 'Use for organizing small items',
        'estimatedValue': {'min': 5, 'max': 10},
      },
      {
        'title': 'DIY Project Material',
        'difficulty': 'Medium',
        'description': 'Get creative with your own design',
        'estimatedValue': {'min': 10, 'max': 25},
      },
    ];
  }

  // Calculate estimated market value
  static Map<String, int> calculateMarketValue(
    String itemName,
    String condition,
    List<Map<String, dynamic>> reuseIdeas,
  ) {
    if (reuseIdeas.isEmpty) {
      return {'min': 5, 'max': 15};
    }
    
    // Get average from all reuse ideas
    int totalMin = 0;
    int totalMax = 0;
    
    for (final idea in reuseIdeas) {
      final value = idea['estimatedValue'] as Map<String, dynamic>;
      totalMin += (value['min'] as int);
      totalMax += (value['max'] as int);
    }
    
    final avgMin = (totalMin / reuseIdeas.length).round();
    final avgMax = (totalMax / reuseIdeas.length).round();
    
    // Adjust based on condition
    double conditionMultiplier = 1.0;
    if (condition.toLowerCase().contains('excellent')) {
      conditionMultiplier = 1.2;
    } else if (condition.toLowerCase().contains('poor')) {
      conditionMultiplier = 0.7;
    }
    
    return {
      'min': (avgMin * conditionMultiplier).round(),
      'max': (avgMax * conditionMultiplier).round(),
    };
  }

  // Dispose resources
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
