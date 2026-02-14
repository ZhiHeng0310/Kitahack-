import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, product }

// Scan Result Model
class ScanResult {
  final String id;
  final String userId;
  final String itemName;
  final String material;
  final String condition;
  final double confidence;
  final bool isReusable;
  final String imagePath;
  final DateTime timestamp;
  final List<ReuseIdea>? reuseIdeas;
  final Map<String, dynamic>? marketValue;

  ScanResult({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.material,
    required this.condition,
    required this.confidence,
    required this.isReusable,
    required this.imagePath,
    required this.timestamp,
    this.reuseIdeas,
    this.marketValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'itemName': itemName,
      'material': material,
      'condition': condition,
      'confidence': confidence,
      'isReusable': isReusable,
      'imagePath': imagePath,
      'timestamp': Timestamp.fromDate(timestamp),
      'reuseIdeas': reuseIdeas?.map((e) => e.toMap()).toList(),
      'marketValue': marketValue,
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      itemName: map['itemName'] ?? '',
      material: map['material'] ?? '',
      condition: map['condition'] ?? '',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      isReusable: map['isReusable'] ?? false,
      imagePath: map['imagePath'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      reuseIdeas: (map['reuseIdeas'] as List<dynamic>?)
          ?.map((e) => ReuseIdea.fromMap(e))
          .toList(),
      marketValue: map['marketValue'] as Map<String, dynamic>?,
    );
  }
}

// Reuse Idea Model
class ReuseIdea {
  final String title;
  final String difficulty;
  final String description;
  final Map<String, int> estimatedValue;

  ReuseIdea({
    required this.title,
    required this.difficulty,
    required this.description,
    required this.estimatedValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'difficulty': difficulty,
      'description': description,
      'estimatedValue': estimatedValue,
    };
  }

  factory ReuseIdea.fromMap(Map<String, dynamic> map) {
    return ReuseIdea(
      title: map['title'] ?? '',
      difficulty: map['difficulty'] ?? '',
      description: map['description'] ?? '',
      estimatedValue: Map<String, int>.from(map['estimatedValue'] ?? {}),
    );
  }
}

// User Model
class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime createdAt;
  final UserStats stats;
  final List<String> connections;
  final List<String> followers;
  final List<String> following;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    required this.stats,
    this.connections = const [],
    this.followers = const [],
    this.following = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'stats': stats.toMap(),
      'connections': connections, 
      'followers': followers, 
      'following': following, 
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      stats: UserStats.fromMap(map['stats'] ?? {}),
      connections: List<String>.from(map['connections'] ?? []), 
      followers: List<String>.from(map['followers'] ?? []), 
      following: List<String>.from(map['following'] ?? []), 

    );
  }
}

// User Stats Model
class UserStats {
  final int itemsReused;
  final int itemsRecycled;
  final int itemsExchanged;
  final double co2Saved;
  final List<String> badges;

  UserStats({
    this.itemsReused = 0,
    this.itemsRecycled = 0,
    this.itemsExchanged = 0,
    this.co2Saved = 0.0,
    this.badges = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'itemsReused': itemsReused,
      'itemsRecycled': itemsRecycled,
      'itemsExchanged': itemsExchanged,
      'co2Saved': co2Saved,
      'badges': badges,
    };
  }

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      itemsReused: map['itemsReused'] ?? 0,
      itemsRecycled: map['itemsRecycled'] ?? 0,
      itemsExchanged: map['itemsExchanged'] ?? 0,
      co2Saved: (map['co2Saved'] ?? 0.0).toDouble(),
      badges: List<String>.from(map['badges'] ?? []),
    );
  }

  UserStats copyWith({
    int? itemsReused,
    int? itemsRecycled,
    int? itemsExchanged,
    double? co2Saved,
    List<String>? badges,
  }) {
    return UserStats(
      itemsReused: itemsReused ?? this.itemsReused,
      itemsRecycled: itemsRecycled ?? this.itemsRecycled,
      itemsExchanged: itemsExchanged ?? this.itemsExchanged,
      co2Saved: co2Saved ?? this.co2Saved,
      badges: badges ?? this.badges,
    );
  }
}

// Marketplace Product Model
class Product {
  final String id;
  final String sellerId;
  final String sellerName;
  final String title;
  final String description;
  final String category;
  final double price;
  final List<String> imageUrls;
  final String condition;
  final bool isActive;
  final DateTime createdAt;
  final int views;
  final int saves;
  final String? sellerPhotoUrl;

  Product({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrls,
    required this.condition,
    this.isActive = true,
    required this.createdAt,
    this.views = 0,
    this.saves = 0,
    this.sellerPhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'imageUrls': imageUrls,
      'condition': condition,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'views': views,
      'saves': saves,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      condition: map['condition'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      views: map['views'] ?? 0,
      saves: map['saves'] ?? 0,
    );
  }
}

// Community Post Model
class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String content;
  final String category; // 'reuse_ideas', 'exchange', 'success', 'tutorial'
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final List<String> likedBy;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.content,
    required this.category,
    this.imageUrls = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'category': category,
      'imageUrls': imageUrls,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
    };
  }

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhotoUrl: map['userPhotoUrl'],
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
    );
  }
}

// Chat Message Model
class ChatMessage {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final String? productId; // For product sharing
  final String? productTitle;
  final String? productImage;
  final double? productPrice;
  final MessageType type;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.readAt,
    this.productId,
    this.productTitle,
    this.productImage,
    this.productPrice,
    required this.type,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'readAt' : readAt != null ? Timestamp.fromDate(readAt!) : null,
      'productId': productId,
      'productTitle': productTitle,
      'productImage': productImage,
      'productPrice': productPrice,
      'type' : type.name,
      'imageUrl' : imageUrl,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      message: map['message'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      readAt: map['readAt'] != null ? (map['readAt'] as Timestamp).toDate() : null,
      productId: map['productId'],
      productTitle: map['productTitle'],
      productImage: map['productImage'],
      productPrice: map['productPrice']?.toDouble(),
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      imageUrl: map['imageUrl'],
    );
  }
}

// Chat Conversation Model
class ChatConversation {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastSenderId;
  final int unreadCount;
  final String? productId;

  ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastSenderId,
    this.unreadCount = 0,
    this.productId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participantIds': participantIds,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
      'productId': productId,
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] ?? '',
      participantIds: List<String>.from(map['participantIds'] ?? []),
      participantNames: List<String>.from(map['participantNames'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: (map['lastMessageTime'] as Timestamp).toDate(),
      lastSenderId: map['lastSenderId'] ?? '',
      unreadCount: map['unreadCount'] ?? 0,
      productId: map['productId'],
    );
  }
}
