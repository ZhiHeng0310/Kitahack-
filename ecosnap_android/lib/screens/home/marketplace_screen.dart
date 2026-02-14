import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../services/database_service.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../../widgets/network_or_file_image.dart';
import 'marketplace/create_product_screen.dart';
import 'marketplace/product_detail_screen.dart';
import 'chat/chat_list_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Upcycled Home Decor',
    'Furniture',
    'Garden',
    'Art & Crafts',
    'Storage Solutions',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          // Message Icon with UNREAD notification badge
          StreamBuilder<int>(
            stream: currentUserId.isNotEmpty
                ? _getUnreadCountStream(currentUserId) // Use local method
                : Stream.value(0),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () async {
                      // Navigate and wait for return
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChatListScreen(),
                        ),
                      );
                      // Force rebuild after returning
                      if (mounted) setState(() {});
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 9 ? '9+' : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateProductScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            color: AppTheme.backgroundWhite,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category);
                    },
                    backgroundColor: AppTheme.backgroundWhite,
                    selectedColor: AppTheme.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.darkGray,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Products Grid
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _selectedCategory == 'All'
                  ? _dbService.getActiveProducts()
                  : _dbService.getProductsByCategory(_selectedCategory),
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
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: AppTheme.darkGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateProductScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('List Your Item'),
                        ),
                      ],
                    ),
                  );
                }
                
                final products = snapshot.data!;
                
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return _ProductCard(product: products[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Local method to get unread count stream
  Stream<int> _getUnreadCountStream(String userId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
          int totalUnread = 0;

          for (var chatDoc in snapshot.docs) {
            final unreadMessages = await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatDoc.id)
                .collection('messages')
                .where('senderId', isNotEqualTo: userId)
                .where('isRead', isEqualTo: false)
                .get();

            totalUnread += unreadMessages.docs.length;
          }

          print('🔴 Marketplace unread count: $totalUnread'); // Debug
          return totalUnread;
        });
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: product.imageUrls.isNotEmpty 
                  ? NetworkOrFileImage(
                      imagePath: product.imageUrls.first,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'RM ${product.price.toStringAsFixed(2)}',
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
                          Icons.person_outline,
                          size: 12,
                          color: AppTheme.darkGray.withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.sellerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.darkGray.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ],
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