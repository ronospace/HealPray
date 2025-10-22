import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';

import 'firebase_service.dart';
import '../../core/utils/logger.dart';
import '../../core/config/app_config.dart';

// Mock User class for development mode
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final bool isAnonymous;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.isAnonymous = false,
  });
}

// Mock UserCredential class for development mode
class MockUserCredential {
  final MockUser? user;

  MockUserCredential({this.user});
}

// Custom exception for development mode authentication
class _DevelopmentModeException implements Exception {
  final String message;
  _DevelopmentModeException(this.message);

  @override
  String toString() => 'DevelopmentModeException: $message';
}

/// Authentication service handling all auth methods
class AuthService {
  AuthService._();

  static final _instance = AuthService._();
  static AuthService get instance => _instance;

  FirebaseAuth? _auth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isFirebaseAvailable = false;

  // Development mode user tracking
  MockUser? _developmentUser;
  final _developmentAuthStream = StreamController<MockUser?>.broadcast();

  // Initialize Firebase Auth safely
  void _initializeFirebaseAuth() {
    if (_auth != null) return; // Already initialized

    try {
      _auth = FirebaseAuth.instance;
      _isFirebaseAvailable = true;
    } catch (e) {
      AppLogger.warning('Firebase Auth not available in development mode: $e');
      _isFirebaseAvailable = false;
    }
  }

  // Helper to check if Firebase is available and throw appropriate error
  void _requireFirebase() {
    _initializeFirebaseAuth();
    if (!_isFirebaseAvailable || _auth == null) {
      throw FirebaseAuthException(
        code: 'firebase-not-available',
        message: 'Firebase Auth is not available. Running in development mode.',
      );
    }
  }

  /// Get current user
  User? get currentUser {
    if (AppConfig.isDevelopment && _developmentUser != null) {
      // In development mode, we can't return MockUser as User
      // This is a limitation - we'll handle this in the UI layer
      return null; // But we track development user separately
    }

    try {
      _requireFirebase();
      return _auth!.currentUser;
    } catch (e) {
      return null; // No user in development mode
    }
  }

  /// Get current development user (development mode only)
  MockUser? get currentDevelopmentUser {
    return AppConfig.isDevelopment ? _developmentUser : null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    // In development mode, check if we have a development user
    if (AppConfig.isDevelopment) {
      return _developmentUser != null;
    }

    try {
      _requireFirebase();
      return _auth!.currentUser != null;
    } catch (e) {
      return false; // No authenticated user when Firebase unavailable
    }
  }

  /// Get authentication state stream
  Stream<User?> get authStateChanges {
    if (AppConfig.isDevelopment) {
      // In development mode, we can't emit MockUser as User
      // The UI will use isDevelopmentAuthenticated instead
      return Stream.value(null);
    }

    try {
      _requireFirebase();
      return _auth!.authStateChanges();
    } catch (e) {
      // Return a stream that emits null when Firebase unavailable
      return Stream.value(null);
    }
  }

