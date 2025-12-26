import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Getter for current user
  UserModel? get currentUser => _currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Get current Firebase user
  User? get firebaseUser => _firebaseAuth.currentUser;

  // Initialize user from Firebase
  Future<void> initializeUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _loadUserFromFirestore(user.uid);
      }
    } catch (e) {
      debugPrint('Error initializing user: $e');
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentUser = UserModel(
          uid: userId,
          email: data['email'] ?? '',
          password: '', // Don't store password
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          profession: data['profession'] ?? '',
          role: data['role'],
          rating: (data['rating'] ?? 4.8).toDouble(),
          completedJobs: data['completedJobs'] ?? 0,
          monthlyEarnings: (data['monthlyEarnings'] ?? 0).toDouble(),
          activeJobs: data['activeJobs'] ?? 0,
        );
      }
    } catch (e) {
      debugPrint('Error loading user from Firestore: $e');
    }
  }

  // Sign up user with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String profession,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email.trim(),
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'profession': profession,
        'role': '',
        'rating': 4.5,
        'completedJobs': 0,
        'monthlyEarnings': 0.0,
        'activeJobs': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Load user data
      await _loadUserFromFirestore(userCredential.user!.uid);

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': _currentUser,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Sign up failed'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign in user with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Load user data from Firestore
      await _loadUserFromFirestore(userCredential.user!.uid);

      return {
        'success': true,
        'message': 'Sign in successful',
        'user': _currentUser,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Sign in failed'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      _currentUser = null;
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return {'success': true, 'message': 'Password reset email sent'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Failed to send reset email',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Update user profile in Firestore
  Future<Map<String, dynamic>> updateUserProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profession,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser!.uid;

      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (profession != null) updateData['profession'] = profession;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updateData);

      // Reload user data
      await _loadUserFromFirestore(userId);

      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to update profile: $e'};
    }
  }

  // Update user statistics
  Future<void> updateUserStats({
    double? rating,
    int? completedJobs,
    double? monthlyEarnings,
    int? activeJobs,
  }) async {
    try {
      final userId = _firebaseAuth.currentUser!.uid;

      final updateData = <String, dynamic>{};
      if (rating != null) updateData['rating'] = rating;
      if (completedJobs != null) updateData['completedJobs'] = completedJobs;
      if (monthlyEarnings != null) {
        updateData['monthlyEarnings'] = monthlyEarnings;
      }
      if (activeJobs != null) updateData['activeJobs'] = activeJobs;
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updateData);

      // Reload user data
      await _loadUserFromFirestore(userId);
    } catch (e) {
      debugPrint('Error updating user stats: $e');
    }
  }

  // Delete user account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final userId = _firebaseAuth.currentUser!.uid;

      // Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();

      // Delete user from Firebase Auth
      await _firebaseAuth.currentUser!.delete();

      _currentUser = null;

      return {'success': true, 'message': 'Account deleted successfully'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Failed to delete account',
      };
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  // Set user role (e.g., 'User' or 'Worker') and reload profile
  Future<Map<String, dynamic>> setUserRole(String role) async {
    try {
      final userId = _firebaseAuth.currentUser!.uid;
      await _firestore.collection('users').doc(userId).update({
        'role': role,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _loadUserFromFirestore(userId);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) codeSent,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign in with credential (for Phone Auth)
  Future<Map<String, dynamic>> signInWithCredential(
    AuthCredential credential,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore, if not create basic profile
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'phoneNumber': user.phoneNumber,
            'email': '',
            'firstName': 'User', // Default
            'lastName': '',
            'profession': '',
            'role': '', // Needs selection or default
            'rating': 5.0,
            'completedJobs': 0,
            'monthlyEarnings': 0.0,
            'activeJobs': 0,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
        await _loadUserFromFirestore(user.uid);
      }

      return {
        'success': true,
        'message': 'Sign in successful',
        'user': _currentUser,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': e.message ?? 'Sign in failed'};
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }
}
