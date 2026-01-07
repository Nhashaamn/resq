import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import '../common_widgets/social_login_button.dart';

class SocialLoginSection extends ConsumerWidget {
  const SocialLoginSection({super.key});

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    final googleSignInUseCase = ref.read(googleSignInUseCaseProvider);
    final result = await googleSignInUseCase();

    if (!context.mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              failure.when(
                server: (msg) => msg,
                network: (msg) => msg,
                cache: (msg) => msg,
                validation: (msg) => msg,
                auth: (msg) => msg,
              ),
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      (_) async {
        await ref.read(authStateProvider.notifier).checkAuth();
        if (context.mounted) {
          context.go('/home');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.borderLight,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or sign in with',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.borderLight,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SocialLoginButton(
                icon: 'assets/pics/google.png',
                label: 'Google',
                onPressed: () => _handleGoogleSignIn(context, ref),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SocialLoginButton(
                icon: 'assets/pics/facebook.png',
                label: 'Facebook',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
