import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final Product? product;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    this.product,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  bool _hasSentProductInfo = false;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
    
    // Send product info automatically if provided
    if (widget.product != null && !_hasSentProductInfo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendProductInfo();
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';
    await _chatService.markMessagesAsRead(widget.chatId, userId);
  }

  Future<void> _sendProductInfo() async {
    if (_hasSentProductInfo || widget.product == null) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final userData = await authService.getUserDocument(user!.uid);

    await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: user.uid,
      senderName: userData?.displayName ?? 'User',
      message: 'Hi! I\'m interested in this item:',
      productId: widget.product!.id,
      productTitle: widget.product!.title,
      productImage: widget.product!.imageUrls.isNotEmpty 
          ? widget.product!.imageUrls.first 
          : null,
      productPrice: widget.product!.price,
    );

    setState(() => _hasSentProductInfo = true);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    final userData = await authService.getUserDocument(user!.uid);

    await _chatService.sendMessage(
      chatId: widget.chatId,
      senderId: user.uid,
      senderName: userData?.displayName ?? 'User',
      message: _messageController.text.trim(),
    );

    _messageController.clear();
    
    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.chatId)
              .get(),
          builder: (context, snapshot) {
            String? otherUserId;
            
            if (snapshot.hasData && snapshot.data!.exists) {
              final chatData = snapshot.data!.data() as Map<String, dynamic>;
              final participantIds = List<String>.from(chatData['participantIds'] ?? []);
              final authService = Provider.of<AuthService>(context, listen: false);
              final currentUserId = authService.currentUser?.uid ?? '';
              
              otherUserId = participantIds.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );
            }

            return FutureBuilder<DocumentSnapshot>(
              future: otherUserId != null && otherUserId.isNotEmpty
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(otherUserId)
                      .get()
                  : null,
              builder: (context, userSnapshot) {
                String? photoUrl;
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  photoUrl = userData['photoUrl'];
                }

                return Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      radius: 18,
                      child: photoUrl != null
                          ? ClipOval(
                              child: NetworkOrFileImage(
                                imagePath: photoUrl,
                                width: 36,
                                height: 36,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Text(
                              widget.otherUserName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.otherUserName,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatService.getMessages(widget.chatId),
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
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: AppTheme.darkGray.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkGray.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Start the conversation!',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _MessageBubble(
                      message: message,
                      isMe: isMe,
                    );
                  },
                );
              },
            ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.lightGray,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryGreen,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  String _formatSeenTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            // Profile picture for other user
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(message.senderId)
                  .get(),
              builder: (context, snapshot) {
                String? photoUrl;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>;
                  photoUrl = userData['photoUrl'];
                }

                return CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  radius: 16,
                  child: photoUrl != null
                      ? ClipOval(
                          child: NetworkOrFileImage(
                            imagePath: photoUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          message.senderName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryGreen : AppTheme.lightGray,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product card if present
                      if (message.productId != null) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isMe ? 0.2 : 1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMe 
                                  ? Colors.white.withOpacity(0.3)
                                  : AppTheme.darkGray.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              if (message.productImage != null)
                                NetworkOrFileImage(
                                  imagePath: message.productImage!,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.productTitle ?? 'Product',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isMe ? Colors.white : AppTheme.darkGray,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (message.productPrice != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'RM ${message.productPrice!.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: isMe 
                                              ? Colors.white 
                                              : AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Message text
                      Text(
                        message.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: isMe ? Colors.white : AppTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                
                // Time and Status
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.darkGray.withOpacity(0.6),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      // Show "Seen" with time if read
                      if (message.isRead && message.readAt != null) ...[
                        Text(
                          '• Seen ${_formatSeenTime(message.readAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (message.isRead) ...[
                        // Fallback if readAt is missing
                        const Text(
                          '• Seen',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        // Not read - show checkmark
                        Icon(
                          Icons.check,
                          size: 14,
                          color: AppTheme.darkGray.withOpacity(0.6),
                        ),
                      ],
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}