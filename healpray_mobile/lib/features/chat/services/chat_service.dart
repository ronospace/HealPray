import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/chat_message.dart';
import '../repositories/chat_repository.dart';
import '../../mood/services/mood_service.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/logger.dart';

/// Service for managing chat interactions and AI responses
class ChatService {
  static ChatService? _instance;
  static ChatService get instance => _instance ??= ChatService._();

  ChatService._();

  final ChatRepository _repository = ChatRepository.instance;
  final MoodService _moodService = MoodService.instance;

  GenerativeModel? _aiModel;
  String? _currentConversationId;
  String? _currentSessionId;

  /// Initialize the chat service
  Future<void> initialize() async {
    try {
      await _repository.initialize();

      // Initialize AI model
      if (AppConfig.hasValidGeminiKey) {
        try {
          _aiModel = GenerativeModel(
            model: 'gemini-pro',
            apiKey: AppConfig.geminiApiKey,
          );
          AppLogger.info('ChatService initialized with Gemini AI');
        } catch (e) {
          AppLogger.warning('Failed to initialize Gemini AI: $e - Using demo mode');
          _aiModel = null;
        }
      } else {
        AppLogger.info('Running in demo mode - using simulated responses');
      }
    } catch (e) {
      AppLogger.warning('ChatService initialization error: $e - Using demo mode');
      // Don't rethrow - allow chat to work in demo mode
    }
  }

  // ============= CONVERSATION MANAGEMENT =============

  /// Start a new conversation
  Future<Conversation> startConversation({
    String? title,
    ChatContext context = ChatContext.spiritual,
  }) async {
    // Get current mood context for personalized responses
    final moodContext = await _getCurrentMoodContext();

    final conversation = await _repository.createConversation(
      title: title,
      context: context,
      metadata: {
        'moodContext': moodContext,
        'startedAt': DateTime.now().toIso8601String(),
      },
    );

    _currentConversationId = conversation.id;

    // Create initial session
    final session = await _repository.createSession(
      conversationId: conversation.id,
      context: context,
      moodContext: moodContext,
    );

    // Session created for analytics

    // Send welcome message
    await _sendWelcomeMessage(conversation.id, context, moodContext);

    AppLogger.info(
        'Started conversation: ${conversation.id} with context: $context');
    return conversation;
  }

  /// Get all user conversations
  List<Conversation> getAllConversations() {
    return _repository.getAllConversations();
  }

  /// Get conversation by ID
  Conversation? getConversation(String id) {
    return _repository.getConversation(id);
  }

