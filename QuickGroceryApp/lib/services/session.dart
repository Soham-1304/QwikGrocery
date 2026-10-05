import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'api_exception.dart';

class SessionController extends ChangeNotifier {
  SessionController({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance {
    _authSubscription = _auth.authStateChanges().listen(
      (_) {
        _isInitialized = true;
        notifyListeners();
      },
    );
  }

  final FirebaseAuth _auth;
  late final StreamSubscription<User?> _authSubscription;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  bool get signedIn => _auth.currentUser != null;
  String? get uid => _auth.currentUser?.uid;
  String? get email => _auth.currentUser?.email;

  Future<String?> get token async => _auth.currentUser?.getIdToken();
  Future<bool> get isStaff async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final result = await user.getIdTokenResult(true);
    return result.claims?['staff'] == true;
  }

  Future<void> register(
    String name,
    String emailAddress,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      throw ApiException(_messageFor(error), statusCode: _statusFor(error));
    }
  }

  Future<void> signIn(String emailAddress, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailAddress.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw ApiException(_messageFor(error), statusCode: _statusFor(error));
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        await _auth.signInWithPopup(GoogleAuthProvider());
        return;
      }

      final googleSignIn = GoogleSignIn(
        serverClientId:
            '563192241880-arpuhe79sg5mke4rkkf7miah9skicukt.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (error) {
      throw ApiException(_messageFor(error), statusCode: _statusFor(error));
    } catch (error) {
      final msg = error.toString();
      throw ApiException(
        msg.contains('ApiException: 10') || msg.contains('sign_in_failed')
            ? 'Google Sign-In on Android requires registering SHA-1 in Firebase Console. Please sign in with Email & Password or add your SHA-1.'
            : (error is Exception
                ? error.toString().replaceAll('Exception: ', '')
                : 'Google sign-in could not be completed.'),
      );
    }
  }

  Future<void> signOut() => _auth.signOut();

  static String _messageFor(
    FirebaseAuthException error,
  ) => switch (error.code) {
    'email-already-in-use' => 'An account with this email already exists.',
    'invalid-email' => 'Enter a valid email address.',
    'weak-password' => 'Choose a stronger password.',
    'user-not-found' => 'No account was found for that email.',
    'wrong-password' ||
    'invalid-credential' => 'The email or password is incorrect.',
    'user-disabled' => 'This account is disabled.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    'operation-not-allowed' =>
      'Email and password sign-in is not enabled for this Firebase project.',
    'network-request-failed' => 'Check your internet connection and try again.',
    _ => error.message ?? 'Authentication could not be completed.',
  };

  static int? _statusFor(FirebaseAuthException error) => switch (error.code) {
    'user-not-found' || 'wrong-password' || 'invalid-credential' => 401,
    'too-many-requests' => 429,
    'network-request-failed' => 503,
    _ => 400,
  };

  @override
  void dispose() {
    unawaited(_authSubscription.cancel());
    super.dispose();
  }
}
