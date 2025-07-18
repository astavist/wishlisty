import 'package:cloud_firestore/cloud_firestore.dart';

class WishModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? imageUrl;
  final String? productUrl;
  final double? price;
  final String? currency;
  final String category;
  final int priority; // 1-5, 5 being highest
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> likes;
  final List<WishComment> comments;
  final List<WishPin> pins; // People who pinned this wish (hidden from owner)
  final bool isPublic;
  final Map<String, dynamic> metadata;

  WishModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.productUrl,
    this.price,
    this.currency = 'USD',
    required this.category,
    this.priority = 3,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.comments,
    required this.pins,
    this.isPublic = true,
    required this.metadata,
  });

  factory WishModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return WishModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      productUrl: data['productUrl'],
      price: data['price']?.toDouble(),
      currency: data['currency'] ?? 'USD',
      category: data['category'] ?? 'Other',
      priority: data['priority'] ?? 3,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      comments: (data['comments'] as List<dynamic>? ?? [])
          .map((comment) => WishComment.fromMap(comment))
          .toList(),
      pins: (data['pins'] as List<dynamic>? ?? [])
          .map((pin) => WishPin.fromMap(pin))
          .toList(),
      isPublic: data['isPublic'] ?? true,
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'productUrl': productUrl,
      'price': price,
      'currency': currency,
      'category': category,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'comments': comments.map((comment) => comment.toMap()).toList(),
      'pins': pins.map((pin) => pin.toMap()).toList(),
      'isPublic': isPublic,
      'metadata': metadata,
    };
  }

  // Check if current user has pinned this wish
  bool isPinnedBy(String userId) {
    return pins.any((pin) => pin.userId == userId);
  }

  // Get pins without revealing to wish owner
  List<WishPin> getPinsForUser(String currentUserId) {
    if (currentUserId == userId) {
      return []; // Hide pins from wish owner
    }
    return pins;
  }

  // Get like count
  int get likeCount => likes.length;

  // Get comment count
  int get commentCount => comments.length;

  // Get pin count (visible to everyone except owner)
  int getPinCount(String currentUserId) {
    if (currentUserId == userId) {
      return 0; // Hide pin count from wish owner
    }
    return pins.length;
  }

  WishModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? imageUrl,
    String? productUrl,
    double? price,
    String? currency,
    String? category,
    int? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? likes,
    List<WishComment>? comments,
    List<WishPin>? pins,
    bool? isPublic,
    Map<String, dynamic>? metadata,
  }) {
    return WishModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      productUrl: productUrl ?? this.productUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      pins: pins ?? this.pins,
      isPublic: isPublic ?? this.isPublic,
      metadata: metadata ?? this.metadata,
    );
  }
}

class WishComment {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;

  WishComment({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory WishComment.fromMap(Map<String, dynamic> map) {
    return WishComment(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class WishPin {
  final String userId;
  final DateTime pinnedAt;
  final String? note; // Private note for the person who pinned

  WishPin({
    required this.userId,
    required this.pinnedAt,
    this.note,
  });

  factory WishPin.fromMap(Map<String, dynamic> map) {
    return WishPin(
      userId: map['userId'] ?? '',
      pinnedAt: (map['pinnedAt'] as Timestamp).toDate(),
      note: map['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'pinnedAt': Timestamp.fromDate(pinnedAt),
      'note': note,
    };
  }
} 