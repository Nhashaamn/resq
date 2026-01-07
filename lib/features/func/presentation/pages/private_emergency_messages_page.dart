import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/providers/private_emergency_message_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class PrivateEmergencyMessagesPage extends ConsumerStatefulWidget {
  const PrivateEmergencyMessagesPage({super.key});

  @override
  ConsumerState<PrivateEmergencyMessagesPage> createState() => _PrivateEmergencyMessagesPageState();
}

class _PrivateEmergencyMessagesPageState extends ConsumerState<PrivateEmergencyMessagesPage> {
  @override
  void initState() {
    super.initState();
    // Mark all messages as read when page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messages = ref.read(privateEmergencyMessageProvider).messages;
      for (final message in messages) {
        if (!message.isRead) {
          ref.read(privateEmergencyMessageProvider.notifier).markAsRead(message.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final privateMessagesState = ref.watch(privateEmergencyMessageProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'Emergency Messages',
        icon: Icons.arrow_back,
        onTap: () => context.pop(),
      ),
      body: privateMessagesState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : privateMessagesState.messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emergency_outlined,
                        size: 64,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No emergency messages',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Emergency messages will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: privateMessagesState.messages.length,
                  itemBuilder: (context, index) {
                    final message = privateMessagesState.messages[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: message.isRead
                            ? AppTheme.backgroundWhite
                            : AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: message.isRead
                              ? AppTheme.borderLight
                              : AppTheme.errorRed.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorRed.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.emergency_rounded,
                                  color: AppTheme.errorRed,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'From: ${message.fromUserName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTimestamp(message.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!message.isRead)
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message.message,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Contact: ${message.toEmail} | ${message.toPhoneNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

