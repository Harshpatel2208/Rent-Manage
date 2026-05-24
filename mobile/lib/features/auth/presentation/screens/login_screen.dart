import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

/// Premium dark-themed login screen with entrance animations.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }

  Future<void> _googleSignIn() async {
    await ref.read(authNotifierProvider.notifier).googleSignIn();
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (_, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) context.go('/dashboard');
        },
        error: (e, _) => _showError(e.toString()),
      );
    });

    final isLoading =
        ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 64),
                    _buildLogo()
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -0.3),
                    const SizedBox(height: 48),
                    Text(
                      AppStrings.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 32),
                    _buildEmailField()
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideX(begin: -0.1),
                    const SizedBox(height: 16),
                    _buildPasswordField()
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideX(begin: -0.1),
                    const SizedBox(height: 24),
                    _buildLoginButton(isLoading)
                        .animate()
                        .fadeIn(delay: 600.ms),
                    const SizedBox(height: 12),
                    _buildOtpButton().animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 12),
                    _buildGoogleButton(isLoading)
                        .animate()
                        .fadeIn(delay: 800.ms),
                    const SizedBox(height: 24),
                    _buildRegisterLink()
                        .animate()
                        .fadeIn(delay: 900.ms),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (isLoading) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Widgets
  // -------------------------------------------------------------------------

  Widget _buildLogo() => Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '₹',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      );

  Widget _buildEmailField() => TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: _inputDecoration(
          label: AppStrings.email,
          icon: Icons.email_outlined,
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return AppStrings.requiredField;
          if (!v.contains('@')) return AppStrings.invalidEmail;
          return null;
        },
      );

  Widget _buildPasswordField() => TextFormField(
        controller: _passwordCtrl,
        obscureText: _obscurePassword,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: _inputDecoration(
          label: AppStrings.password,
          icon: Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return AppStrings.requiredField;
          if (v.length < 8) return AppStrings.passwordTooShort;
          return null;
        },
      );

  Widget _buildLoginButton(bool loading) => ElevatedButton(
        onPressed: loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: const Text(
          AppStrings.login,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  Widget _buildOtpButton() => OutlinedButton.icon(
        onPressed: () => context.push('/otp'),
        icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
        label: const Text(
          AppStrings.loginWithOtp,
          style: TextStyle(color: AppColors.primary),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildGoogleButton(bool loading) => OutlinedButton.icon(
        onPressed: loading ? null : _googleSignIn,
        icon: const Icon(Icons.g_mobiledata, size: 24),
        label: const Text(AppStrings.continueWithGoogle),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildRegisterLink() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            AppStrings.noAccount,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          GestureDetector(
            onTap: () => context.push('/register'),
            child: const Text(
              AppStrings.register,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

  Widget _buildLoadingOverlay() => Container(
        color: Colors.black54,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      );

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
