import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_email_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_password_field.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_text_button.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_error_text.dart';
import 'social_login_section.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the login form provider state
    final loginFormState = ref.watch(loginFormProvider);
    
    // Listen for successful login and navigate to home
    ref.listen(loginFormProvider, (previous, next) {
      if (next.success && context.mounted) {
        context.go('/home');
      }
    });

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
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your details below',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),

          const SizedBox(height: 24),

          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppEmailField(
                  controller: _email,
                ),
                const SizedBox(height: 24),
                AppPasswordField(
                  controller: _password,
                ),
              ],
            ),
          ),

          AppErrorText(error: loginFormState.error),

          const SizedBox(height: 24),

          AppGradientButton(
            text: 'Sign in',
            isLoading: loginFormState.isLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                ref.read(loginFormProvider.notifier).login(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                    );
              }
            },
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: AppTextButton(
              text: 'Forgot your password?',
              onPressed: () {
                context.go('/forgot-password');
              },
            ),
          ),

          const SizedBox(height: 32),
          const SocialLoginSection(),
          ],
        ),
      ),
    );
  }
}
