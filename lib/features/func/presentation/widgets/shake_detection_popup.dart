import 'dart:async';
import 'package:flutter/material.dart';
import 'package:resq/core/theme/app_theme.dart';

class ShakeDetectionPopup extends StatefulWidget {
  final VoidCallback? onOkPressed;
  final VoidCallback? onNeedHelpPressed;
  final VoidCallback? onAutoClose;

  const ShakeDetectionPopup({
    super.key,
    this.onOkPressed,
    this.onNeedHelpPressed,
    this.onAutoClose,
  });

  @override
  State<ShakeDetectionPopup> createState() => _ShakeDetectionPopupState();
}

class _ShakeDetectionPopupState extends State<ShakeDetectionPopup> {
  Timer? _autoCloseTimer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();
    _startAutoCloseTimer();
  }

  void _startAutoCloseTimer() {
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });

        if (_remainingSeconds <= 0) {
          timer.cancel();
          // Call onAutoClose callback before closing
          if (widget.onAutoClose != null) {
            widget.onAutoClose!();
          }
          _closePopup();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _closePopup() {
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleOkPressed() {
    _autoCloseTimer?.cancel();
    if (widget.onOkPressed != null) {
      widget.onOkPressed!();
    } else {
      _closePopup();
    }
  }

  void _handleNeedHelpPressed() {
    _autoCloseTimer?.cancel();
    if (widget.onNeedHelpPressed != null) {
      widget.onNeedHelpPressed!();
    } else {
      _closePopup();
    }
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningYellow,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Are you OK?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We detected a sudden movement. Are you safe and okay?',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.warningYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: AppTheme.warningYellow,
                ),
                const SizedBox(width: 6),
                Text(
                  'Auto-closing in $_remainingSeconds seconds',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warningYellow,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _handleOkPressed,
          child: Text(
            'I\'m OK',
            style: TextStyle(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleNeedHelpPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: AppTheme.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
          ),
          child: const Text(
            'Need Help',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