  /// Get development authentication state stream
  Stream<MockUser?> get developmentAuthStateChanges {
    return _developmentAuthStream.stream;
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting email sign in for: $email');

      // Development mode bypass
      if (AppConfig.isDevelopment) {
        return await _signInDevelopmentAccount(
          email: email,
          password: password,
        );
      }

      _requireFirebase();

      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppLogger.userAuthenticated(
        userId: credential.user?.uid ?? 'unknown',
        method: 'email',
      );

      // Update last sign in time
      await _updateUserLastSignIn(credential.user);

      return credential;
    } catch (error) {
      AppLogger.error('Email sign in failed', error);
      rethrow;
    }
  }

  /// Create account with email and password
  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      AppLogger.info('Creating account for: $email');

      // Development mode bypass
      if (AppConfig.isDevelopment) {
        return await _createDevelopmentAccount(
          email: email,
          password: password,
          displayName: displayName,
        );
      }

      _requireFirebase();

      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        await credential.user!.reload();
      }

      AppLogger.userAuthenticated(
        userId: credential.user?.uid ?? 'unknown',
        method: 'email',
      );

      // Create user document in Firestore
      if (credential.user != null) {
        await FirebaseService.createUserDocument(credential.user!);
      }

      return credential;
    } catch (error) {
      AppLogger.error('Account creation failed', error);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      AppLogger.info('Attempting Google sign in');
      _requireFirebase();

      // Trigger the authentication flow
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign in was aborted by user',
        );
      }

      // Obtain the auth details from the request
      final googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth!.signInWithCredential(credential);

      AppLogger.userAuthenticated(
        userId: userCredential.user?.uid ?? 'unknown',
        method: 'google',
      );

      // Create or update user document
      if (userCredential.user != null) {
        await _handleNewUser(userCredential.user!);
      }

      return userCredential;
    } catch (error) {
      AppLogger.error('Google sign in failed', error);

      // Sign out from Google on error to prevent stuck state
      await _googleSignIn.signOut();

      rethrow;
    }
  }

  /// Sign in with Apple
  Future<UserCredential> signInWithApple() async {
    try {
      AppLogger.info('Attempting Apple sign in');
      _requireFirebase();

      // Check if Apple Sign In is available
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw FirebaseAuthException(
          code: 'apple-signin-not-available',
          message: 'Apple Sign In is not available on this device',
        );
      }

      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple ID credential
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create OAuth credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Sign in to Firebase
      final userCredential = await _auth!.signInWithCredential(oauthCredential);

      AppLogger.userAuthenticated(
        userId: userCredential.user?.uid ?? 'unknown',
        method: 'apple',
      );

      // Update display name from Apple if available and not already set
      if (userCredential.user != null) {
        await _updateAppleUserInfo(userCredential.user!, appleCredential);
        await _handleNewUser(userCredential.user!);
      }

      return userCredential;
    } catch (error) {
      AppLogger.error('Apple sign in failed', error);
      rethrow;
    }
  }

  /// Sign in anonymously
  Future<UserCredential> signInAnonymously() async {
    try {
      AppLogger.info('Attempting anonymous sign in');
      _requireFirebase();

      final credential = await _auth!.signInAnonymously();

      AppLogger.userAuthenticated(
        userId: credential.user?.uid ?? 'unknown',
        method: 'anonymous',
      );

      // Create user document for anonymous user
      if (credential.user != null) {
        await FirebaseService.createUserDocument(credential.user!);
      }

      return credential;
    } catch (error) {
      AppLogger.error('Anonymous sign in failed', error);
      rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.info('Sending password reset email to: $email');
      _requireFirebase();

      await _auth!.sendPasswordResetEmail(email: email);

      AppLogger.info('Password reset email sent successfully');
    } catch (error) {
      AppLogger.error('Failed to send password reset email', error);
      rethrow;
    }
  }

  /// Change password for current user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _requireFirebase();
      final user = _auth!.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No authenticated user found',
        );
      }

      if (user.email == null) {
        throw FirebaseAuthException(
          code: 'invalid-user',
          message: 'Cannot change password for this user type',
        );
      }

      AppLogger.info('Changing password for user: ${user.uid}');

      // Re-authenticate user first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      AppLogger.info('Password changed successfully');
    } catch (error) {
      AppLogger.error('Failed to change password', error);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _requireFirebase();
      final user = _auth!.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No authenticated user found',
        );
      }

      AppLogger.info('Updating profile for user: ${user.uid}');

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      AppLogger.info('Profile updated successfully');
    } catch (error) {
      AppLogger.error('Failed to update profile', error);
      rethrow;
    }
  }

  /// Delete user account
  Future<void> deleteAccount({String? password}) async {
    try {
      _requireFirebase();
      final user = _auth!.currentUser;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No authenticated user found',
        );
      }

      AppLogger.warning('Deleting account for user: ${user.uid}');

      // Re-authenticate for sensitive operation
      if (password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      // Delete user document from Firestore first
      await FirebaseService.firestore.doc('users/${user.uid}').delete();

      // Delete Firebase auth account
      await user.delete();

      AppLogger.warning('Account deleted successfully');
    } catch (error) {
      AppLogger.error('Failed to delete account', error);
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      AppLogger.info('Signing out user');

      // Handle development mode sign out
      if (AppConfig.isDevelopment) {
        _signOutDevelopmentUser();
        AppLogger.info('Development user signed out successfully');
        return;
      }

      _requireFirebase();

      // Sign out from all providers
      await _auth!.signOut();
      await _googleSignIn.signOut();

      AppLogger.info('User signed out successfully');
    } catch (error) {
      AppLogger.error('Sign out failed', error);
      rethrow;
    }
  }

  /// Link anonymous account with email/password
  Future<UserCredential> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _requireFirebase();
      final user = _auth!.currentUser;
      if (user == null || !user.isAnonymous) {
        throw FirebaseAuthException(
          code: 'invalid-user',
          message: 'No anonymous user to link',
        );
      }

      AppLogger.info('Linking anonymous account with email: $email');

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final userCredential = await user.linkWithCredential(credential);

      AppLogger.info('Anonymous account linked with email successfully');

      // Update user document
      await _updateUserLastSignIn(userCredential.user);

      return userCredential;
    } catch (error) {
      AppLogger.error('Failed to link with email', error);
      rethrow;
    }
  }

  /// Link anonymous account with Google
  Future<UserCredential> linkWithGoogle() async {
    try {
      _requireFirebase();
      final user = _auth!.currentUser;
      if (user == null || !user.isAnonymous) {
        throw FirebaseAuthException(
          code: 'invalid-user',
          message: 'No anonymous user to link',
        );
      }

      AppLogger.info('Linking anonymous account with Google');

      // Get Google credential
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'aborted-by-user',
          message: 'Google sign in was aborted by user',
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Link accounts
      final userCredential = await user.linkWithCredential(credential);

      AppLogger.info('Anonymous account linked with Google successfully');

      // Update user document
      await _updateUserLastSignIn(userCredential.user);

      return userCredential;
    } catch (error) {
      AppLogger.error('Failed to link with Google', error);
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  /// Handle new user creation or first-time sign in
  Future<void> _handleNewUser(User user) async {
    try {
      // Check if this is a new user by looking for existing document
      final userDoc =
          await FirebaseService.firestore.doc('users/${user.uid}').get();

      if (!userDoc.exists) {
        // New user - create document
        await FirebaseService.createUserDocument(user);
      } else {
        // Existing user - update last sign in
        await _updateUserLastSignIn(user);
      }
    } catch (error) {
      AppLogger.error('Failed to handle new user', error);
    }
  }

  /// Update user's last sign in time
  Future<void> _updateUserLastSignIn(User? user) async {
    if (user == null) return;

    try {
      await FirebaseService.firestore.doc('users/${user.uid}').update({
        'lastSignIn': Timestamp.now(),
      });
    } catch (error) {
      AppLogger.error('Failed to update last sign in', error);
    }
  }

  /// Update Apple user info from credential
  Future<void> _updateAppleUserInfo(
      User user, AuthorizationCredentialAppleID appleCredential) async {
    try {
      // Apple Sign In doesn't always provide name information
      // The fullName property is not available in newer versions of the API
      // so we'll skip setting the display name for Apple users
      AppLogger.info(
          'Apple user info processed (name not available from credential)');
    } catch (error) {
      AppLogger.error('Failed to update Apple user info', error);
    }
  }

  /// Generate a cryptographically secure nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Generate SHA256 hash of string
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get user-friendly error message
  String getErrorMessage(dynamic error) {
    return FirebaseService.getErrorMessage(error);
  }

  // Development mode helper methods

  /// Create development account (bypasses Firebase)
  Future<UserCredential> _createDevelopmentAccount({
    required String email,
    required String password,
    String? displayName,
  }) async {
    AppLogger.info('🔧 Creating development account for: $email');

    // Generate a mock user ID
    final uid = 'dev_${email.replaceAll('@', '_at_').replaceAll('.', '_')}';

    final mockUser = MockUser(
      uid: uid,
      email: email,
      displayName: displayName ?? email.split('@')[0],
      isAnonymous: false,
    );

    // Store the development user
    _developmentUser = mockUser;
    _developmentAuthStream.add(mockUser);

    AppLogger.userAuthenticated(
      userId: uid,
      method: 'email-development',
    );

    AppLogger.info('🔧 Development account created successfully');

    // In development mode, we don't return a real UserCredential
    // The authentication state will be handled by the development auth stream
    // We need to throw a specific exception that the AuthProvider will handle
    throw _DevelopmentModeException('Development account created successfully');
  }

  /// Sign in to development account (bypasses Firebase)
  Future<UserCredential> _signInDevelopmentAccount({
    required String email,
    required String password,
  }) async {
    AppLogger.info('🔧 Signing in to development account: $email');

    // For simplicity, always allow sign-in with any email/password in development
    // In a real scenario, you might want to store and validate credentials
    final uid = 'dev_${email.replaceAll('@', '_at_').replaceAll('.', '_')}';

    final mockUser = MockUser(
      uid: uid,
      email: email,
      displayName: email.split('@')[0],
      isAnonymous: false,
    );

    // Store the development user
    _developmentUser = mockUser;
    _developmentAuthStream.add(mockUser);

    AppLogger.userAuthenticated(
      userId: uid,
      method: 'email-development',
    );

    AppLogger.info('🔧 Development sign-in successful');

    // Throw development mode exception to signal successful development auth
    throw _DevelopmentModeException('Development sign-in successful');
  }

  /// Sign out development user
  void _signOutDevelopmentUser() {
    if (_developmentUser != null) {
      AppLogger.info(
          '🔧 Signing out development user: ${_developmentUser!.email}');
      _developmentUser = null;
      _developmentAuthStream.add(null);
    }
  }
}
