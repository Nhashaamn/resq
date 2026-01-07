import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/providers/chatbot_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';
import 'package:resq/features/func/presentation/widgets/chatbot_widgets/chat_message_list.dart';
import 'package:resq/features/func/presentation/widgets/chatbot_widgets/chatbot_input.dart';

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});

  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
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

  @override
  Widget build(BuildContext context) {
    final chatbotState = ref.watch(chatbotProvider);

    // Auto-scroll when new messages arrive
    ref.listen(chatbotProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'AI Assistant',
        icon: Icons.refresh,
        leadingIcon: Icons.smart_toy,
        onTap: () {
          ref.read(chatbotProvider.notifier).clearChat();
        },
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatbotState.isLoading && chatbotState.messages.isEmpty
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
                          'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : chatbotState.messages.isEmpty
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
                                  Icons.smart_toy_outlined,
                                  size: 80,
                                  color: AppTheme.primary.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Start a conversation',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Ask me anything about emergency preparedness!',
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
                    : ChatMessageList(
                        messages: chatbotState.messages,
                        scrollController: _scrollController,
                        isLoading: chatbotState.isSending,
                      ),
          ),
          // Message input
          ChatbotInput(
            onSend: () {},
            isSending: chatbotState.isSending,
            onMessageSent: (text) {
              ref.read(chatbotProvider.notifier).sendMessage(text);
            },
          ),
          // Show error if any
          if (chatbotState.error != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.errorRed.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      chatbotState.error!,
                      style: TextStyle(
                        color: AppTheme.errorRed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

