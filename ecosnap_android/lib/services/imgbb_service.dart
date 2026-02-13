import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImgBBService {
  // Get your FREE API key from: https://api.imgbb.com/
  // You need to sign up and get your own key
  static const String _apiKey = '4fbef03394524f3bd8fd0256d866b731'; // Replace with your key
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload image to ImgBB and get permanent URL
  Future<String> uploadImage(File imageFile) async {
    try {
      // Read image file as bytes
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Create multipart request
      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
          'expiration': '0', // 0 = never expire (requires free account)
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          final imageUrl = jsonResponse['data']['url'];
          print('✅ Image uploaded to ImgBB: $imageUrl');
          return imageUrl;
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error']['message']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error uploading to ImgBB: $e');
      rethrow;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    final urls = <String>[];
    
    for (var imageFile in imageFiles) {
      final url = await uploadImage(imageFile);
      urls.add(url);
    }
    
    return urls;
  }

  /// Delete image from ImgBB (requires delete hash which we need to store)
  /// Note: ImgBB free plan doesn't support deletion via API
  /// Images can be managed through their dashboard
  Future<void> deleteImage(String imageUrl) async {
    print('⚠️ ImgBB free tier doesn\'t support API deletion');
    print('Manage images at: https://imgbb.com/');
  }
}