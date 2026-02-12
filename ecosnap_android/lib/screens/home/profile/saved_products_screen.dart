import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import 'package:ecosnap/screens/home/marketplace/product_detail_screen.dart';

class SavedProductsScreen extends StatefulWidget {
  const SavedProductsScreen({super.key});

  @override
  State<SavedProductsScreen> createState() => _SavedProductsScreenState();
}

class _SavedProductsScreenState extends State<SavedProductsScreen> {
  List<Product> _savedProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedProducts();
  }

    Future<void> _loadSavedProducts() async {
        setState(() => _isLoading = true);

        final authService = Provider.of<AuthService>(context, listen: false);
        final currentUserId = authService.currentUser?.uid ?? '';

        try {
        final savedSnapshot = await FirebaseFirestore.instance
            .collection('saved_products')
            .where('userId', isEqualTo: currentUserId)
            .get();

        List<Product> products = [];

        for (var doc in savedSnapshot.docs) {
            final productId = doc['productId'];
            
            final productDoc = await FirebaseFirestore.instance
                .collection('products')
                .doc(productId)
                .get();

            if (productDoc.exists && productDoc.data() != null) {
            final productData = productDoc.data()!;
            final product = Product.fromMap(productData);
            products.add(product);
            }
        } // <--- This closes the FOR loop

        if (mounted) {
            setState(() {
            _savedProducts = products;
            _isLoading = false;
            });
        }
        } catch (e) {
        print('❌ Error loading saved products: $e');
        if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error loading saved products: $e'),
                backgroundColor: AppTheme.errorRed,
            ),
            );
        }
        }
    }

  void _openProductDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Products'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedProducts.isEmpty
              ? Center(
                  child: Text(
                    'No saved products yet.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.darkGray.withOpacity(0.6),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _savedProducts[index];

                    return GestureDetector(
                      onTap: () => _openProductDetail(product),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            // Product image
                            SizedBox(
                                width: 100,
                                height: 100,
                                child: product.imageUrls.isNotEmpty &&
                                        File(product.imageUrls.first).existsSync()
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                            File(product.imageUrls.first),
                                            fit: BoxFit.cover,
                                        ),
                                        )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                            Icons.image,
                                            size: 50,
                                        ),
                                        ),
                                ),

                            // Product info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'RM ${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.darkGray.withOpacity(0.6),
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
                  },
                ),
    );
  }
}