import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../services/notification_service.dart';

class AuthResult {
  final bool success;
  final String? message;

  const AuthResult(this.success, {this.message});
}

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseService.client;
  String? _currentUserId;
  String? _currentUser;
  bool _isAuthenticated = false;
  bool _initialized = false;
  late final Stream<AuthState> _authStream;

  String? get currentUserId => _currentUserId;
  String? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get initialized => _initialized;

  AuthProvider() {
    _authStream = _client.auth.onAuthStateChange;
    _authStream.listen((event) {
      final session = event.session;
      if (session?.user != null) {
        _currentUserId = session!.user.id;
        _currentUser = session.user.email;
        _isAuthenticated = true;
      } else {
        _currentUserId = null;
        _currentUser = null;
        _isAuthenticated = false;
      }
      _initialized = true;
      notifyListeners();
    });
    final current = _client.auth.currentUser;
    if (current != null) {
      _currentUserId = current.id;
      _currentUser = current.email;
      _isAuthenticated = true;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(false, message: 'Email and password are required.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      return const AuthResult(false, message: 'Please enter a valid email address.');
    }
    if (password.length < 6) {
      return const AuthResult(false, message: 'Password must be at least 6 characters.');
    }
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const AuthResult(false, message: 'Login failed.');
      }
      _currentUserId = user.id;
      _currentUser = user.email;
      _isAuthenticated = true;
      notifyListeners();
      try {
        await NotificationService.showLoginSuccess(email: _currentUser);
      } catch (e) {
        debugPrint('Login notification failed: $e');
      }
      return const AuthResult(true);
    } on AuthException catch (e) {
      String message = 'Authentication failed';
      if (e.message.contains('Invalid login credentials')) {
        message = 'Invalid email or password. Please check your credentials.';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Please check your email and confirm your account.';
      } else if (e.message.contains('Too many requests')) {
        message = 'Too many login attempts. Please try again later.';
      }
      return AuthResult(false, message: message);
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      return const AuthResult(false, message: 'Network error. Please check your connection.');
    }
  }

  Future<AuthResult> signup(String email, String password, String confirmPassword) async {
    if (email.isEmpty || password.isEmpty) {
      return const AuthResult(false, message: 'Email and password are required.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      return const AuthResult(false, message: 'Please enter a valid email address.');
    }
    if (password.length < 6) {
      return const AuthResult(false, message: 'Password must be at least 6 characters.');
    }
    if (password != confirmPassword) {
      return const AuthResult(false, message: 'Passwords do not match.');
    }
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        return const AuthResult(false, message: 'Sign up failed.');
      }
      // Note: User is not authenticated until email is confirmed
      // Don't set _isAuthenticated = true here
      return const AuthResult(true, message: 'Please check your email and confirm your account before logging in.');
    } on AuthException catch (e) {
      final raw = e.message;
      String message = 'Registration failed: $raw';
      if (raw.contains('User already registered')) {
        message = 'An account with this email already exists.';
      } else if (raw.contains('Password should be at least')) {
        message = 'Password is too weak. Please choose a stronger password.';
      } else if (raw.contains('Signup is disabled')) {
        message = 'Sign up is disabled in Supabase Auth settings.';
      } else if (raw.contains('Unable to validate email address')) {
        message = 'Please enter a valid email address.';
      } else if (raw.contains('For security purposes, you can only request this after')) {
        message = 'Too many signup attempts. Please try again later.';
      }
      return AuthResult(false, message: message);
    } catch (e) {
      return AuthResult(false, message: 'Registration failed: $e');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    _currentUser = null;
    _currentUserId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> resendConfirmationEmail(String email) async {
    await _client.auth.resend(
      type: OtpType.signup,
      email: email,
    );
  }

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      return const AuthResult(false, message: 'Email is required.');
    }
    if (!email.contains('@') || !email.contains('.')) {
      return const AuthResult(false, message: 'Please enter a valid email address.');
    }
    try {
      // Ensure the reset link returns to the running app (required for web).
      // Use localhost:3000 for local development
      const redirectTo = 'http://localhost:3000';
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      return const AuthResult(true, message: 'Password reset email sent. Please check your inbox.');
    } on AuthException catch (e) {
      String message = 'Password reset failed.';
      if (e.message.contains('User not found')) {
        message = 'No account found for that email.';
      } else if (e.message.contains('Too many requests')) {
        message = 'Too many requests. Please try again later.';
      }
      return AuthResult(false, message: message);
    } catch (e) {
      return const AuthResult(false, message: 'Network error. Please check your connection.');
    }
  }
}
