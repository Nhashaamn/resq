import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

class AppErrorText extends StatelessWidget {
  final String? error;
  final EdgeInsetsGeometry? padding;

  const AppErrorText({
    super.key,
    this.error,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (error == null || error!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 12),
      child: Text(
        error!,
        style: const TextStyle(color: AppTheme.errorRed),
      ),
    );
  }
}

