import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextAlign? textAlign;
  final double? fontSize;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textAlign,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

