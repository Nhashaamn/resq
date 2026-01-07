import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/domain/usecases/send_phone_otp_usecase.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_phone_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_error_text.dart';

class PhoneForm extends ConsumerStatefulWidget {
  const PhoneForm({super.key});

  @override
  ConsumerState<PhoneForm> createState() => _PhoneFormState();
}

class _PhoneFormState extends ConsumerState<PhoneForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final sendOtpUseCase = getIt<SendPhoneOtpUseCase>();
    // Phone form is used for signup, so pass isSignup = true
    final result = await sendOtpUseCase(_phoneController.text.trim(), isSignup: true);

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
      },
      (verificationId) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          context.push('/otp', extra: {
            'verificationId': verificationId,
            'phoneNumber': _phoneController.text.trim(),
          });
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
              Icons.phone_android,
              size: 80,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter Your Phone Number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll send you a verification code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: AppPhoneField(
                controller: _phoneController,
              ),
            ),
            AppErrorText(error: _error),
            const SizedBox(height: 24),
            AppGradientButton(
              text: 'Send OTP',
              isLoading: _isLoading,
              onPressed: _handleSendOtp,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

