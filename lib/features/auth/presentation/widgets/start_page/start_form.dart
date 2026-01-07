import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';

class StartForm extends StatelessWidget {
  const StartForm({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: size.height * 0.8),
        child: Container(
          margin: const EdgeInsets.only(top: 24),
          decoration: const BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Start Image
                Image.asset(
                  'assets/pics/start.png',
                  fit: BoxFit.contain,
                  height: 280,
                ),
                const SizedBox(height: 40),
                // Enterprise Text
                Text(
                  'ResQ Enterprise',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 14),
                // Main Title
                const Text(
                  'your one tap emergency solution',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 40),
                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  child: AppGradientButton(
                    text: 'Get Started',
                    onPressed: () => context.go('/login'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}