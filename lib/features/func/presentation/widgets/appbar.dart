import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppbarWidget({super.key, required this.title, this.icon, this.onTap, this.leadingIcon, this.onLeadingTap});
  final String title;
  final IconData? icon;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 72,
        centerTitle: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: IconButton(onPressed: onLeadingTap, icon: Icon(leadingIcon ?? Icons.home, color: AppTheme.primary)),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your one tap emergency solution',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (icon != null && onTap != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: InkWell(
                  onTap: onTap,
                  child: Icon(icon, color: AppTheme.primary),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderLight),
        ),
      );
  }
}