import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/domain/entities/message.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/presentation/providers/community_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageBubble extends ConsumerWidget {
  final Message message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isCurrentUser = authState.user?.id == message.userId;

    return GestureDetector(
      onDoubleTap: () {
        // Only allow double tap to reply for messages from other users
        if (!isCurrentUser) {
          HapticFeedback.mediumImpact();
          ref.read(communityProvider.notifier).setReplyingToMessage(message);
        }
      },
      onLongPress: () {
        // Only allow long press to delete for current user's messages
        if (isCurrentUser) {
          HapticFeedback.mediumImpact();
          _showDeleteDialog(context, ref);
        }
      },
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment:
                isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // User name (only show if not current user)
              if (!isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                  child: Text(
                    message.userName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              // Message bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser ? AppTheme.primary : AppTheme.backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isCurrentUser ? 16 : 4),
                    bottomRight: Radius.circular(isCurrentUser ? 4 : 16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reply preview if this is a reply
                    if (message.replyToMessageId != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentUser
                              ? AppTheme.white.withOpacity(0.2)
                              : AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border(
                            left: BorderSide(
                              color: isCurrentUser
                                  ? AppTheme.white.withOpacity(0.5)
                                  : AppTheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.replyToUserName ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isCurrentUser
                                    ? AppTheme.white
                                    : AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message.replyToText ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                color: isCurrentUser
                                    ? AppTheme.white.withOpacity(0.8)
                                    : AppTheme.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isCurrentUser
                            ? AppTheme.white
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isCurrentUser
                            ? AppTheme.white.withOpacity(0.7)
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // "Double tap to reply" hint (only for other users' messages)
              if (!isCurrentUser)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 12),
                  child: Text(
                    'Double tap to reply',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textLight,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return DateFormat('h:mm a').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE h:mm a').format(timestamp);
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Message',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this message? This action cannot be undone.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
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
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.secendory],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await ref
                    .read(communityProvider.notifier)
                    .deleteMessage(message.id);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ref.read(communityProvider).error?.when(
                              server: (msg) => msg,
                              network: (msg) => msg,
                              cache: (msg) => msg,
                              validation: (msg) => msg,
                              auth: (msg) => msg,
                            ) ?? 'Failed to delete message',
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
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

