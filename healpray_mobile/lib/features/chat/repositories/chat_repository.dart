import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../../../core/utils/logger.dart';

/// Repository for managing chat messages and conversations locally
class ChatRepository {
  static ChatRepository? _instance;
  static ChatRepository get instance => _instance ??= ChatRepository._();
  
  ChatRepository._();
  
  // Hive box names
  static const String _messagesBoxName = 'chat_messages';
  static const String _conversationsBoxName = 'conversations';
  static const String _sessionsBoxName = 'chat_sessions';
  
  // Hive boxes
  Box<ChatMessage>? _messagesBox;
  Box<Conversation>? _conversationsBox;
  Box<ChatSession>? _sessionsBox;
  
  final _uuid = const Uuid();
  
  /// Initialize the repository and open Hive boxes
  Future<void> initialize() async {
    try {
      _messagesBox = await Hive.openBox<ChatMessage>(_messagesBoxName);
      _conversationsBox = await Hive.openBox<Conversation>(_conversationsBoxName);
      _sessionsBox = await Hive.openBox<ChatSession>(_sessionsBoxName);
      
      AppLogger.info('ChatRepository initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize ChatRepository', e);
      rethrow;
    }
  }
  
  /// Ensure boxes are initialized
  void _ensureInitialized() {
    if (_messagesBox == null || _conversationsBox == null || _sessionsBox == null) {
      throw Exception('ChatRepository not initialized. Call initialize() first.');
    }
  }
  
  // ============= CONVERSATION MANAGEMENT =============
  
  /// Create a new conversation
  Future<Conversation> createConversation({
    String? title,
    ChatContext context = ChatContext.general,
    Map<String, dynamic>? metadata,
  }) async {
    _ensureInitialized();
    
    final conversation = Conversation(
      id: _uuid.v4(),
      title: title ?? _generateConversationTitle(context),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      context: context,
      metadata: metadata,
    );
    
    await _conversationsBox!.put(conversation.id, conversation);
    AppLogger.info('Created conversation: ${conversation.id}');
    
    return conversation;
  }
  
  /// Get all conversations
  List<Conversation> getAllConversations() {
    _ensureInitialized();
    
    final conversations = _conversationsBox!.values.toList();
    // Sort by most recent first
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    
    return conversations;
  }
  
  /// Get conversation by ID
  Conversation? getConversation(String id) {
    _ensureInitialized();
    return _conversationsBox!.get(id);
  }
  
  /// Update conversation
  Future<void> updateConversation(Conversation conversation) async {
    _ensureInitialized();
    
    final updatedConversation = conversation.copyWith(
      updatedAt: DateTime.now(),
    );
    
    await _conversationsBox!.put(conversation.id, updatedConversation);
  }
  
  /// Delete conversation and all its messages
  Future<void> deleteConversation(String conversationId) async {
    _ensureInitialized();
    
    // Delete all messages in this conversation
    final messages = getMessagesForConversation(conversationId);
    for (final message in messages) {
      await _messagesBox!.delete(message.id);
    }
    
    // Delete the conversation
    await _conversationsBox!.delete(conversationId);
    
    AppLogger.info('Deleted conversation: $conversationId');
  }
  
  // ============= MESSAGE MANAGEMENT =============
  
  /// Save a chat message
  Future<ChatMessage> saveMessage(ChatMessage message) async {
    _ensureInitialized();
    
    await _messagesBox!.put(message.id, message);
    
    // Update conversation with latest message info
    final conversation = getConversation(message.conversationId);
    if (conversation != null) {
      final updatedMessageIds = List<String>.from(conversation.messageIds);
      if (!updatedMessageIds.contains(message.id)) {
        updatedMessageIds.add(message.id);
      }
      
      final updatedConversation = conversation.copyWith(
        messageIds: updatedMessageIds,
        lastMessage: message.content.length > 50 
          ? '${message.content.substring(0, 50)}...'
          : message.content,
        lastMessageAt: message.timestamp,
        updatedAt: DateTime.now(),
      );
      
      await updateConversation(updatedConversation);
    }
    
    return message;
  }
  
  /// Create and save a user message
  Future<ChatMessage> createUserMessage({
    required String content,
    required String conversationId,
    ChatContext context = ChatContext.general,
    Map<String, dynamic>? metadata,
  }) async {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      context: context,
      metadata: metadata,
      isRead: true,
    );
    
