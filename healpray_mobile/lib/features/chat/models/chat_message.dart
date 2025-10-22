import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Enum for different types of chat messages
@HiveType(typeId: 4)
enum MessageType {
  @HiveField(0)
  user,

  @HiveField(1)
  ai,

  @HiveField(2)
  system,

  @HiveField(3)
  suggestion,
}

/// Enum for different chat contexts and purposes
@HiveType(typeId: 5)
enum ChatContext {
  @HiveField(0)
  general,

  @HiveField(1)
  spiritual,

  @HiveField(2)
  prayer,

  @HiveField(3)
  mood,

  @HiveField(4)
  crisis,

  @HiveField(5)
  meditation,

  @HiveField(6)
  guidance,
}

/// Individual chat message model
@freezed
@HiveType(typeId: 6)
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    @HiveField(0) required String id,
    @HiveField(1) required String content,
    @HiveField(2) required MessageType type,
    @HiveField(3) required DateTime timestamp,
    @HiveField(4) required String conversationId,
    @HiveField(5) @Default(ChatContext.general) ChatContext context,
    @HiveField(6) Map<String, dynamic>? metadata,
    @HiveField(7) bool? isRead,
    @HiveField(8) bool? isError,
    @HiveField(9) String? errorMessage,
    @HiveField(10) List<String>? attachments,
    @HiveField(11) String? replyToMessageId,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

/// Chat conversation model
@freezed
@HiveType(typeId: 7)
class Conversation with _$Conversation {
  const factory Conversation({
    @HiveField(0) required String id,
    @HiveField(1) required String title,
    @HiveField(2) required DateTime createdAt,
    @HiveField(3) required DateTime updatedAt,
    @HiveField(4) @Default(ChatContext.general) ChatContext context,
    @HiveField(5) @Default([]) List<String> messageIds,
    @HiveField(6) Map<String, dynamic>? metadata,
    @HiveField(7) bool? isArchived,
    @HiveField(8) bool? isPinned,
    @HiveField(9) String? lastMessage,
    @HiveField(10) DateTime? lastMessageAt,
    @HiveField(11) int? unreadCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

/// Chat session with additional context and mood integration
@freezed
@HiveType(typeId: 8)
class ChatSession with _$ChatSession {
  const factory ChatSession({
    @HiveField(0) required String id,
    @HiveField(1) required String conversationId,
    @HiveField(2) required DateTime startedAt,
    @HiveField(3) DateTime? endedAt,
    @HiveField(4) @Default(ChatContext.general) ChatContext context,
    @HiveField(5) Map<String, dynamic>? moodContext,
    @HiveField(6) Map<String, dynamic>? userContext,
    @HiveField(7) List<String>? topics,
    @HiveField(8) int? messageCount,
    @HiveField(9) bool? isActive,
    @HiveField(10) String? summary,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}

/// Predefined spiritual guidance prompts and contexts
class SpiritualGuidancePrompts {
  static const Map<ChatContext, String> contextPrompts = {
    ChatContext.spiritual: '''
You are a compassionate spiritual companion providing guidance rooted in love, wisdom, and understanding. 
Offer supportive advice that helps the user grow spiritually while respecting their beliefs and journey.
''',
    ChatContext.prayer: '''
You are a prayer companion helping users connect with the divine through meaningful prayer. 
Provide guidance on prayer practices, suggest relevant prayers, and help deepen their spiritual connection.
''',
    ChatContext.mood: '''
You are an empathetic spiritual counselor helping users process their emotions through a spiritual lens. 
Offer comfort, biblical wisdom, and spiritual practices that can help improve their emotional well-being.
''',
    ChatContext.crisis: '''
You are a crisis spiritual counselor providing immediate comfort and guidance during difficult times. 
Offer hope, spiritual strength, and practical steps while encouraging professional help when needed.
IMPORTANT: If someone expresses thoughts of self-harm, encourage them to seek immediate professional help.
''',
    ChatContext.meditation: '''
You are a meditation guide helping users find peace and connection with the divine through contemplative practices.
Offer guided meditations, breathing exercises, and spiritual reflection techniques.
''',
    ChatContext.guidance: '''
You are a wise spiritual mentor providing life guidance through spiritual principles and wisdom.
Help users make decisions aligned with their values and spiritual beliefs.
''',
  };

  /// Get system prompt based on context and user's mood
  static String getSystemPrompt(ChatContext context,
      {Map<String, dynamic>? moodData}) {
    String basePrompt =
        contextPrompts[context] ?? contextPrompts[ChatContext.general]!;

    if (moodData != null) {
      final moodScore = moodData['score'] as int? ?? 5;
      final emotions = moodData['emotions'] as List? ?? [];

      String moodContext = '''
      
CURRENT USER MOOD CONTEXT:
- Mood Level: $moodScore/10
- Recent Emotions: ${emotions.join(', ')}

Please be especially sensitive to their current emotional state and provide appropriate spiritual support.
''';

      if (moodScore <= 3) {
        moodContext += '''
The user is experiencing low mood. Offer extra compassion, hope, and gentle encouragement.
Focus on providing comfort and reminding them of their inherent worth and divine love.
''';
      } else if (moodScore >= 8) {
        moodContext += '''
The user is in a positive mood. Help them maintain this joy and perhaps explore gratitude practices.
Encourage them to use this positive energy for spiritual growth and helping others.
''';
      }

      basePrompt += moodContext;
    }

    return basePrompt;
  }
}

/// Quick spiritual responses for common situations
class QuickSpiritualResponses {
  static const Map<String, List<String>> responses = {
    'greeting': [
      'Peace be with you! How can I support you in your spiritual journey today?',
      'Blessings! I\'m here to listen and offer spiritual guidance. What\'s on your heart?',
      'Welcome, dear soul. How may I help you find peace and spiritual clarity today?',
    ],
    'anxiety': [
      'I understand you\'re feeling anxious. Let\'s breathe together and remember that you are held in divine love.',
      'Anxiety can feel overwhelming, but remember: "Cast all your anxiety on Him because He cares for you." You\'re not alone.',
      'Your worries are valid. Let\'s find some peace together through prayer and spiritual grounding.',
    ],
    'gratitude': [
      'What a beautiful heart of gratitude you have! Gratitude truly transforms our spiritual perspective.',
      'I\'m so glad you\'re experiencing joy and thankfulness. These moments of gratitude are sacred gifts.',
      'Your grateful spirit is inspiring! How wonderful to witness the blessings in your life.',
    ],
    'doubt': [
      'Spiritual doubt is often part of a deeper journey toward faith. Your questions are valid and important.',
      'Even in uncertainty, you are beloved and held. Doubt can sometimes be the pathway to deeper understanding.',
      'It\'s okay to question and seek. Many spiritual seekers have walked this path of uncertainty before finding clarity.',
    ],
    'prayer_request': [
      'I would be honored to pray with you. What is weighing on your heart that we can bring to the divine?',
      'Prayer is a powerful way to connect with the sacred. Tell me what you\'d like to pray about.',
      'Let\'s create a sacred space for prayer together. What intention would you like to hold?',
    ],
  };

  static String getResponse(String category) {
    final responses = QuickSpiritualResponses.responses[category];
    if (responses != null && responses.isNotEmpty) {
      return responses[DateTime.now().millisecond % responses.length];
    }
    return 'I\'m here to listen and support you. How can I help you today?';
  }
}
