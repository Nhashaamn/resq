import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/domain/usecases/verify_phone_otp_usecase.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_otp_input.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_error_text.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_text_button.dart';

class OtpForm extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpForm({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends ConsumerState<OtpForm> {
  final GlobalKey<AppOtpInputState> _otpInputKey = GlobalKey();
  bool _isLoading = false;
  String? _error;

  Future<void> _handleVerifyOtp(String otp) async {
    if (otp.length != 6) {
      setState(() {
        _error = 'Please enter the complete 6-digit code';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final verifyOtpUseCase = getIt<VerifyPhoneOtpUseCase>();
    final result = await verifyOtpUseCase(widget.verificationId, otp);

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _error = failure.when(
            server: (msg) => msg,
            network: (msg) => msg,
            cache: (msg) => msg,
            validation: (msg) => msg,
            auth: (msg) => msg,
          );
        });
        _otpInputKey.currentState?.clear();
      },
      (user) {
        ref.read(authStateProvider.notifier).checkAuth();
        if (mounted) {
          // Navigate to address page for new users (after phone verification)
          context.go('/address');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.sms,
              size: 80,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Verification Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a code to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 48),
            AppOtpInput(
              key: _otpInputKey,
              onCompleted: _handleVerifyOtp,
              onChanged: (otp) {
                if (_error != null) {
                  setState(() {
                    _error = null;
                  });
                }
              },
            ),
            AppErrorText(error: _error),
            const SizedBox(height: 24),
            AppGradientButton(
              text: 'Verify',
              isLoading: _isLoading,
              onPressed: () {
                final otp = _otpInputKey.currentState?.getOtp() ?? '';
                if (otp.length == 6) {
                  _handleVerifyOtp(otp);
                } else {
                  setState(() {
                    _error = 'Please enter the complete 6-digit code';
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            AppTextButton(
              text: 'Change Phone Number',
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