  /// Delete a conversation
  Future<void> deleteConversation(String conversationId) async {
    await _repository.deleteConversation(conversationId);

    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
      // Session ended
    }
  }

  // ============= MESSAGE HANDLING =============

  /// Send a user message and get AI response
  Future<List<ChatMessage>> sendMessage(
    String content, {
    String? conversationId,
    ChatContext? context,
  }) async {
    final convId = conversationId ?? _currentConversationId;
    if (convId == null) {
      throw Exception('No active conversation. Start a conversation first.');
    }

    final conversation = _repository.getConversation(convId);
    if (conversation == null) {
      throw Exception('Conversation not found');
    }

    final chatContext = context ?? conversation.context;

    try {
      // Save user message
      final userMessage = await _repository.createUserMessage(
        content: content,
        conversationId: convId,
        context: chatContext,
      );

      // Generate AI response
      final aiResponse = await _generateAIResponse(
        content,
        convId,
        chatContext,
      );

      return [userMessage, aiResponse];
    } catch (e) {
      AppLogger.error('Error sending message', e);

      // Create error message
      final errorMessage = await _repository.createAIMessage(
        content:
            'I apologize, but I\'m having trouble responding right now. Please try again in a moment.',
        conversationId: convId,
        context: chatContext,
        isError: true,
        errorMessage: e.toString(),
      );

      return [
        await _repository.createUserMessage(
          content: content,
          conversationId: convId,
          context: chatContext,
        ),
        errorMessage,
      ];
    }
  }

  /// Get messages for a conversation
  List<ChatMessage> getMessagesForConversation(String conversationId) {
    return _repository.getMessagesForConversation(conversationId);
  }

  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    await _repository.markMessageAsRead(messageId);
  }

  // ============= AI INTEGRATION =============

  /// Generate AI response using Gemini or demo mode
  Future<ChatMessage> _generateAIResponse(
    String userMessage,
    String conversationId,
    ChatContext context,
  ) async {
    // Use demo responses if AI model is not initialized
    if (_aiModel == null || AppConfig.mockAiResponses) {
      return await _generateDemoResponse(userMessage, conversationId, context);
    }

    try {
      // Get conversation history for context
      final messages = _repository.getMessagesForConversation(conversationId);
      final recentMessages =
          messages.takeLast(10).toList(); // Last 10 messages for context

      // Get current mood context
      final moodContext = await _getCurrentMoodContext();

      // Build conversation context
      final systemPrompt = SpiritualGuidancePrompts.getSystemPrompt(
        context,
        moodData: moodContext,
      );

      // Build conversation history
      final conversationHistory = _buildConversationHistory(recentMessages);

      // Create full prompt
      final fullPrompt = '''
$systemPrompt

CONVERSATION HISTORY:
$conversationHistory

USER: $userMessage

SPIRITUAL COMPANION: ''';

      // Generate response
      final response = await _aiModel!.generateContent([
        Content.text(fullPrompt),
      ]);

      final responseText =
          response.text ?? 'I\'m here to listen and support you.';

      // Create and save AI message
      return await _repository.createAIMessage(
        content: responseText,
        conversationId: conversationId,
        context: context,
        metadata: {
          'promptType': 'conversational',
          'moodContext': moodContext,
          'generatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      AppLogger.error('AI response generation failed', e);

      // Fallback to predefined responses
      final fallbackResponse = _getFallbackResponse(userMessage, context);

      return await _repository.createAIMessage(
        content: fallbackResponse,
        conversationId: conversationId,
        context: context,
        metadata: {
          'fallback': true,
          'originalError': e.toString(),
        },
      );
    }
  }

  /// Send welcome message based on context
  Future<void> _sendWelcomeMessage(
    String conversationId,
    ChatContext context,
    Map<String, dynamic>? moodContext,
  ) async {
    String welcomeMessage;

    // Customize welcome based on mood
    final moodScore = moodContext?['score'] as int? ?? 5;

    switch (context) {
      case ChatContext.spiritual:
        welcomeMessage = moodScore <= 3
            ? 'I sense you may be going through a difficult time. I\'m here to offer spiritual comfort and guidance. How can I support you today?'
            : 'Peace be with you! I\'m here to accompany you on your spiritual journey. What\'s on your heart today?';
        break;

      case ChatContext.prayer:
        welcomeMessage =
            'Welcome to our prayer space. Whether you\'d like to pray together, need prayer guidance, or want to share prayer requests, I\'m here to support your connection with the divine.';
        break;

      case ChatContext.mood:
        welcomeMessage = moodScore <= 3
            ? 'I can see you\'re having a challenging time emotionally. You\'re not alone - I\'m here to listen and offer spiritual perspectives that might bring comfort.'
            : 'I\'m glad you\'re taking care of your emotional well-being. How are you feeling right now, and how can I support you spiritually?';
        break;

      case ChatContext.crisis:
        welcomeMessage =
            'I\'m here to provide immediate spiritual support during this difficult time. You are loved and not alone. If you\'re in immediate danger, please contact emergency services. How can I help bring you comfort right now?';
        break;

      case ChatContext.meditation:
        welcomeMessage =
            'Welcome to our meditation space. I\'m here to guide you toward inner peace and spiritual connection. Would you like a guided meditation, breathing exercise, or spiritual reflection?';
        break;

      case ChatContext.guidance:
        welcomeMessage =
            'I\'m honored to offer spiritual guidance for whatever you\'re facing. Whether it\'s a decision, challenge, or question about your spiritual path, I\'m here to listen and share wisdom.';
        break;

      default:
        welcomeMessage = QuickSpiritualResponses.getResponse('greeting');
    }

    await _repository.createAIMessage(
      content: welcomeMessage,
      conversationId: conversationId,
      context: context,
      metadata: {
        'messageType': 'welcome',
        'moodScore': moodScore,
      },
    );
  }

  // ============= HELPER METHODS =============

  /// Get current user mood context
  Future<Map<String, dynamic>?> _getCurrentMoodContext() async {
    try {
      await _moodService.initialize();
      final recentEntries = _moodService.getAllMoodEntries();

      if (recentEntries.isNotEmpty) {
        final latest = recentEntries.first;
        return {
          'score': latest.score,
          'emotions': latest.emotions,
          'timestamp': latest.timestamp.toIso8601String(),
          'notes': latest.notes,
        };
      }
    } catch (e) {
      AppLogger.warning('Could not fetch mood context: $e');
    }

    return null;
  }

  /// Build conversation history for AI context
  String _buildConversationHistory(List<ChatMessage> messages) {
    final history = StringBuffer();

    for (final message in messages) {
      final role = message.type == MessageType.user ? 'USER' : 'ASSISTANT';
      history.writeln('$role: ${message.content}');
    }

    return history.toString();
  }

  /// Generate demo response when AI is not available
  Future<ChatMessage> _generateDemoResponse(
    String userMessage,
    String conversationId,
    ChatContext context,
  ) async {
    // Simulate thinking time
    await Future.delayed(const Duration(milliseconds: 800));
    
    final responseContent = _getFallbackResponse(userMessage, context);
    
    return await _repository.createAIMessage(
      content: responseContent,
      conversationId: conversationId,
      context: context,
      metadata: {
        'mode': 'demo',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Get fallback response when AI fails
  String _getFallbackResponse(String userMessage, ChatContext context) {
    final lowerMessage = userMessage.toLowerCase();

    // Detect emotional keywords and respond appropriately
    if (lowerMessage.contains(RegExp(r'\b(anxious|worried|scared|afraid)\b'))) {
      return QuickSpiritualResponses.getResponse('anxiety');
    }

    if (lowerMessage.contains(RegExp(r'\b(thank|grateful|blessed|happy)\b'))) {
      return QuickSpiritualResponses.getResponse('gratitude');
    }

    if (lowerMessage.contains(RegExp(r'\b(doubt|uncertain|confused|lost)\b'))) {
      return QuickSpiritualResponses.getResponse('doubt');
    }

    if (lowerMessage.contains(RegExp(r'\b(pray|prayer)\b'))) {
      return QuickSpiritualResponses.getResponse('prayer_request');
    }

    // Context-based fallbacks
    switch (context) {
      case ChatContext.crisis:
        return 'I\'m here with you during this difficult time. You are not alone, and you are deeply loved. Can you tell me more about what you\'re experiencing?';

      case ChatContext.mood:
        return 'Thank you for sharing with me. Your feelings are valid and important. Would you like to explore what might help bring you some peace right now?';

      case ChatContext.prayer:
        return 'Prayer is a beautiful way to connect with the divine. Would you like me to suggest a prayer, or is there something specific you\'d like to pray about?';

      default:
        return 'I\'m here to listen and support you on your spiritual journey. Could you tell me more about what\'s on your heart today?';
    }
  }

  // ============= SEARCH AND ANALYTICS =============

  /// Search messages across conversations
  List<ChatMessage> searchMessages(String query, {ChatContext? context}) {
    return _repository.searchMessages(query, context: context);
  }

  /// Get conversation statistics
  Map<String, dynamic> getConversationStats(String conversationId) {
    return _repository.getConversationStats(conversationId);
  }

  /// Get chat insights and patterns
  Map<String, dynamic> getChatInsights() {
    final conversations = _repository.getAllConversations();
    final allMessages = _repository.getRecentMessages(limit: 1000);

    // Analyze conversation patterns
    final contextCounts = <ChatContext, int>{};
    final dailyCounts = <String, int>{};

    for (final conv in conversations) {
      contextCounts[conv.context] = (contextCounts[conv.context] ?? 0) + 1;
    }

    for (final message in allMessages) {
      if (message.type == MessageType.user) {
        final dateKey =
            '${message.timestamp.year}-${message.timestamp.month.toString().padLeft(2, '0')}-${message.timestamp.day.toString().padLeft(2, '0')}';
        dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      }
    }

    return {
      'totalConversations': conversations.length,
      'totalMessages': allMessages.length,
      'contextBreakdown':
          contextCounts.map((k, v) => MapEntry(k.toString(), v)),
      'dailyActivity': dailyCounts,
      'averageMessagesPerConversation':
          conversations.isEmpty ? 0 : allMessages.length / conversations.length,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  // ============= UTILITY =============

  /// Switch to a different conversation
  void switchConversation(String conversationId) {
    _currentConversationId = conversationId;

    // Get or create active session
    final activeSession =
        _repository.getActiveSessionForConversation(conversationId);
    if (activeSession != null) {
      _currentSessionId = activeSession.id;
    } else {
      // Create new session
      _repository
          .createSession(
        conversationId: conversationId,
        context: _repository.getConversation(conversationId)?.context ??
            ChatContext.general,
      )
          .then((session) {
        _currentSessionId = session.id;
      });
    }
  }

  /// Get current conversation ID
  String? getCurrentConversationId() => _currentConversationId;

  /// Clear all chat data
  Future<void> clearAllData() async {
    await _repository.clearAllData();
    _currentConversationId = null;
    _currentSessionId = null;
  }
}

// Extension to get last N elements from a list
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
