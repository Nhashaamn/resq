import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

enum PasswordStrength {
  weak,
  medium,
  strong,
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final PasswordStrength strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.strength,
  });

  static PasswordStrength calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.medium;
    
    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    int criteria = 0;
    if (hasUpper) criteria++;
    if (hasLower) criteria++;
    if (hasDigit) criteria++;
    if (hasSpecial) criteria++;
    
    if (criteria >= 3 && password.length >= 8) {
      return PasswordStrength.strong;
    } else if (criteria >= 2 || password.length >= 6) {
      return PasswordStrength.medium;
    }
    return PasswordStrength.weak;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    final strength = calculateStrength(password);
    final segments = _getSegments(strength);
    final text = _getStrengthText(strength);
    final color = _getStrengthColor(strength);

    return Row(
      children: [
        ...segments.map((isFilled) => Expanded(
              child: Container(
                height: 4,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: isFilled ? color : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            )),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<bool> _getSegments(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return [true, false, false];
      case PasswordStrength.medium:
        return [true, true, false];
      case PasswordStrength.strong:
        return [true, true, true];
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppTheme.errorRed;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return AppTheme.successGreen;
    }
  }
}

