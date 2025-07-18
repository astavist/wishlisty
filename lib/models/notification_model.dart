import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  friendRequest,
  friendAccepted,
  wishLiked,
  wishCommented,
  wishPinned,
  mention,
  giftPurchased,
}

class NotificationModel {
  final String id;
  final String recipientId;
  final String senderId;
  final NotificationType type;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.senderId,
    required this.type,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.data,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: NotificationType.values.firstWhere(
        (type) => type.toString() == data['type'],
        orElse: () => NotificationType.mention,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'type': type.toString(),
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    NotificationType? type,
    String? title,
    String? body,
    String? imageUrl,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Factory methods for creating specific notification types
  factory NotificationModel.friendRequest({
    required String recipientId,
    required String senderId,
    required String senderName,
  }) {
    return NotificationModel(
      id: '',
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationType.friendRequest,
      title: 'New Friend Request',
      body: '$senderName sent you a friend request',
      data: {'senderId': senderId, 'senderName': senderName},
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.friendAccepted({
    required String recipientId,
    required String senderId,
    required String senderName,
  }) {
    return NotificationModel(
      id: '',
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationType.friendAccepted,
      title: 'Friend Request Accepted',
      body: '$senderName accepted your friend request',
      data: {'senderId': senderId, 'senderName': senderName},
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.wishLiked({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String wishId,
    required String wishTitle,
  }) {
    return NotificationModel(
      id: '',
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationType.wishLiked,
      title: 'Wish Liked',
      body: '$senderName liked your wish "$wishTitle"',
      data: {
        'senderId': senderId,
        'senderName': senderName,
        'wishId': wishId,
        'wishTitle': wishTitle,
      },
      createdAt: DateTime.now(),
    );
  }

  factory NotificationModel.wishCommented({
    required String recipientId,
    required String senderId,
    required String senderName,
    required String wishId,
    required String wishTitle,
    required String comment,
  }) {
    return NotificationModel(
      id: '',
      recipientId: recipientId,
      senderId: senderId,
      type: NotificationType.wishCommented,
      title: 'New Comment',
      body: '$senderName commented on your wish "$wishTitle"',
      data: {
        'senderId': senderId,
        'senderName': senderName,
        'wishId': wishId,
        'wishTitle': wishTitle,
        'comment': comment,
      },
      createdAt: DateTime.now(),
    );
  }
} 