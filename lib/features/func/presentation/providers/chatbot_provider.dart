import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:resq/core/constants/api_constants.dart';
import 'package:resq/features/func/presentation/widgets/chatbot_widgets/chat_message_list.dart';

final chatbotProvider = StateNotifierProvider<ChatbotNotifier, ChatbotState>(
  (ref) => ChatbotNotifier(),
);

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final bool isSending;

  ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isSending = false,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    bool? isSending,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatbotNotifier extends StateNotifier<ChatbotState> {
  final Gemini _gemini = Gemini.instance;

  ChatbotNotifier() : super(ChatbotState()) {
    _initializeGemini();
    _addWelcomeMessage();
  }

  void _initializeGemini() {
    try {
      Gemini.init(apiKey: ApiConstants.geminiApiKey);
    } catch (e) {
      // Already initialized or error
    }
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      text: 'Hello! I\'m your ResQ assistant. How can I help you today?',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [welcomeMessage]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Create user message
    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Add user message to state
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );

    try {
      // Generate response from Gemini
      final response = await _gemini.text(text.trim());

      // Create bot message
      final botMessage = ChatMessage(
        text: response?.output ?? 'Sorry, I couldn\'t generate a response.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Add bot message to state
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isSending: false,
      );
    } catch (e) {
      // Handle error
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearChat() {
    state = ChatbotState();
    _addWelcomeMessage();
  }
}

