import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_manager/core/app_constants.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current user
  User? get currentUser => _firebaseAuth.currentUser;
  bool get isLoggedIn => currentUser != null;
  
  // Auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _createUserDocument(credential.user!);
      
      return credential;
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Create user document in Firestore
  Future<void> _createUserDocument(User user) async {
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Create default settings document
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .collection(AppConstants.settingsCollection)
        .doc('preferences')
        .set({
          AppConstants.themeKey: 'system',
          AppConstants.languageKey: AppConstants.defaultLanguage,
        });
  }
  
  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Get user settings
  Future<Map<String, dynamic>> getUserSettings() async {
    if (currentUser == null) {
      return {
        AppConstants.themeKey: 'system',
        AppConstants.languageKey: AppConstants.defaultLanguage,
      };
    }
    
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser!.uid)
          .collection(AppConstants.settingsCollection)
          .doc('preferences')
          .get();
          
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      
      return {
        AppConstants.themeKey: 'system',
        AppConstants.languageKey: AppConstants.defaultLanguage,
      };
    } catch (e) {
      print('Error getting user settings: $e');
      return {
        AppConstants.themeKey: 'system',
        AppConstants.languageKey: AppConstants.defaultLanguage,
      };
    }
  }
  
  // Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (currentUser == null) return;
    
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser!.uid)
          .collection(AppConstants.settingsCollection)
          .doc('preferences')
          .set(settings, SetOptions(merge: true));
    } catch (e) {
      print('Error updating user settings: $e');
      throw Exception('Failed to update settings');
    }
  }
  
  // Handle authentication errors
  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email');
        case 'wrong-password':
          return Exception('Wrong password');
        case 'email-already-in-use':
          return Exception('Email is already in use');
        case 'weak-password':
          return Exception('Password is too weak');
        case 'invalid-email':
          return Exception('Invalid email format');
        case 'user-disabled':
          return Exception('This account has been disabled');
        case 'operation-not-allowed':
          return Exception('Operation not allowed');
        case 'too-many-requests':
          return Exception('Too many attempts. Try again later');
        default:
          return Exception('Authentication error: ${e.message}');
      }
    }
    return Exception('Authentication error occurred');
  }
} 