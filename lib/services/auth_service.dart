import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    String? displayName,
  }) async {
    try {
      // First check if username is available
      final isUsernameAvailable = await this.isUsernameAvailable(username);
      if (!isUsernameAvailable) {
        throw Exception('Username is already taken');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'display_name': displayName ?? username,
        },
      );

      if (response.user != null) {
        // Create user profile in the database
        try {
          await _createUserProfile(
            userId: response.user!.id,
            email: email,
            username: username,
            displayName: displayName,
          );
        } catch (profileError) {
          // If profile creation fails, we should still return the auth response
          // The profile can be created later or handled by database triggers
          // Profile creation failed, but auth succeeded
          // This can be handled by database triggers or retry logic
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.instagramapp.flutter://login-callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign in with Apple
  Future<bool> signInWithApple() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'com.instagramapp.flutter://login-callback',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<app_user.User?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return app_user.User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String userId,
    String? username,
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) updates['username'] = username;
      if (displayName != null) updates['display_name'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String username,
    String? displayName,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _client.from('profiles').insert({
        'id': userId,
        'username': username,
        'full_name': displayName ?? username,
        'bio': null,
        'avatar_url': null,
        'website': null,
        'is_private': false,
        'followers_count': 0,
        'following_count': 0,
        'posts_count': 0,
        'created_at': now,
        'updated_at': now,
      });
    } catch (e) {
      // If user already exists, that's okay
      if (e.toString().contains('duplicate key') ||
          e.toString().contains('already exists')) {
        return; // Profile already exists, which is fine
      }
      rethrow;
    }
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      return false;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      if (currentUser != null) {
        // Delete user data from database
        await _client
            .from('profiles')
            .delete()
            .eq('id', currentUser!.id);

        // Delete auth user
        await _client.auth.admin.deleteUser(currentUser!.id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
