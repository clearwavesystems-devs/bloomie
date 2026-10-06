import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../../profile/cubit/profile_cubit.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final ProfileCubit _profileCubit;

  AuthCubit(this._authService, this._profileCubit) : super(AuthInitial());

  // ── Check session on startup ────────────────

  Future<void> checkSession() async {
    emit(AuthLoading());
    try {
      if (_authService.isSignedIn) {
        final userId = _authService.currentUser!.id;
        try {
          final user = await _authService.fetchProfile(userId);
          await _profileCubit.loadFromSupabase(user);
          emit(AuthAuthenticated(user));
        } catch (networkError, stack) {
          // The Supabase session is still valid locally, but the profile
          // fetch failed (most likely no internet connection). Fall back
          // to the cached profile instead of forcing the user to log out.
          debugPrint('AuthCubit.checkSession network error: $networkError');
          debugPrint('StackTrace: $stack');
          final cachedUser = await _profileCubit.loadCachedProfile(userId);
          if (cachedUser != null) {
            emit(AuthAuthenticated(cachedUser));
          } else {
            emit(AuthUnauthenticated());
          }
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e, stack) {
      debugPrint('AuthCubit.checkSession Error: $e');
      debugPrint('StackTrace: $stack');

      // If the user has a valid local session but we can't reach the server
      // (e.g. no internet on startup), keep them authenticated with cached
      // data rather than booting them to the login screen.
      final isNetworkError = e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('ClientException') ||
          e.toString().contains('AuthRetryableFetchException');

      if (isNetworkError && _authService.isSignedIn) {
        debugPrint('AuthCubit.checkSession: Network error but local session exists — staying authenticated offline.');
        // ProfileCubit starts in ProfileInitial at cold-start, so cachedUser
        // is null. Load from SharedPreferences first, then read it back.
        await _profileCubit.loadProfile();
        final cachedUser = _profileCubit.cachedUser;
        if (cachedUser != null) {
          emit(AuthAuthenticated(cachedUser));
        } else {
          // No cached profile at all — treat as unauthenticated so the user
          // can sign in fresh when connectivity is restored.
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    }
  }

  // ── Sign Up ────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(AuthLoading());
    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      emit(AuthRegistrationSuccess(email));
    } catch (e, stack) {
      debugPrint('AuthCubit.signUp Error: $e');
      debugPrint('StackTrace: $stack');
      final raw = e.toString();
      emit(AuthError(
        _friendlyError(raw),
        unconfirmedEmail: _isEmailNotConfirmed(raw) ? email : null,
      ));
    }
  }

  // ── Sign In ────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signIn(email: email, password: password);
      await _profileCubit.loadFromSupabase(user);
      emit(AuthAuthenticated(user));
    } catch (e, stack) {
      debugPrint('AuthCubit.signIn Error: $e');
      debugPrint('StackTrace: $stack');
      final raw = e.toString();
      emit(AuthError(
        _friendlyError(raw),
        unconfirmedEmail: _isEmailNotConfirmed(raw) ? email : null,
      ));
    }
  }

  // ── Sign Out ───────────────────────────────

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await _authService.deleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Could not delete account. Please try again.'));
    }
  }

  // ── Password Recovery ──────────────────────

  /// Sends a password-reset email. Throws on failure so the caller (a
  /// dialog with its own local loading indicator) can surface the error
  /// without disturbing the screen-wide [AuthState].
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(_friendlyError(e.toString()));
    }
  }

  /// Re-sends the sign-up confirmation email. See [sendPasswordResetEmail]
  /// for why this doesn't touch the shared [AuthState].
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _authService.resendConfirmationEmail(email);
    } catch (e) {
      throw Exception(_friendlyError(e.toString()));
    }
  }

  // ── Helpers ────────────────────────────────

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login')) return 'Incorrect email or password.';
    if (raw.contains('already registered')) return 'An account with this email already exists.';
    if (raw.contains('weak_password')) return 'Password must be at least 6 characters.';
    if (raw.contains('network')) return 'No internet connection.';
    if (raw.contains('email_not_confirmed') || raw.contains('not confirmed')) {
      return 'Please confirm your email before signing in.';
    }
    if (raw.contains('rate limit') || raw.contains('rate_limit')) {
      return 'Too many attempts. Please wait a few minutes and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  bool _isEmailNotConfirmed(String raw) =>
      raw.contains('email_not_confirmed') || raw.contains('not confirmed');
}
