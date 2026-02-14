import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../services/auth_service.dart';
import '../../../services/chat_service.dart';
import '../../../models/models.dart';
import '../../../utils/constants.dart';
import '../../../widgets/network_or_file_image.dart';
import 'chat_screen.dart';
import '../user/user_profile_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: ChatService().getUserConversations(currentUserId),
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
                    'Start a conversation by contacting a seller',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data!;

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context,index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              
              // Get other user's info
              final otherUserIndex = conversation.participantIds[0] == currentUserId ? 1 : 0;
              final otherUserId = conversation.participantIds[otherUserIndex];
              final otherUserName = conversation.participantNames[otherUserIndex];

              // NEW: Check for unread messages in this conversation
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(conversation.id)
                    .collection('messages')
                    .where('senderId', isNotEqualTo: currentUserId)
                    .where('isRead', isEqualTo: false)
                    .limit(1)
                    .snapshots(),
                builder: (context, unreadSnapshot) {
                  // Only show as unread if there are unread messages from the other person
                  final hasUnread = unreadSnapshot.hasData && 
                                  unreadSnapshot.data!.docs.isNotEmpty;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(otherUserId)
                        .get(),
                    builder: (context, snapshot) {
                      String? photoUrl;
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final userData = snapshot.data!.data() as Map<String, dynamic>;
                        photoUrl = userData['photoUrl'];
                      }

                      return ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UserProfileScreen(userId: otherUserId),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: AppTheme.primaryGreen,
                            radius: 28,
                            child: photoUrl != null
                                ? ClipOval(
                                    child: NetworkOrFileImage(
                                      imagePath: photoUrl,
                                      width: 56,
                                      height: 56,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Text(
                                    otherUserName[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        title: Text(
                          otherUserName,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          conversation.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.darkGray.withOpacity(0.7),
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(conversation.lastMessageTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnread 
                                    ? AppTheme.primaryGreen 
                                    : AppTheme.darkGray.withOpacity(0.6),
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (hasUnread) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: conversation.id,
                                otherUserName: otherUserName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(dateTime);
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}