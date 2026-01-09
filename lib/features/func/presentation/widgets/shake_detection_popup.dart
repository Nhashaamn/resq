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

class _ShakeDetectionPopupState extends State<ShakeDetectionPopup>
    with SingleTickerProviderStateMixin {
  Timer? _autoCloseTimer;
  int _remainingSeconds = 10;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _startAutoCloseTimer();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
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
    _pulseController.dispose();
    super.dispose();
  }

  Color _getTimerColor() {
    if (_remainingSeconds <= 3) {
      return AppTheme.errorRed;
    } else if (_remainingSeconds <= 6) {
      return Colors.orange;
    }
    return const Color(0xFFFFA726);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / 10.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated warning icon with pulse effect
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.errorRed,
                      size: 48,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            // Title
            const Text(
              'Are you OK?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Description
            Text(
              'We detected a sudden movement.\nAre you safe and okay?',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Timer progress bar
            Column(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getTimerColor(),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _getTimerColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTimerColor().withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: _getTimerColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Auto-closing in $_remainingSeconds ${_remainingSeconds == 1 ? 'second' : 'seconds'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getTimerColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _handleOkPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(
                        color: AppTheme.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'I\'m OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _handleNeedHelpPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.emergency, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Need Help',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

