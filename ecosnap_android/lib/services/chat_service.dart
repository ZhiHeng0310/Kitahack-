import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create chat conversation between two users
  Future<String> getOrCreateConversation({
    required String userId1,
    required String userName1,
    required String userId2,
    required String userName2,
    String? productId,
  }) async {
    try {
      // Check if conversation already exists
      final existingChats = await _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId1)
          .get();

      for (var doc in existingChats.docs) {
        final chat = ChatConversation.fromMap(doc.data());
        if (chat.participantIds.contains(userId2)) {
          return chat.id;
        }
      }

      // Create new conversation
      final chatId = const Uuid().v4();
      final conversation = ChatConversation(
        id: chatId,
        participantIds: [userId1, userId2],
        participantNames: [userName1, userName2],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastSenderId: '',
        productId: productId,
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .set(conversation.toMap());

      return chatId;
    } catch (e) {
      print('Error creating conversation: $e');
      rethrow;
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String message,
    MessageType type = MessageType.text,
    String? imageUrl,
    String? productId,
    String? productTitle,
    String? productImage,
    double? productPrice,
  }) async {
    try {
      final messageId = const Uuid().v4();
      final chatMessage = ChatMessage(
        id: messageId,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        message: message,
        timestamp: DateTime.now(),
        type: type,
        imageUrl: imageUrl,
        productId: productId,
        productTitle: productTitle,
        productImage: productImage,
        productPrice: productPrice,
      );

      // Add message to messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(chatMessage.toMap());

      // Update conversation with last message
      // If it's an image, we show "Sent a photo" in the preview
      String previewMessage = type == MessageType.image ? 'Sent a photo' : message;
      
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': previewMessage,
        'lastMessageTime': Timestamp.now(),
        'lastSenderId': senderId,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList());
  }

  // Get user's conversations
  Stream<List<ChatConversation>> getUserConversations(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversation.fromMap(doc.data()))
            .toList());
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      final readTime = DateTime.now();

      for (var doc in messages.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.fromDate(readTime), // NEW: Add read timestamp
        });
      }

      await batch.commit();
      print('✅ Marked ${messages.docs.length} messages as read at $readTime');
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadCount(String userId) async {
    try {
        final conversations = await _firestore
            .collection('chats')
            .where('participantIds', arrayContains: userId)
            .get();

        int totalUnread = 0;

        for (var chatDoc in conversations.docs) {
          final unreadMessages = await _firestore
            .collection('chats')
            .doc(chatDoc.id)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

        totalUnread += unreadMessages.docs.length;
        }
        return totalUnread;
    } catch (e) {
        print('Error getting unread count: $e');
        return 0;
    }
  }

  // Stream of unread count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
      .collection('chats')
      .where('participantIds', arrayContains: userId)
      .snapshots()
      .asyncMap((snapshot) async {
        int totalUnread = 0;

        for (var chatDoc in snapshot.docs) {
          final unreadMessages = await _firestore
              .collection('chats')
              .doc(chatDoc.id)
              .collection('messages')
              .where('senderId', isNotEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .get();

          totalUnread += unreadMessages.docs.length;
        }

        return totalUnread;
      }); 
  }
}