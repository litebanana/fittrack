import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/user_profile.dart';
import '../data/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserProfile? _userProfile;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  String? get userId => _authService.currentUserId;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) async {
      if (user != null) {
        await _loadUserProfile(user.uid);
      } else {
        _status = AuthStatus.unauthenticated;
        _userProfile = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _userProfile = await _authService.getUserProfile(uid);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading();
    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
    required String fitnessGoal,
    required String gender,
  }) async {
    _setLoading();
    try {
      final credential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final profile = UserProfile(
        uid: credential.user!.uid,
        name: name,
        email: email,
        age: age,
        height: height,
        weight: weight,
        fitnessGoal: fitnessGoal,
        gender: gender,
      );

      await _authService.createUserProfile(profile);
      _userProfile = profile;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _setLoading();
    try {
      await _authService.sendPasswordResetEmail(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_authErrorMessage(e.code));
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<bool> updateProfile(UserProfile profile) async {
    try {
      await _authService.updateUserProfile(profile);
      _userProfile = profile;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update profile');
      return false;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}
