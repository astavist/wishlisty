import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/wish_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Collections
  static const String usersCollection = 'users';
  static const String wishesCollection = 'wishes';
  static const String notificationsCollection = 'notifications';
  static const String activitiesCollection = 'activities';

  // Wish Operations
  Future<String?> createWish(WishModel wish) async {
    try {
      DocumentReference docRef = await _firestore.collection(wishesCollection).add(wish.toFirestore());
      return docRef.id;
    } catch (error) {
      print('Create wish error: $error');
      return null;
    }
  }

  Future<bool> updateWish(String wishId, Map<String, dynamic> updateData) async {
    try {
      await _firestore.collection(wishesCollection).doc(wishId).update({
        ...updateData,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (error) {
      print('Update wish error: $error');
      return false;
    }
  }

  Future<bool> deleteWish(String wishId) async {
    try {
      await _firestore.collection(wishesCollection).doc(wishId).delete();
      return true;
    } catch (error) {
      print('Delete wish error: $error');
      return false;
    }
  }

  Future<WishModel?> getWish(String wishId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(wishesCollection).doc(wishId).get();
      if (doc.exists) {
        return WishModel.fromFirestore(doc);
      }
      return null;
    } catch (error) {
      print('Get wish error: $error');
      return null;
    }
  }

  Stream<List<WishModel>> getUserWishes(String userId) {
    return _firestore
        .collection(wishesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => WishModel.fromFirestore(doc)).toList());
  }

  Stream<List<WishModel>> getFriendsWishes(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(wishesCollection)
        .where('userId', whereIn: friendIds)
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => WishModel.fromFirestore(doc)).toList());
  }

  // Pin/Unpin Wish (Secret from wish owner)
  Future<bool> pinWish(String wishId, String userId, {String? note}) async {
    try {
      WishPin pin = WishPin(
        userId: userId,
        pinnedAt: DateTime.now(),
        note: note,
      );

      await _firestore.collection(wishesCollection).doc(wishId).update({
        'pins': FieldValue.arrayUnion([pin.toMap()]),
      });
      return true;
    } catch (error) {
      print('Pin wish error: $error');
      return false;
    }
  }

  Future<bool> unpinWish(String wishId, String userId) async {
    try {
      DocumentSnapshot wishDoc = await _firestore.collection(wishesCollection).doc(wishId).get();
      if (!wishDoc.exists) return false;

      WishModel wish = WishModel.fromFirestore(wishDoc);
      List<WishPin> updatedPins = wish.pins.where((pin) => pin.userId != userId).toList();

      await _firestore.collection(wishesCollection).doc(wishId).update({
        'pins': updatedPins.map((pin) => pin.toMap()).toList(),
      });
      return true;
    } catch (error) {
      print('Unpin wish error: $error');
      return false;
    }
  }

  // Like/Unlike Wish
  Future<bool> likeWish(String wishId, String userId) async {
    try {
      await _firestore.collection(wishesCollection).doc(wishId).update({
        'likes': FieldValue.arrayUnion([userId]),
      });
      return true;
    } catch (error) {
      print('Like wish error: $error');
      return false;
    }
  }

  Future<bool> unlikeWish(String wishId, String userId) async {
    try {
      await _firestore.collection(wishesCollection).doc(wishId).update({
        'likes': FieldValue.arrayRemove([userId]),
      });
      return true;
    } catch (error) {
      print('Unlike wish error: $error');
      return false;
    }
  }

  // Add Comment to Wish
  Future<bool> addComment(String wishId, String userId, String content) async {
    try {
      WishComment comment = WishComment(
        id: _uuid.v4(),
        userId: userId,
        content: content,
        createdAt: DateTime.now(),
      );

      await _firestore.collection(wishesCollection).doc(wishId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
      });
      return true;
    } catch (error) {
      print('Add comment error: $error');
      return false;
    }
  }

  // Friend Operations
  Future<bool> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      // Add to sender's sent requests
      await _firestore.collection(usersCollection).doc(fromUserId).update({
        'sentRequests': FieldValue.arrayUnion([toUserId]),
      });

      // Add to receiver's friend requests
      await _firestore.collection(usersCollection).doc(toUserId).update({
        'friendRequests': FieldValue.arrayUnion([fromUserId]),
      });

      return true;
    } catch (error) {
      print('Send friend request error: $error');
      return false;
    }
  }

  Future<bool> acceptFriendRequest(String currentUserId, String fromUserId) async {
    try {
      // Add to both users' friends lists
      await _firestore.collection(usersCollection).doc(currentUserId).update({
        'friends': FieldValue.arrayUnion([fromUserId]),
        'friendRequests': FieldValue.arrayRemove([fromUserId]),
      });

      await _firestore.collection(usersCollection).doc(fromUserId).update({
        'friends': FieldValue.arrayUnion([currentUserId]),
        'sentRequests': FieldValue.arrayRemove([currentUserId]),
      });

      return true;
    } catch (error) {
      print('Accept friend request error: $error');
      return false;
    }
  }

  Future<bool> rejectFriendRequest(String currentUserId, String fromUserId) async {
    try {
      // Remove from current user's friend requests
      await _firestore.collection(usersCollection).doc(currentUserId).update({
        'friendRequests': FieldValue.arrayRemove([fromUserId]),
      });

      // Remove from sender's sent requests
      await _firestore.collection(usersCollection).doc(fromUserId).update({
        'sentRequests': FieldValue.arrayRemove([currentUserId]),
      });

      return true;
    } catch (error) {
      print('Reject friend request error: $error');
      return false;
    }
  }

  Future<bool> removeFriend(String currentUserId, String friendId) async {
    try {
      // Remove from both users' friends lists
      await _firestore.collection(usersCollection).doc(currentUserId).update({
        'friends': FieldValue.arrayRemove([friendId]),
      });

      await _firestore.collection(usersCollection).doc(friendId).update({
        'friends': FieldValue.arrayRemove([currentUserId]),
      });

      return true;
    } catch (error) {
      print('Remove friend error: $error');
      return false;
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + 'z')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (error) {
      print('Search users error: $error');
      return [];
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(usersCollection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (error) {
      print('Get user error: $error');
      return null;
    }
  }

  // Get multiple users by IDs
  Future<List<UserModel>> getUsers(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];
      
      List<UserModel> users = [];
      
      // Firestore has a limit of 10 for 'whereIn' queries
      for (int i = 0; i < userIds.length; i += 10) {
        List<String> batch = userIds.skip(i).take(10).toList();
        QuerySnapshot snapshot = await _firestore
            .collection(usersCollection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        users.addAll(snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
      }
      
      return users;
    } catch (error) {
      print('Get users error: $error');
      return [];
    }
  }

  // Notification Operations
  Future<bool> createNotification(NotificationModel notification) async {
    try {
      await _firestore.collection(notificationsCollection).add(notification.toFirestore());
      return true;
    } catch (error) {
      print('Create notification error: $error');
      return false;
    }
  }

  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(notificationsCollection)
        .where('recipientId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList());
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection(notificationsCollection).doc(notificationId).update({
        'isRead': true,
      });
      return true;
    } catch (error) {
      print('Mark notification as read error: $error');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(notificationsCollection)
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (DocumentSnapshot doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();

      return true;
    } catch (error) {
      print('Mark all notifications as read error: $error');
      return false;
    }
  }

  // Get unread notification count
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(notificationsCollection)
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (error) {
      print('Get unread notification count error: $error');
      return 0;
    }
  }
} 