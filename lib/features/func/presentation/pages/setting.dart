import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/presentation/providers/emergency_number_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';
import 'package:resq/features/func/presentation/widgets/setting_widgets/profile_card.dart';
import 'package:resq/features/func/presentation/widgets/setting_widgets/section%20_title.dart';
import 'package:resq/features/func/presentation/widgets/setting_widgets/setting_items.dart';

class Setting extends ConsumerStatefulWidget {
  const Setting({super.key});

  @override
  ConsumerState<Setting> createState() => _SettingState();
}

class _SettingState extends ConsumerState<Setting> {

  void _showSetEmergencyNumberDialog() {
    final emergencyNumberState = ref.read(emergencyNumberProvider);
    final phoneController = TextEditingController(
      text: emergencyNumberState.emergencyNumber?.phoneNumber ?? '',
    );
    final emailController = TextEditingController(
      text: emergencyNumberState.emergencyNumber?.email ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Set Emergency Contact',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter emergency contact email',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter emergency contact number',
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.phone,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This contact will receive private emergency messages when shake is detected and you don\'t respond',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: ref.read(emergencyNumberProvider).isLoading
                ? null
                : () async {
                    final email = emailController.text.trim();
                    final number = phoneController.text.trim();
                    if (email.isNotEmpty && number.isNotEmpty) {
                      final success = await ref
                          .read(emergencyNumberProvider.notifier)
                          .setEmergencyNumber(number, email);
                      if (mounted) {
                        Navigator.of(context).pop();
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Emergency contact saved successfully'),
                              backgroundColor: AppTheme.successGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        } else {
                          final error = ref.read(emergencyNumberProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error?.when(
                                      server: (msg) => msg,
                                      network: (msg) => msg,
                                      cache: (msg) => msg,
                                      validation: (msg) => msg,
                                      auth: (msg) => msg,
                                    ) ?? 'Failed to save emergency contact',
                              ),
                              backgroundColor: AppTheme.errorRed,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: ref.watch(emergencyNumberProvider).isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    if (!authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final user = authState.user;
    final displayName = user?.name?.isNotEmpty == true
        ? user!.name!
        : 'ResQ User';
    final displayEmail = user?.email ?? 'email@example.com';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'Setting',
        icon: Icons.close,
        onTap: () => context.go('/home'),
        leadingIcon: Icons.settings,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileCard(name: displayName, email: displayEmail),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Emergency'),
              const SizedBox(height: 12),
              Consumer(
                builder: (context, ref, child) {
                  final emergencyNumberState = ref.watch(emergencyNumberProvider);
                  return SettingItem(
                    icon: Icons.emergency_rounded,
                    title: 'Emergency Number',
                    subtitle: emergencyNumberState.isLoading
                        ? 'Loading...'
                        : (emergencyNumberState.emergencyNumber != null &&
                                emergencyNumberState.emergencyNumber!.phoneNumber.isNotEmpty &&
                                emergencyNumberState.emergencyNumber!.email.isNotEmpty)
                            ? '${emergencyNumberState.emergencyNumber!.email}\n${emergencyNumberState.emergencyNumber!.phoneNumber}'
                            : 'Not set - Tap to set emergency contact',
                    iconBackground: AppTheme.errorRed.withOpacity(0.12),
                    iconColor: AppTheme.errorRed,
                    onTap: _showSetEmergencyNumberDialog,
                  );
                },
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Account'),
              const SizedBox(height: 12),
              SettingItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                iconBackground: Colors.red.withOpacity(0.12),
                iconColor: Colors.red,
                onTap: () async {
                  await ref.read(authStateProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
              const SizedBox(height: 24),
              const SectionTitle(title: 'Support'),
              const SizedBox(height: 12),
              SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Learn how we handle your data',
                onTap: () {
                  context.go('/privacy-policy');
                },
              ),
              const SizedBox(height: 12),
              SettingItem(
                icon: Icons.help_outline,
                title: 'Help',
                subtitle: 'Get answers and support',
                onTap: () {
                  context.go('/help');
                },
              ),
              const SizedBox(height: 12),
              SettingItem(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Know more about ResQ',
                onTap: () {
                  context.go('/about');
                },
              ),
              const SizedBox(height: 12),
              SettingItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () {
                  context.go('/terms-of-service');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
