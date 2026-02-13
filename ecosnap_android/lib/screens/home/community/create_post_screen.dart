import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../widgets/network_or_file_image.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  final CommunityPost? post; // For editing

  const CreatePostScreen({super.key, this.post});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _dbService = DatabaseService();

  List<String> _imagePaths = [];
  String _selectedCategory = 'reuse_ideas';
  bool _isLoading = false;

  final Map<String, String> _categories = {
    'reuse_ideas': 'Reuse Ideas',
    'exchange': 'Exchange Requests',
    'success': 'Success Stories',
    'tutorial': 'Tutorials & Tips',
  };

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _contentController.text = widget.post!.content;
      _selectedCategory = widget.post!.category;
      _imagePaths = List.from(widget.post!.imageUrls);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isEmpty) return;

      setState(() => _isLoading = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Uploading images...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final remainingSlots = 4 - _imagePaths.length;
      final imagesToAdd = images.take(remainingSlots).toList();

      for (var image in imagesToAdd) {
        final imageUrl = await _dbService.uploadImage(
          File(image.path),
          'community_posts',
        );
        _imagePaths.add(imageUrl);
      }

      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _savePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      final userData = await authService.getUserDocument(user!.uid);

      // REPLACE this section in _savePost():
      if (widget.post == null) {
        // Create new post
        final postId = const Uuid().v4(); // Generate ID first
        
        final post = CommunityPost(
          id: postId,
          userId: user.uid,
          userName: userData?.displayName ?? user.email!.split('@')[0],
          userPhotoUrl: userData?.photoUrl,
          content: _contentController.text.trim(),
          category: _selectedCategory,
          imageUrls: _imagePaths,
          createdAt: DateTime.now(),
          likes: 0,      // ADD THIS
          comments: 0,   // ADD THIS
          likedBy: [],   // ADD THIS
        );

        // Save to Firestore WITH the ID field included
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(postId)
            .set({
              ...post.toMap(),
              'id': postId, // CRITICAL: Ensure ID is in the document
            });

        // Update user stats - total posts (using co2Saved field as totalPosts)
        await _dbService.incrementTotalPosts(user.uid);
      } else{
        //UPDATE EXISTING POST logic (Move this OUT of the userData check)
          await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(widget.post!.id)
            .update({
          'content': _contentController.text.trim(),
          'category': _selectedCategory,
          'imageUrls': _imagePaths,
        });
      }

        // Update user stats - total posts (using co2Saved field as totalPosts)
        if (userData != null) {
          final updatedStats = userData.stats.copyWith(
            co2Saved: userData.stats.co2Saved + 1,
          );
          await authService.updateUserStats(user.uid, updatedStats);
        } else {
        // Update existing post
        await FirebaseFirestore.instance
            .collection('community_posts')
            .doc(widget.post!.id)
            .update({
          'content': _contentController.text.trim(),
          'category': _selectedCategory,
          'imageUrls': _imagePaths,
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.post == null
                  ? 'Post created successfully!'
                  : 'Post updated successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? 'Create Post' : 'Edit Post'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _savePost,
              child: const Text('Post'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = entry.key);
                    },
                    backgroundColor: AppTheme.backgroundWhite,
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Content
              const Text(
                'What\'s on your mind?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _contentController,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText: 'Share your thoughts, ideas, or questions...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  if (value.trim().length < 10) {
                    return 'Content must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Images Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Photos (Optional)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _imagePaths.length < 4 ? _pickImages : null,
                    icon: const Icon(Icons.add_photo_alternate, size: 20),
                    label: Text('Add (${_imagePaths.length}/4)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_imagePaths.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        // Using your custom widget handles the logic automatically
                        NetworkOrFileImage(
                          imagePath: _imagePaths[index],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your post will be visible to the community',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkGray.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}