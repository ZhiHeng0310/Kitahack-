import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../widgets/network_or_file_image.dart';
import '../../../services/auth_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../services/chat_service.dart';
import 'package:ecosnap/screens/home/chat/chat_screen.dart';
import '../user/user_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isSaved = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('saved_products')
          .where('userId', isEqualTo: userId)
          .where('productId', isEqualTo: widget.product.id)
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _isSaved = doc.docs.isNotEmpty;
        });
      }
    } catch (e) {
      print('Error checking saved status: $e');
    }
  }

  Future<void> _toggleSave() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    if (userId.isEmpty) return;

    try {
      if (_isSaved) {
        // Unsave
        final docs = await FirebaseFirestore.instance
            .collection('saved_products')
            .where('userId', isEqualTo: userId)
            .where('productId', isEqualTo: widget.product.id)
            .get();

        for (var doc in docs.docs) {
          await doc.reference.delete();
        }

        setState(() => _isSaved = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product unsaved'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Save
        await FirebaseFirestore.instance.collection('saved_products').add({
          'userId': userId,
          'productId': widget.product.id,
          'savedAt': Timestamp.now(),
        });

        setState(() => _isSaved = true);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product saved!'),
              backgroundColor: AppTheme.successGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? AppTheme.primaryGreen : null,
            ),
            onPressed: _toggleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            if (widget.product.imageUrls.isNotEmpty)
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: widget.product.imageUrls.length,
                      onPageChanged: (index) {
                        setState(() => _currentImageIndex = index);
                      },
                      itemBuilder: (context, index) {
                        if (index >= widget.product.imageUrls.length) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 80),
                          );
                        }
                        
                        return NetworkOrFileImage(
                          imagePath: widget.product.imageUrls[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        );
                      },
                    ),
                    if (widget.product.imageUrls.length > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.product.imageUrls.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              // ADDED: Show placeholder when no images
              Container(
                height: 300,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: AppTheme.darkGray.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No images available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Text(
                    'RM ${widget.product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Details Cards
                  Row(
                    children: [
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.category,
                          label: 'Category',
                          value: widget.product.category,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DetailCard(
                          icon: Icons.star,
                          label: 'Condition',
                          value: widget.product.condition,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    widget.product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seller Info
                  const Text(
                    'Seller Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.product.sellerId)
                        .get(),
                    builder: (context, snapshot) {
                      String? photoUrl;

                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        photoUrl = userData['photoUrl'];
                      }

                      return Column(
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: AppTheme.primaryGreen,
                                    radius: 25,
                                    child: photoUrl != null
                                        ? ClipOval(
                                            child: NetworkOrFileImage(
                                              imagePath: photoUrl,
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Text(
                                            widget.product.sellerName[0]
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => UserProfileScreen(userId: widget.product.sellerId),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            widget.product.sellerName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryGreen,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Listed ${DateFormat('MMM dd, yyyy').format(widget.product.createdAt)}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: AppTheme.darkGray
                                                .withOpacity(0.7),
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
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.darkGray.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}