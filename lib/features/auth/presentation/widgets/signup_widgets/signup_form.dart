import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/core/di/injection.dart';
import 'package:resq/features/auth/domain/usecases/signup_usecase.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_name_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_email_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_password_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_error_text.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/password_strength_indicator.dart';
import 'package:resq/features/auth/presentation/widgets/login_widgets/social_login_section.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final signupUseCase = getIt<SignupUseCase>();
    final result = await signupUseCase(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

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
      (user) {
        if (mounted) context.go('/phone');
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
            const Text(
              'Get started free.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Free forever. No credit card needed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppEmailField(
                    controller: _emailController,
                  ),
                  const SizedBox(height: 24),
                  AppNameField(
                    controller: _nameController,
                  ),
                  const SizedBox(height: 24),
                  AppPasswordField(
                    controller: _passwordController,
                    onChanged: (value) {
                      setState(() {}); // Update to show password strength
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                    strength: PasswordStrengthIndicator.calculateStrength(
                      _passwordController.text,
                    ),
                  ),
                ],
              ),
            ),
            AppErrorText(error: _error),
            const SizedBox(height: 24),
            AppGradientButton(
              text: 'Sign up',
              isLoading: _isLoading,
              onPressed: _handleSignup,
            ),
            const SizedBox(height: 32),
            const SocialLoginSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

