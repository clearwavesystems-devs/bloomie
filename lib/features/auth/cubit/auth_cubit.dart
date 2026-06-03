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
        final user = await _authService.fetchProfile(_authService.currentUser!.id);
        _profileCubit.loadFromSupabase(user);
        emit(AuthAuthenticated(user));
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
      emit(AuthError(_friendlyError(e.toString())));
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
      _profileCubit.loadFromSupabase(user);
      emit(AuthAuthenticated(user));
    } catch (e, stack) {
      debugPrint('AuthCubit.signIn Error: $e');
      debugPrint('StackTrace: $stack');
      emit(AuthError(_friendlyError(e.toString())));
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

  // ── Helpers ────────────────────────────────

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login')) return 'Incorrect email or password.';
    if (raw.contains('already registered')) return 'An account with this email already exists.';
    if (raw.contains('weak_password')) return 'Password must be at least 6 characters.';
    if (raw.contains('network')) return 'No internet connection.';
    if (raw.contains('email_not_confirmed') || raw.contains('not confirmed')) {
      return 'This account was created before email confirmations were turned off. Please register with a new email address!';
    }
    if (raw.contains('rate limit') || raw.contains('rate_limit')) {
      return 'Email limit reached. Please turn OFF "Confirm email" in your Supabase Dashboard under Auth -> Providers -> Email to test instantly.';
    }
    return 'Something went wrong. Please try again.';
  }
}
