import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

/// OTP authentication screen.
///
/// Flow:
/// 1. User enters phone number → presses Send OTP
/// 2. 6-digit code input appears with countdown timer
/// 3. User enters code → Verify → authenticated
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _sending = false;
  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // OTP flow
  // -------------------------------------------------------------------------

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 10) {
      _showError(AppStrings.invalidPhone);
      return;
    }
    setState(() => _sending = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendOtp(phone: phone);
      setState(() {
        _otpSent = true;
        _sending = false;
      });
      _startCountdown();
    } catch (e) {
      setState(() => _sending = false);
      _showError(e.toString());
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length != 6) {
      _showError('Please enter the complete 6-digit OTP');
      return;
    }
    await ref.read(authNotifierProvider.notifier).verifyOtp(
          phone: _phoneCtrl.text.trim(),
          otp: otp,
        );
  }

  void _startCountdown() {
    _countdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 0) {
        t.cancel();
        setState(() {});
        return;
      }
      setState(() => _countdown--);
    });
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

    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                AppStrings.otpTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 8),
              const Text(
                AppStrings.otpSubtitle,
                style:
                    TextStyle(color: AppColors.textSecondary),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // Phone field
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: AppStrings.phone,
                  labelStyle:
                      const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.phone_outlined,
                      color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              if (!_otpSent)
                ElevatedButton(
                  onPressed: _sending ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _sending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.sendOtp,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 300.ms),

              if (_otpSent) ...[
                const SizedBox(height: 8),
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14),
                ),
                const SizedBox(height: 12),
                _buildOtpInput()
                    .animate()
                    .fadeIn(delay: 100.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(AppStrings.verifyOtp,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                Center(
                  child: _countdown > 0
                      ? Text(
                          '${AppStrings.resendIn}$_countdown s',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        )
                      : TextButton(
                          onPressed: _sendOtp,
                          child: const Text(
                            AppStrings.resendOtp,
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (i) => _otpBox(i)),
      );

  Widget _otpBox(int index) => SizedBox(
        width: 48,
        height: 56,
        child: TextFormField(
          controller: _otpCtrls[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            counterText: '',
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
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            } else if (val.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }
          },
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
