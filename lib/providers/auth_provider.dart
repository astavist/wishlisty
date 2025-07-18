import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuthState();
  }

  void _initializeAuthState() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

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

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      UserModel? user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to sign in');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      _setLoading(true);
      _setError(null);

      UserModel? user = await _authService.registerWithEmailAndPassword(
          email, password, displayName);
      
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create account');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);

      UserModel? user = await _authService.signInWithGoogle();
      
      if (user != null) {
        _currentUser = user;
        _setLoading(false);
        return true;
      } else {
        _setError('Google sign in cancelled');
        _setLoading(false);
        return false;
      }
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _setLoading(false);
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      if (_currentUser == null) return false;

      _setLoading(true);
      _setError(null);

      bool success = await _authService.updateUserProfile(
        uid: _currentUser!.id,
        displayName: displayName,
        photoURL: photoURL,
        bio: bio,
      );

      if (success) {
        // Update local user data
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          photoURL: photoURL ?? _currentUser!.photoURL,
          bio: bio ?? _currentUser!.bio,
        );
      }

      _setLoading(false);
      return success;
    } catch (error) {
      _setError(_getErrorMessage(error));
      _setLoading(false);
      return false;
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    return await _authService.checkEmailExists(email);
  }

  // Update current user data
  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  // Convert error to user-friendly message
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account with this email already exists.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'too-many-requests':
          return 'Too many requests. Please try again later.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return 'An authentication error occurred.';
      }
    }
    return error.toString();
  }
} 