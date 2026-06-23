import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> createUserProfile(UserProfile profile) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(profile.uid)
        .set(profile.toMap());
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (doc.exists) {
      return UserProfile.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(profile.uid)
        .update(profile.toMap());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    final uid = currentUserId;
    if (uid != null) {
      await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
    }
    await _auth.currentUser?.delete();
  }
}
