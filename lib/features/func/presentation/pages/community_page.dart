import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/providers/community_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';
import 'package:resq/features/func/presentation/widgets/community_widgets/message_bubble.dart';
import 'package:resq/features/func/presentation/widgets/community_widgets/reply_preview.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) {
      // Clear reply if message is empty
      ref.read(communityProvider.notifier).clearReply();
      return;
    }

    final success = await ref.read(communityProvider.notifier).sendMessage(text);
    if (success) {
      _messageController.clear();
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(communityProvider).error?.when(
                    server: (msg) => msg,
                    network: (msg) => msg,
                    cache: (msg) => msg,
                    validation: (msg) => msg,
                    auth: (msg) => msg,
                  ) ?? 'Failed to send message',
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

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(communityProvider);

    // Auto-scroll when new messages arrive
    ref.listen(communityProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'Community Chat',
        icon: Icons.settings,
        leadingIcon: Icons.arrow_back,
        onTap: () {
          context.go('/community');
        },
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: communityState.isLoading && communityState.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            color: AppTheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Loading messages...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : communityState.messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primary.withOpacity(0.1),
                                      AppTheme.secendory.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 80,
                                  color: AppTheme.primary.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Be the first to start the conversation!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Share updates, ask questions, or connect with others',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.backgroundWhite,
                              AppTheme.backgroundLight,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 4,
                          ),
                          itemCount: communityState.messages.length,
                          itemBuilder: (context, index) {
                            return MessageBubble(
                              message: communityState.messages[index],
                            );
                          },
                        ),
                      ),
          ),
          // Message input
          Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Reply preview
                  if (communityState.replyingToMessage != null)
                    ReplyPreview(
                      message: communityState.replyingToMessage!,
                      onCancel: () {
                        ref.read(communityProvider.notifier).clearReply();
                      },
                    ),
                  // Input field
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: AppTheme.borderLight,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: communityState.replyingToMessage != null
                                    ? 'Type a reply...'
                                    : 'Type a message...',
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                hintStyle: TextStyle(
                                  color: AppTheme.textLight,
                                  fontSize: 15,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: null,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: communityState.isSending
                                  ? [
                                      AppTheme.primary.withOpacity(0.6),
                                      AppTheme.secendory.withOpacity(0.6),
                                    ]
                                  : const [
                                      AppTheme.primary,
                                      AppTheme.secendory,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: communityState.isSending
                                  ? null
                                  : () => _sendMessage(),
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                child: communityState.isSending
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            AppTheme.white,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: AppTheme.white,
                                        size: 24,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
