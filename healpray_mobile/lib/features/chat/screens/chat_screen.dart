import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/gradient_text.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/conversation_context_selector.dart';

/// Main chat screen for AI spiritual guidance
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.conversationId});

  final String? conversationId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final ChatService _chatService = ChatService.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  List<ChatMessage> _messages = [];
  Conversation? _currentConversation;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _showContextSelector = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);

    try {
      await _chatService.initialize();

      if (widget.conversationId != null) {
        // Load existing conversation
        _currentConversation =
            _chatService.getConversation(widget.conversationId!);
        if (_currentConversation != null) {
          _messages =
              _chatService.getMessagesForConversation(widget.conversationId!);
          _chatService.switchConversation(widget.conversationId!);
        }
      } else {
        // Start new conversation with spiritual context
        _currentConversation = await _chatService.startConversation(
          context: ChatContext.spiritual,
        );
        _messages =
            _chatService.getMessagesForConversation(_currentConversation!.id);
      }

      setState(() => _isInitialized = true);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      _showErrorSnackBar('Failed to initialize chat. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: AnimatedGradientBackground(
        child: _isLoading
            ? _buildLoadingState()
            : _isInitialized
                ? _buildChatInterface()
                : _buildErrorState(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GradientText(
            _currentConversation?.title ?? 'Chat with Sophia',
            gradient: const LinearGradient(
              colors: [Colors.white, Color(0xFFE5F0FF)],
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (_currentConversation != null)
            Text(
              _getContextDisplayName(_currentConversation!.context),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () =>
              setState(() => _showContextSelector = !_showContextSelector),
          icon: Icon(
            _showContextSelector ? Icons.close : Icons.tune,
            color: Colors.white,
          ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'new_conversation',
              child: ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('New Conversation'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'conversation_history',
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text('Conversation History'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'crisis_support',
              child: ListTile(
                leading: Icon(Icons.support_agent, color: Colors.red),
                title: Text('Crisis Support'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.healingTeal),
          ),
          SizedBox(height: 16),
          Text(
            'Sophia is getting ready to chat with you...',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to connect',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please check your connection and try again',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeChat,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface() {
    return Column(
      children: [
        // Context selector
        if (_showContextSelector)
          ConversationContextSelector(
            currentContext:
                _currentConversation?.context ?? ChatContext.spiritual,
            onContextChanged: _switchContext,
          ),

        // Messages area
        Expanded(
          child: _messages.isEmpty ? _buildEmptyState() : _buildMessagesList(),
        ),

        // Input area
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTheme.lightGray, width: 1),
            ),
          ),
          child: SafeArea(
            child: ChatInputField(
              controller: _messageController,
              onSendMessage: _sendMessage,
              isLoading: _isLoading,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.healingTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline,
                size: 40,
                color: AppTheme.healingTeal,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Your Spiritual Companion',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'I\'m here to provide spiritual guidance, support, and companionship on your journey. Share what\'s on your heart.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('How can I find peace?'),
                _buildSuggestionChip('I need prayer guidance'),
                _buildSuggestionChip('Feeling anxious today'),
                _buildSuggestionChip('Seeking spiritual direction'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () => _sendMessage(text),
      backgroundColor: AppTheme.healingTeal.withValues(alpha: 0.1),
      labelStyle: const TextStyle(
        color: AppTheme.healingTeal,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.healingTeal, width: 1),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isLast = index == _messages.length - 1;

        return Padding(
          padding: EdgeInsets.only(
            bottom: isLast ? 16 : 8,
          ),
          child: MessageBubble(
            message: message,
            onRetry:
                message.isError == true ? () => _retryMessage(message) : null,
          ),
        );
      },
    );
  }

  // ============= ACTIONS =============

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty || _currentConversation == null) return;

    setState(() => _isLoading = true);

    try {
      final newMessages = await _chatService.sendMessage(
        content.trim(),
        conversationId: _currentConversation!.id,
      );

      setState(() {
        _messages.addAll(newMessages);
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
      _showErrorSnackBar('Failed to send message. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _retryMessage(ChatMessage failedMessage) async {
    setState(() => _isLoading = true);

    try {
      // Find the user message that preceded this failed AI response
      final messageIndex = _messages.indexOf(failedMessage);
      if (messageIndex > 0) {
        final userMessage = _messages[messageIndex - 1];
        if (userMessage.type == MessageType.user) {
          // Retry with the original user message
          final newMessages = await _chatService.sendMessage(
            userMessage.content,
            conversationId: _currentConversation!.id,
          );

          // Remove the failed message and add the new response
          setState(() {
            _messages.removeAt(messageIndex);
            _messages.add(newMessages.last); // Add only the AI response
          });

          _scrollToBottom();
        }
      }
    } catch (e) {
      debugPrint('Error retrying message: $e');
      _showErrorSnackBar('Retry failed. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _switchContext(ChatContext newContext) async {
    setState(() => _showContextSelector = false);

    if (_currentConversation?.context == newContext) return;

    // Start new conversation with different context
    try {
      setState(() => _isLoading = true);

      _currentConversation = await _chatService.startConversation(
        context: newContext,
      );

      _messages =
          _chatService.getMessagesForConversation(_currentConversation!.id);

      setState(() {});
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error switching context: $e');
      _showErrorSnackBar('Failed to switch context. Please try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new_conversation':
        _startNewConversation();
        break;
      case 'conversation_history':
        _showConversationHistory();
        break;
      case 'crisis_support':
        _startCrisisSupport();
        break;
    }
  }

  // ============= UTILITY METHODS =============

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  String _getContextDisplayName(ChatContext context) {
    switch (context) {
      case ChatContext.spiritual:
        return 'Spiritual Guidance';
      case ChatContext.prayer:
        return 'Prayer Support';
      case ChatContext.mood:
        return 'Emotional Support';
      case ChatContext.crisis:
        return 'Crisis Support';
      case ChatContext.meditation:
        return 'Meditation Guide';
      case ChatContext.guidance:
        return 'Life Guidance';
      default:
        return 'General Chat';
    }
  }

  Future<void> _startNewConversation() async {
    // Implementation for starting new conversation
  }

  void _showConversationHistory() {
    // Implementation for showing conversation history
  }

  Future<void> _startCrisisSupport() async {
    // Implementation for crisis support
  }
}
