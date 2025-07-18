import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<UserModel> _friends = [];
  List<UserModel> _friendRequests = [];
  List<UserModel> _sentRequests = [];
  List<UserModel> _searchResults = [];
  List<NotificationModel> _notifications = [];
  int _unreadNotificationCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get friends => _friends;
  List<UserModel> get friendRequests => _friendRequests;
  List<UserModel> get sentRequests => _sentRequests;
  List<UserModel> get searchResults => _searchResults;
  List<NotificationModel> get notifications => _notifications;
  int get unreadNotificationCount => _unreadNotificationCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Load user's friends, friend requests, and sent requests
  Future<void> loadUserRelationships(UserModel currentUser) async {
    try {
      _setLoading(true);

      // Load friends
      if (currentUser.friends.isNotEmpty) {
        _friends = await _firestoreService.getUsers(currentUser.friends);
      } else {
        _friends = [];
      }

      // Load friend requests
      if (currentUser.friendRequests.isNotEmpty) {
        _friendRequests = await _firestoreService.getUsers(currentUser.friendRequests);
      } else {
        _friendRequests = [];
      }

      // Load sent requests
      if (currentUser.sentRequests.isNotEmpty) {
        _sentRequests = await _firestoreService.getUsers(currentUser.sentRequests);
      } else {
        _sentRequests = [];
      }

      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Load notifications
  void loadNotifications(String userId) {
    _firestoreService.getUserNotifications(userId).listen((notifications) {
      _notifications = notifications;
      _unreadNotificationCount = notifications.where((notification) => !notification.isRead).length;
      notifyListeners();
    });
  }

  // Search users
  Future<void> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        _searchResults = [];
        notifyListeners();
        return;
      }

      _setLoading(true);
      _setError(null);

      List<UserModel> results = await _firestoreService.searchUsers(query.trim());
      _searchResults = results;

      _setLoading(false);
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String currentUserId, String targetUserId, String currentUserName) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.sendFriendRequest(currentUserId, targetUserId);
      
      if (success) {
        // Create notification for the target user
        NotificationModel notification = NotificationModel.friendRequest(
          recipientId: targetUserId,
          senderId: currentUserId,
          senderName: currentUserName,
        );
        await _firestoreService.createNotification(notification);

        // Update local state
        UserModel? targetUser = _searchResults.firstWhere(
          (user) => user.id == targetUserId,
          orElse: () => UserModel(
            id: targetUserId,
            email: '',
            displayName: 'Unknown User',
            friends: [],
            friendRequests: [],
            sentRequests: [],
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
            notificationSettings: {},
          ),
        );
        
        if (!_sentRequests.any((user) => user.id == targetUserId)) {
          _sentRequests.add(targetUser);
        }
      } else {
        _setError('Failed to send friend request');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String currentUserId, String fromUserId, String currentUserName) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.acceptFriendRequest(currentUserId, fromUserId);
      
      if (success) {
        // Create notification for the request sender
        NotificationModel notification = NotificationModel.friendAccepted(
          recipientId: fromUserId,
          senderId: currentUserId,
          senderName: currentUserName,
        );
        await _firestoreService.createNotification(notification);

        // Update local state
        UserModel? acceptedUser = _friendRequests.firstWhere(
          (user) => user.id == fromUserId,
          orElse: () => UserModel(
            id: fromUserId,
            email: '',
            displayName: 'Unknown User',
            friends: [],
            friendRequests: [],
            sentRequests: [],
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
            notificationSettings: {},
          ),
        );

        // Move from friend requests to friends
        _friendRequests.removeWhere((user) => user.id == fromUserId);
        if (!_friends.any((user) => user.id == fromUserId)) {
          _friends.add(acceptedUser);
        }
      } else {
        _setError('Failed to accept friend request');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String currentUserId, String fromUserId) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.rejectFriendRequest(currentUserId, fromUserId);
      
      if (success) {
        // Update local state
        _friendRequests.removeWhere((user) => user.id == fromUserId);
      } else {
        _setError('Failed to reject friend request');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String currentUserId, String friendId) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.removeFriend(currentUserId, friendId);
      
      if (success) {
        // Update local state
        _friends.removeWhere((user) => user.id == friendId);
      } else {
        _setError('Failed to remove friend');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      return await _firestoreService.getUser(userId);
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  // Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      bool success = await _firestoreService.markNotificationAsRead(notificationId);
      
      if (success) {
        // Update local state
        for (int i = 0; i < _notifications.length; i++) {
          if (_notifications[i].id == notificationId) {
            _notifications[i] = _notifications[i].copyWith(isRead: true);
            break;
          }
        }
        _unreadNotificationCount = _notifications.where((notification) => !notification.isRead).length;
        notifyListeners();
      }

      return success;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      bool success = await _firestoreService.markAllNotificationsAsRead(userId);
      
      if (success) {
        // Update local state
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        _unreadNotificationCount = 0;
        notifyListeners();
      }

      return success;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Check relationship status with a user
  UserRelationship getRelationshipStatus(String currentUserId, String targetUserId) {
    if (currentUserId == targetUserId) {
      return UserRelationship.self;
    }

    if (_friends.any((user) => user.id == targetUserId)) {
      return UserRelationship.friend;
    }

    if (_friendRequests.any((user) => user.id == targetUserId)) {
      return UserRelationship.pendingReceived;
    }

    if (_sentRequests.any((user) => user.id == targetUserId)) {
      return UserRelationship.pendingSent;
    }

    return UserRelationship.none;
  }

  // Get friend IDs for loading wishes
  List<String> getFriendIds() {
    return _friends.map((friend) => friend.id).toList();
  }

  // Get user by name (for mentions, etc.)
  UserModel? getUserByDisplayName(String displayName) {
    // Search in friends first
    for (UserModel friend in _friends) {
      if (friend.displayName.toLowerCase() == displayName.toLowerCase()) {
        return friend;
      }
    }

    // Then search in search results
    for (UserModel user in _searchResults) {
      if (user.displayName.toLowerCase() == displayName.toLowerCase()) {
        return user;
      }
    }

    return null;
  }

  // Filter friends by name
  List<UserModel> filterFriends(String query) {
    if (query.trim().isEmpty) return _friends;
    
    return _friends.where((friend) =>
        friend.displayName.toLowerCase().contains(query.toLowerCase()) ||
        friend.email.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Sort friends
  List<UserModel> sortFriends(List<UserModel> friends, String sortBy) {
    List<UserModel> sortedFriends = List.from(friends);
    
    switch (sortBy.toLowerCase()) {
      case 'name':
        sortedFriends.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case 'recent':
        sortedFriends.sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
        break;
      case 'oldest':
        sortedFriends.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    
    return sortedFriends;
  }
}

enum UserRelationship {
  self,
  friend,
  pendingReceived, // They sent us a request
  pendingSent,     // We sent them a request
  none,
} 