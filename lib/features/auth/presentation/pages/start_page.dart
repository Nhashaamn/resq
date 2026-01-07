import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/widgets/common_widgets/app_gradient_button.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primary, AppTheme.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.topRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    const Text(
                      'ResQ',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pagination Indicators
                  ],
                ),
              ),
              // White Content Card
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 24),
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 32),
                          // Start Image
                          Image.asset(
                            'assets/pics/start.png',
                            fit: BoxFit.contain,
                            height: 300,
                          ),
                          const SizedBox(height: 48),
                          // Enterprise Text
                          Text(
                            'ResQ Enterprise',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
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
                          const SizedBox(height: 48),
                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            child: AppGradientButton(
                              text: 'Get Started',
                              onPressed: () => context.go('/login'),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
