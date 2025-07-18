import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final String? bio;
  final List<String> friends;
  final List<String> friendRequests;
  final List<String> sentRequests;
  final DateTime createdAt;
  final DateTime lastSeen;
  final Map<String, bool> notificationSettings;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.bio,
    required this.friends,
    required this.friendRequests,
    required this.sentRequests,
    required this.createdAt,
    required this.lastSeen,
    required this.notificationSettings,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      bio: data['bio'],
      friends: List<String>.from(data['friends'] ?? []),
      friendRequests: List<String>.from(data['friendRequests'] ?? []),
      sentRequests: List<String>.from(data['sentRequests'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      notificationSettings: Map<String, bool>.from(data['notificationSettings'] ?? {
        'mentions': true,
        'wishLists': true,
        'comments': true,
        'newFriendRequests': true,
        'giftPurchases': true,
      }),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'friends': friends,
      'friendRequests': friendRequests,
      'sentRequests': sentRequests,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
      'notificationSettings': notificationSettings,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    String? bio,
    List<String>? friends,
    List<String>? friendRequests,
    List<String>? sentRequests,
    DateTime? createdAt,
    DateTime? lastSeen,
    Map<String, bool>? notificationSettings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      friends: friends ?? this.friends,
      friendRequests: friendRequests ?? this.friendRequests,
      sentRequests: sentRequests ?? this.sentRequests,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }
} 