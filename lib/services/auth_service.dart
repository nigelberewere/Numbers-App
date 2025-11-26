import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  AuthUser? get currentUser => _userFromFirebase(_auth.currentUser);

  // Auth state changes stream
  Stream<AuthUser?> get authStateChanges =>
      _auth.authStateChanges().map(_userFromFirebase);

  // Helper to map Firebase User to AuthUser
  AuthUser? _userFromFirebase(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  // Sign in with email and password
  Future<AuthUser?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<AuthUser?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user);
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign in with Google
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return _userFromFirebase(userCredential.user);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      if (e.toString().contains('People API')) {
        debugPrint(
          '################################################################################',
        );
        debugPrint(
          'ACTION REQUIRED: Enable People API in Google Cloud Console',
        );
        debugPrint(
          'URL: https://console.developers.google.com/apis/api/people.googleapis.com/overview',
        );
        debugPrint(
          '################################################################################',
        );
      }
      return null;
    }
  }
}
