import 'package:flutter/material.dart';
import '../models/wish_model.dart';
import '../services/firestore_service.dart';

class WishProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<WishModel> _userWishes = [];
  List<WishModel> _friendsWishes = [];
  WishModel? _selectedWish;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WishModel> get userWishes => _userWishes;
  List<WishModel> get friendsWishes => _friendsWishes;
  WishModel? get selectedWish => _selectedWish;
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

  // Load user's wishes
  void loadUserWishes(String userId) {
    _firestoreService.getUserWishes(userId).listen((wishes) {
      _userWishes = wishes;
      notifyListeners();
    });
  }

  // Load friends' wishes
  void loadFriendsWishes(List<String> friendIds) {
    _firestoreService.getFriendsWishes(friendIds).listen((wishes) {
      _friendsWishes = wishes;
      notifyListeners();
    });
  }

  // Create new wish
  Future<bool> createWish({
    required String userId,
    required String title,
    required String description,
    String? imageUrl,
    String? productUrl,
    double? price,
    String? currency,
    required String category,
    int priority = 3,
    bool isPublic = true,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      WishModel newWish = WishModel(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        description: description,
        imageUrl: imageUrl,
        productUrl: productUrl,
        price: price,
        currency: currency ?? 'USD',
        category: category,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likes: [],
        comments: [],
        pins: [],
        isPublic: isPublic,
        metadata: {},
      );

      String? wishId = await _firestoreService.createWish(newWish);
      
      if (wishId != null) {
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create wish');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update wish
  Future<bool> updateWish(String wishId, Map<String, dynamic> updateData) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.updateWish(wishId, updateData);
      
      if (success) {
        // Update local data if the wish is in our lists
        _updateLocalWishData(wishId, updateData);
      } else {
        _setError('Failed to update wish');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete wish
  Future<bool> deleteWish(String wishId) async {
    try {
      _setLoading(true);
      _setError(null);

      bool success = await _firestoreService.deleteWish(wishId);
      
      if (success) {
        // Remove from local lists
        _userWishes.removeWhere((wish) => wish.id == wishId);
        _friendsWishes.removeWhere((wish) => wish.id == wishId);
        if (_selectedWish?.id == wishId) {
          _selectedWish = null;
        }
        notifyListeners();
      } else {
        _setError('Failed to delete wish');
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(error.toString());
      _setLoading(false);
      return false;
    }
  }

  // Like/Unlike wish
  Future<bool> toggleWishLike(String wishId, String userId) async {
    try {
      WishModel? wish = _getWishById(wishId);
      if (wish == null) return false;

      bool isLiked = wish.likes.contains(userId);
      bool success;

      if (isLiked) {
        success = await _firestoreService.unlikeWish(wishId, userId);
      } else {
        success = await _firestoreService.likeWish(wishId, userId);
      }

      if (success) {
        // Update local data optimistically
        _updateLocalLikes(wishId, userId, !isLiked);
      }

      return success;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // Pin/Unpin wish (secret from owner)
  Future<bool> toggleWishPin(String wishId, String userId, {String? note}) async {
    try {
      WishModel? wish = _getWishById(wishId);
      if (wish == null) return false;

      // Don't allow users to pin their own wishes
      if (wish.userId == userId) return false;

      bool isPinned = wish.isPinnedBy(userId);
      bool success;

      if (isPinned) {
        success = await _firestoreService.unpinWish(wishId, userId);
      } else {
        success = await _firestoreService.pinWish(wishId, userId, note: note);
      }

      return success;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // Add comment to wish
  Future<bool> addComment(String wishId, String userId, String content) async {
    try {
      bool success = await _firestoreService.addComment(wishId, userId, content);
      return success;
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // Get wish by ID
  Future<WishModel?> getWish(String wishId) async {
    try {
      return await _firestoreService.getWish(wishId);
    } catch (error) {
      _setError(error.toString());
      return null;
    }
  }

  // Set selected wish
  void setSelectedWish(WishModel? wish) {
    _selectedWish = wish;
    notifyListeners();
  }

  // Filter wishes by category
  List<WishModel> filterWishesByCategory(List<WishModel> wishes, String category) {
    if (category.toLowerCase() == 'all') return wishes;
    return wishes.where((wish) => wish.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Search wishes
  List<WishModel> searchWishes(List<WishModel> wishes, String query) {
    if (query.isEmpty) return wishes;
    return wishes.where((wish) =>
        wish.title.toLowerCase().contains(query.toLowerCase()) ||
        wish.description.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Sort wishes
  List<WishModel> sortWishes(List<WishModel> wishes, String sortBy) {
    List<WishModel> sortedWishes = List.from(wishes);
    
    switch (sortBy.toLowerCase()) {
      case 'newest':
        sortedWishes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        sortedWishes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'price_high':
        sortedWishes.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
        break;
      case 'price_low':
        sortedWishes.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'priority':
        sortedWishes.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case 'popularity':
        sortedWishes.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
    }
    
    return sortedWishes;
  }

  // Helper methods
  WishModel? _getWishById(String wishId) {
    // Try to find in user wishes first
    for (WishModel wish in _userWishes) {
      if (wish.id == wishId) return wish;
    }
    // Then try friends wishes
    for (WishModel wish in _friendsWishes) {
      if (wish.id == wishId) return wish;
    }
    return null;
  }

  void _updateLocalWishData(String wishId, Map<String, dynamic> updateData) {
    // Update in user wishes
    for (int i = 0; i < _userWishes.length; i++) {
      if (_userWishes[i].id == wishId) {
        // Create updated wish with new data
        _userWishes[i] = _userWishes[i].copyWith(
          title: updateData['title'] ?? _userWishes[i].title,
          description: updateData['description'] ?? _userWishes[i].description,
          imageUrl: updateData['imageUrl'] ?? _userWishes[i].imageUrl,
          productUrl: updateData['productUrl'] ?? _userWishes[i].productUrl,
          price: updateData['price'] ?? _userWishes[i].price,
          category: updateData['category'] ?? _userWishes[i].category,
          priority: updateData['priority'] ?? _userWishes[i].priority,
          isPublic: updateData['isPublic'] ?? _userWishes[i].isPublic,
        );
        break;
      }
    }

    // Update in friends wishes
    for (int i = 0; i < _friendsWishes.length; i++) {
      if (_friendsWishes[i].id == wishId) {
        _friendsWishes[i] = _friendsWishes[i].copyWith(
          title: updateData['title'] ?? _friendsWishes[i].title,
          description: updateData['description'] ?? _friendsWishes[i].description,
          imageUrl: updateData['imageUrl'] ?? _friendsWishes[i].imageUrl,
          productUrl: updateData['productUrl'] ?? _friendsWishes[i].productUrl,
          price: updateData['price'] ?? _friendsWishes[i].price,
          category: updateData['category'] ?? _friendsWishes[i].category,
          priority: updateData['priority'] ?? _friendsWishes[i].priority,
          isPublic: updateData['isPublic'] ?? _friendsWishes[i].isPublic,
        );
        break;
      }
    }

    // Update selected wish if it's the same
    if (_selectedWish?.id == wishId) {
      _selectedWish = _selectedWish!.copyWith(
        title: updateData['title'] ?? _selectedWish!.title,
        description: updateData['description'] ?? _selectedWish!.description,
        imageUrl: updateData['imageUrl'] ?? _selectedWish!.imageUrl,
        productUrl: updateData['productUrl'] ?? _selectedWish!.productUrl,
        price: updateData['price'] ?? _selectedWish!.price,
        category: updateData['category'] ?? _selectedWish!.category,
        priority: updateData['priority'] ?? _selectedWish!.priority,
        isPublic: updateData['isPublic'] ?? _selectedWish!.isPublic,
      );
    }

    notifyListeners();
  }

  void _updateLocalLikes(String wishId, String userId, bool isLiked) {
    void updateWishLikes(WishModel wish) {
      List<String> updatedLikes = List.from(wish.likes);
      if (isLiked && !updatedLikes.contains(userId)) {
        updatedLikes.add(userId);
      } else if (!isLiked && updatedLikes.contains(userId)) {
        updatedLikes.remove(userId);
      }
      // Note: This would require implementing copyWith for likes
      // For now, we'll rely on the stream updates from Firestore
    }

    // Find and update the wish in local lists
    for (int i = 0; i < _userWishes.length; i++) {
      if (_userWishes[i].id == wishId) {
        updateWishLikes(_userWishes[i]);
        break;
      }
    }

    for (int i = 0; i < _friendsWishes.length; i++) {
      if (_friendsWishes[i].id == wishId) {
        updateWishLikes(_friendsWishes[i]);
        break;
      }
    }

    if (_selectedWish?.id == wishId) {
      updateWishLikes(_selectedWish!);
    }

    notifyListeners();
  }
} 