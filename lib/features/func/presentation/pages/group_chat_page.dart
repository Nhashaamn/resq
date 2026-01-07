import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/presentation/providers/group_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';
import 'package:resq/features/func/presentation/widgets/group_widgets/group_message_bubble.dart';
import 'package:share_plus/share_plus.dart';

class GroupChatPage extends ConsumerStatefulWidget {
  final String groupId;
  
  const GroupChatPage({
    super.key,
    required this.groupId,
  });

  @override
  ConsumerState<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends ConsumerState<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).listenToGroupMessages(widget.groupId);
    });
  }

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
      ref.read(groupProvider.notifier).clearReply();
      return;
    }

    final success = await ref
        .read(groupProvider.notifier)
        .sendGroupMessage(widget.groupId, text);
    if (success) {
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(groupProvider).error?.when(
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

  Future<void> _shareGroupLink() async {
    final groups = ref.read(groupProvider).groups;
    final group = groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => throw Exception('Group not found'),
    );

    final inviteCode = group.inviteCode;
    final shareText = 'Join my group "${group.name}" on ResQ!\n\n'
        'Invite Code: $inviteCode\n\n'
        'Or click this link to join: resq://join/$inviteCode';

    // Share via WhatsApp if available, otherwise use default share
    try {
      await Share.share(
        shareText,
        subject: 'Join ${group.name} on ResQ',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupProvider);
    Group? group;
    try {
      group = groupState.groups.firstWhere(
        (g) => g.id == widget.groupId,
      );
    } catch (e) {
      // Group not loaded yet, show loading
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppbarWidget(
          title: 'Loading...',
          icon: Icons.close,
          onTap: () => context.go('/chatsetting'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    ref.listen(groupProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: group.name,
        icon: Icons.share_rounded,
        onTap: _shareGroupLink,
      ),
      body: Column(
        children: [
          Expanded(
            child: groupState.messages.isEmpty
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
                          const Text(
                            'No messages yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Start the conversation!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              height: 1.5,
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
                      itemCount: groupState.messages.length,
                      itemBuilder: (context, index) {
                        return GroupMessageBubble(
                          message: groupState.messages[index],
                          groupId: widget.groupId,
                        );
                      },
                    ),
                  ),
          ),
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
                  if (groupState.replyingToMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Replying to ${groupState.replyingToMessage!.userName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  groupState.replyingToMessage!.text,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              ref.read(groupProvider.notifier).clearReply();
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
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
                                hintText: groupState.replyingToMessage != null
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
                              colors: groupState.isSending
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
                              onTap: groupState.isSending
                                  ? null
                                  : () => _sendMessage(),
                              borderRadius: BorderRadius.circular(28),
                              child: Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                child: groupState.isSending
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

