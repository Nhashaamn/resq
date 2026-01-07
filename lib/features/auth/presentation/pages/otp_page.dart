import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import '../widgets/otp_widgets/otp_form.dart';

class OtpPage extends ConsumerWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: AppTheme.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'ResQ',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: OtpForm(
                    verificationId: verificationId,
                    phoneNumber: phoneNumber,
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