    return await saveMessage(message);
  }
  
  /// Create and save an AI message
  Future<ChatMessage> createAIMessage({
    required String content,
    required String conversationId,
    ChatContext context = ChatContext.general,
    Map<String, dynamic>? metadata,
    bool isError = false,
    String? errorMessage,
  }) async {
    final message = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.ai,
      timestamp: DateTime.now(),
      conversationId: conversationId,
      context: context,
      metadata: metadata,
      isRead: false,
      isError: isError,
      errorMessage: errorMessage,
    );
    
    return await saveMessage(message);
  }
  
  /// Get all messages for a conversation
  List<ChatMessage> getMessagesForConversation(String conversationId) {
    _ensureInitialized();
    
    final messages = _messagesBox!.values
        .where((message) => message.conversationId == conversationId)
        .toList();
    
    // Sort by timestamp (oldest first for chat display)
    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return messages;
  }
  
  /// Get recent messages across all conversations
  List<ChatMessage> getRecentMessages({int limit = 50}) {
    _ensureInitialized();
    
    final messages = _messagesBox!.values.toList();
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return messages.take(limit).toList();
  }
  
  /// Mark message as read
  Future<void> markMessageAsRead(String messageId) async {
    _ensureInitialized();
    
    final message = _messagesBox!.get(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(isRead: true);
      await _messagesBox!.put(messageId, updatedMessage);
    }
  }
  
  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    _ensureInitialized();
    
    final message = _messagesBox!.get(messageId);
    if (message != null) {
      await _messagesBox!.delete(messageId);
      
      // Update conversation message IDs
      final conversation = getConversation(message.conversationId);
      if (conversation != null) {
        final updatedMessageIds = List<String>.from(conversation.messageIds);
        updatedMessageIds.remove(messageId);
        
        final updatedConversation = conversation.copyWith(
          messageIds: updatedMessageIds,
          updatedAt: DateTime.now(),
        );
        
        await updateConversation(updatedConversation);
      }
    }
  }
  
  // ============= SESSION MANAGEMENT =============
  
  /// Create a new chat session
  Future<ChatSession> createSession({
    required String conversationId,
    ChatContext context = ChatContext.general,
    Map<String, dynamic>? moodContext,
    Map<String, dynamic>? userContext,
  }) async {
    _ensureInitialized();
    
    final session = ChatSession(
      id: _uuid.v4(),
      conversationId: conversationId,
      startedAt: DateTime.now(),
      context: context,
      moodContext: moodContext,
      userContext: userContext,
      isActive: true,
      messageCount: 0,
    );
    
    await _sessionsBox!.put(session.id, session);
    AppLogger.info('Created chat session: ${session.id}');
    
    return session;
  }
  
  /// End a chat session
  Future<void> endSession(String sessionId, {String? summary}) async {
    _ensureInitialized();
    
    final session = _sessionsBox!.get(sessionId);
    if (session != null) {
      final updatedSession = session.copyWith(
        endedAt: DateTime.now(),
        isActive: false,
        summary: summary,
      );
      
      await _sessionsBox!.put(sessionId, updatedSession);
    }
  }
  
  /// Get active session for conversation
  ChatSession? getActiveSessionForConversation(String conversationId) {
    _ensureInitialized();
    
    return _sessionsBox!.values.firstWhere(
      (session) => session.conversationId == conversationId && 
                   (session.isActive ?? false),
      orElse: () => null,
    );
  }
  
  // ============= SEARCH AND ANALYTICS =============
  
  /// Search messages by content
  List<ChatMessage> searchMessages(String query, {ChatContext? context}) {
    _ensureInitialized();
    
    final messages = _messagesBox!.values.where((message) {
      final matchesQuery = message.content.toLowerCase().contains(query.toLowerCase());
      final matchesContext = context == null || message.context == context;
      return matchesQuery && matchesContext;
    }).toList();
    
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return messages;
  }
  
  /// Get conversation statistics
  Map<String, dynamic> getConversationStats(String conversationId) {
    final messages = getMessagesForConversation(conversationId);
    final userMessages = messages.where((m) => m.type == MessageType.user).length;
    final aiMessages = messages.where((m) => m.type == MessageType.ai).length;
    final conversation = getConversation(conversationId);
    
    return {
      'totalMessages': messages.length,
      'userMessages': userMessages,
      'aiMessages': aiMessages,
      'createdAt': conversation?.createdAt,
      'lastMessageAt': conversation?.lastMessageAt,
      'context': conversation?.context.toString(),
    };
  }
  
  // ============= UTILITY METHODS =============
  
  /// Generate conversation title based on context
  String _generateConversationTitle(ChatContext context) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    
    switch (context) {
      case ChatContext.spiritual:
        return 'Spiritual Guidance - $timeStr';
      case ChatContext.prayer:
        return 'Prayer Session - $timeStr';
      case ChatContext.mood:
        return 'Mood Support - $timeStr';
      case ChatContext.crisis:
        return 'Crisis Support - $timeStr';
      case ChatContext.meditation:
        return 'Meditation Guide - $timeStr';
      case ChatContext.guidance:
        return 'Life Guidance - $timeStr';
      default:
        return 'Chat - $timeStr';
    }
  }
  
  /// Clear all chat data (use with caution)
  Future<void> clearAllData() async {
    _ensureInitialized();
    
    await _messagesBox!.clear();
    await _conversationsBox!.clear();
    await _sessionsBox!.clear();
    
    AppLogger.warning('Cleared all chat data');
  }
  
  /// Get total storage usage
  int getTotalMessageCount() {
    _ensureInitialized();
    return _messagesBox!.length;
  }
  
  /// Export conversation data (for backup/sync)
  Map<String, dynamic> exportConversationData(String conversationId) {
    final conversation = getConversation(conversationId);
    final messages = getMessagesForConversation(conversationId);
    
    return {
      'conversation': conversation?.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
