import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../../core/utils/logger.dart';

/// Authentication state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState.initial()) {
    _init();
  }

  final AuthService _authService = AuthService.instance;

  /// Initialize authentication state listener
  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _loadUserData(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(User firebaseUser) async {
    try {
      state = AuthState.loading(user: state.user);

      final userDoc = await FirebaseService.getUserDocument(firebaseUser.uid).get();
      
      if (userDoc.exists) {
        final userModel = UserModel.fromFirestore(userDoc);
        state = AuthState.authenticated(user: userModel);
        AppLogger.info('User data loaded successfully');
      } else {
        // Create user document if it doesn't exist
        await FirebaseService.createUserDocument(firebaseUser);
        _loadUserData(firebaseUser); // Retry loading
      }

    } catch (error) {
      AppLogger.error('Failed to load user data', error);
      state = AuthState.error(
        message: 'Failed to load user data',
        user: state.user,
      );
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = AuthState.loading(user: state.user);

      await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Email sign in failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Create account with email and password
  Future<void> createAccountWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      state = AuthState.loading(user: state.user);

      await _authService.createAccountWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Account creation failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = AuthState.loading(user: state.user);

      await _authService.signInWithGoogle();

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Google sign in failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Sign in with Apple
  Future<void> signInWithApple() async {
    try {
      state = AuthState.loading(user: state.user);

      await _authService.signInWithApple();

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Apple sign in failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Sign in anonymously
  Future<void> signInAnonymously() async {
    try {
      state = AuthState.loading(user: state.user);

      await _authService.signInAnonymously();

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Anonymous sign in failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      AppLogger.info('Password reset email sent');
    } catch (error) {
      AppLogger.error('Failed to send password reset email', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (state.user == null) return;

      state = AuthState.loading(user: state.user);

      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Reload user data
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        await _loadUserData(firebaseUser);
      }

    } catch (error) {
      AppLogger.error('Failed to update profile', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      if (state.user == null) return;

      state = AuthState.loading(user: state.user);

      await FirebaseService.getUserDocument(state.user!.uid).update({
        'preferences': preferences.toMap(),
      });

      // Update local state
      state = AuthState.authenticated(
        user: state.user!.copyWith(preferences: preferences),
      );

      AppLogger.info('User preferences updated');

    } catch (error) {
      AppLogger.error('Failed to update preferences', error);
      state = AuthState.error(
        message: FirebaseService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Link anonymous account with email
  Future<void> linkWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      if (state.user == null || !_authService.currentUser!.isAnonymous) {
        throw Exception('No anonymous account to link');
      }

      state = AuthState.loading(user: state.user);

      await _authService.linkWithEmail(
        email: email,
        password: password,
      );

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Failed to link with email', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Link anonymous account with Google
  Future<void> linkWithGoogle() async {
    try {
      if (state.user == null || !_authService.currentUser!.isAnonymous) {
        throw Exception('No anonymous account to link');
      }

      state = AuthState.loading(user: state.user);

      await _authService.linkWithGoogle();

      // State will be updated by auth state listener

    } catch (error) {
      AppLogger.error('Failed to link with Google', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AuthState.unauthenticated();
    } catch (error) {
      AppLogger.error('Sign out failed', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Delete account
  Future<void> deleteAccount({String? password}) async {
    try {
      if (state.user == null) return;

      state = AuthState.loading(user: state.user);

      await _authService.deleteAccount(password: password);

      state = const AuthState.unauthenticated();

    } catch (error) {
      AppLogger.error('Failed to delete account', error);
      state = AuthState.error(
        message: _authService.getErrorMessage(error),
        user: state.user,
      );
    }
  }

  /// Clear error state
  void clearError() {
    if (state.isError) {
      if (state.user != null) {
        state = AuthState.authenticated(user: state.user!);
      } else {
        state = const AuthState.unauthenticated();
      }
    }
  }
}

/// Authentication state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  const AuthState._({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  const AuthState.initial() : this._();

  const AuthState.loading({UserModel? user}) 
      : this._(user: user, isLoading: true);

  const AuthState.authenticated({required UserModel user})
      : this._(user: user, isAuthenticated: true);

  const AuthState.unauthenticated() : this._();

  const AuthState.error({
    required String message,
    UserModel? user,
  }) : this._(user: user, errorMessage: message);

  bool get isError => errorMessage != null;
  bool get isInitial => !isLoading && !isAuthenticated && !isError;

  @override
  String toString() {
    return 'AuthState('
        'user: ${user?.uid}, '
        'isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, '
        'errorMessage: $errorMessage'
        ')';
  }
}

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Provider to get current user
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

/// Provider to check if auth is loading
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Provider to get auth error message
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).errorMessage;
});
