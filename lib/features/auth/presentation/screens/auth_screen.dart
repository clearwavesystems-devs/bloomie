import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:bloomie/core/theme/app_colors.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:bloomie/features/auth/cubit/auth_cubit.dart';
import 'package:bloomie/features/auth/cubit/auth_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isSignIn = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F5),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/');
          }
          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account created successfully! 🎉 Please sign in.',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppColors.lavender,
                duration: const Duration(seconds: 4),
              ),
            );
            setState(() {
              _isSignIn = true;
            });
            _emailCtrl.text = state.email;
            _passwordCtrl.clear();
            _confirmPasswordCtrl.clear();
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 5),
                action: state.unconfirmedEmail != null
                    ? SnackBarAction(
                        label: 'Resend',
                        textColor: Colors.white,
                        onPressed: () => _resendConfirmation(
                            context, state.unconfirmedEmail!),
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 48.h),

                    // ── Hero ────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          Text('🌸', style: TextStyle(fontSize: 64.sp)),
                          SizedBox(height: 12.h),
                          Text(
                            'Bloomie',
                            style: GoogleFonts.baloo2(
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryPink,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _isSignIn
                                ? 'Welcome back! 🌷'
                                : 'Start your bloom journey 🌱',
                            style: GoogleFonts.nunito(
                              fontSize: 15.sp,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40.h),

                    // ── Tab Toggle ──────────────────────
                    Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5E6F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          _TabButton(
                            label: 'Sign In',
                            selected: _isSignIn,
                            onTap: () => setState(() => _isSignIn = true),
                          ),
                          _TabButton(
                            label: 'Sign Up',
                            selected: !_isSignIn,
                            onTap: () => setState(() => _isSignIn = false),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ── Fields ──────────────────────────

                    if (!_isSignIn) ...[
                      _BloomieField(
                        controller: _nameCtrl,
                        label: 'Display Name',
                        hint: 'e.g. Sakura',
                        icon: SolarIconsOutline.user,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                      ),
                      SizedBox(height: 16.h),
                    ],

                    _BloomieField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'hello@bloomie.app',
                      icon: SolarIconsOutline.letter,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || !_emailRegex.hasMatch(v.trim()))
                          ? 'Enter a valid email'
                          : null,
                    ),
                    SizedBox(height: 16.h),

                    _BloomieField(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      icon: SolarIconsOutline.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? SolarIconsOutline.eyeClosed
                              : SolarIconsOutline.eye,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min. 6 characters' : null,
                    ),

                    if (!_isSignIn) ...[
                      SizedBox(height: 16.h),
                      _BloomieField(
                        controller: _confirmPasswordCtrl,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        icon: SolarIconsOutline.lock,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? SolarIconsOutline.eyeClosed
                                : SolarIconsOutline.eye,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(
                              () => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                        validator: (v) => (v != _passwordCtrl.text)
                            ? 'Passwords do not match'
                            : null,
                      ),
                    ],

                    if (_isSignIn) ...[
                      SizedBox(height: 8.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context),
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.nunito(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPink,
                            ),
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 32.h),

                    // ── CTA Button ──────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: isLoading ? null : _submit,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primaryPink, AppColors.lavender],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text(
                                    _isSignIn ? 'Sign In' : 'Create Account',
                                    style: GoogleFonts.baloo2(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Switch mode hint ────────────────
                    Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _isSignIn = !_isSignIn),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.nunito(
                                fontSize: 13.sp, color: AppColors.textMuted),
                            children: [
                              TextSpan(
                                  text: _isSignIn
                                      ? "Don't have an account? "
                                      : "Already have an account? "),
                              TextSpan(
                                text: _isSignIn ? 'Sign Up' : 'Sign In',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryPink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final cubit = context.read<AuthCubit>();

    if (_isSignIn) {
      cubit.signIn(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      cubit.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    }
  }

  Future<void> _resendConfirmation(BuildContext context, String email) async {
    final cubit = context.read<AuthCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      await cubit.resendConfirmationEmail(email);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Confirmation email resent! 📬',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.lavender,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', ''),
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text.trim());
    final resetFormKey = GlobalKey<FormState>();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text(
            'Reset Password 🔑',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, color: AppColors.primaryPink),
          ),
          content: Form(
            key: resetFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter your email and we'll send you a link to reset your password.",
                  style: GoogleFonts.nunito(color: AppColors.textMuted),
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: resetEmailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.nunito(fontSize: 14.sp),
                  validator: (v) => (v == null || !_emailRegex.hasMatch(v.trim()))
                      ? 'Enter a valid email'
                      : null,
                  decoration: InputDecoration(
                    hintText: 'hello@bloomie.app',
                    filled: true,
                    fillColor: const Color(0xFFF5E6F0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(dialogCtx),
              child: Text('Cancel',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPink,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      if (!resetFormKey.currentState!.validate()) return;
                      setDialogState(() => isSending = true);
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        await cubit.sendPasswordResetEmail(resetEmailCtrl.text.trim());
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text('Password reset link sent! Check your inbox. 📧',
                                style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.lavender,
                          ),
                        );
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(e.toString().replaceFirst('Exception: ', ''),
                                style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
              child: isSending
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('Send Link',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable Field ─────────────────────────────

class _BloomieField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _BloomieField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.nunito(fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: AppColors.textMuted),
            prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.grey.shade200, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primaryPink, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tab Button ────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight:
                  selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? AppColors.primaryPink : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
