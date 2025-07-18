import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create user from Firebase User
  UserModel? _userFromFirebaseUser(User? user) {
    return user != null
        ? UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoURL: user.photoURL,
            friends: [],
            friendRequests: [],
            sentRequests: [],
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
            notificationSettings: {
              'mentions': true,
              'wishLists': true,
              'comments': true,
              'newFriendRequests': true,
              'giftPurchases': true,
            },
          )
        : null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      
      if (user != null) {
        // Update last seen
        await _updateLastSeen(user.uid);
        return await getUserData(user.uid);
      }
      return null;
    } catch (error) {
      print('Sign in error: $error');
      throw error;
    }
  }

  // Register with email and password
  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);

        // Create user document in Firestore
        UserModel newUser = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          photoURL: user.photoURL,
          friends: [],
          friendRequests: [],
          sentRequests: [],
          createdAt: DateTime.now(),
          lastSeen: DateTime.now(),
          notificationSettings: {
            'mentions': true,
            'wishLists': true,
            'comments': true,
            'newFriendRequests': true,
            'giftPurchases': true,
          },
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());

        return newUser;
      }
      return null;
    } catch (error) {
      print('Registration error: $error');
      throw error;
    }
  }

  // Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Create new user document
          UserModel newUser = UserModel(
            id: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoURL: user.photoURL,
            friends: [],
            friendRequests: [],
            sentRequests: [],
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
            notificationSettings: {
              'mentions': true,
              'wishLists': true,
              'comments': true,
              'newFriendRequests': true,
              'giftPurchases': true,
            },
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(newUser.toFirestore());
          return newUser;
        } else {
          await _updateLastSeen(user.uid);
          return UserModel.fromFirestore(userDoc);
        }
      }
      return null;
    } catch (error) {
      print('Google sign in error: $error');
      throw error;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      print('Sign out error: $error');
      throw error;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (error) {
      print('Reset password error: $error');
      throw error;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (error) {
      print('Get user data error: $error');
      return null;
    }
  }

  // Update last seen
  Future<void> _updateLastSeen(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSeen': Timestamp.fromDate(DateTime.now()),
      });
    } catch (error) {
      print('Update last seen error: $error');
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String uid,
    String? displayName,
    String? photoURL,
    String? bio,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoURL'] = photoURL;
      if (bio != null) updateData['bio'] = bio;

      await _firestore.collection('users').doc(uid).update(updateData);

      // Also update Firebase Auth profile
      if (displayName != null || photoURL != null) {
        await currentUser?.updateDisplayName(displayName);
        await currentUser?.updatePhotoURL(photoURL);
      }

      return true;
    } catch (error) {
      print('Update profile error: $error');
      return false;
    }
  }

  // Check if email exists
  Future<bool> checkEmailExists(String email) async {
    try {
      List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (error) {
      return false;
    }
  }
} 