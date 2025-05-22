import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_manager/data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, guest }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;
  
  AuthProvider(this._authRepository) {
    // Listen for auth state changes
    _authRepository.authStateChanges.listen((User? user) {
      _user = user;
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    });
  }
  
  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get isGuest => _status == AuthStatus.guest;
  Stream<User?> get authStateChanges => _authRepository.authStateChanges;
  
  // Register new user
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.createUserWithEmailAndPassword(email, password);
      _status = AuthStatus.authenticated;
      _user = _authRepository.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Login with email and password
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
      _status = AuthStatus.authenticated;
      _user = _authRepository.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Continue as guest
  void continueAsGuest() {
    _status = AuthStatus.guest;
    _clearError();
    notifyListeners();
  }
  
  // Logout
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authRepository.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authRepository.resetPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Get user settings from Firebase
  Future<Map<String, dynamic>> getUserSettings() async {
    if (_status != AuthStatus.authenticated) {
      return {};
    }
    
    try {
      return await _authRepository.getUserSettings();
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }
  
  // Update user settings
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    if (_status != AuthStatus.authenticated) return;
    
    try {
      await _authRepository.updateUserSettings(settings);
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
  }
} 