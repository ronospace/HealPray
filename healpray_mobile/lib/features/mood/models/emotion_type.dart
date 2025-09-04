import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'emotion_type.g.dart';

/// Comprehensive emotion types for mood tracking
@HiveType(typeId: 11)
enum EmotionType {
  // Joy & Positive Emotions
  @HiveField(0)
  joyful,
  @HiveField(1)
  grateful,
  @HiveField(2)
  peaceful,
  @HiveField(3)
  hopeful,
  @HiveField(4)
  blessed,
  @HiveField(5)
  content,
  @HiveField(6)
  excited,
  @HiveField(7)
  loved,
  @HiveField(8)
  confident,
  @HiveField(9)
  serene,

  // Sadness & Melancholy
  @HiveField(10)
  sad,
  @HiveField(11)
  lonely,
  @HiveField(12)
  disappointed,
  @HiveField(13)
  heartbroken,
  @HiveField(14)
  grieving,
  @HiveField(15)
  melancholy,
  @HiveField(16)
  empty,
  @HiveField(17)
  lost,
  @HiveField(18)
  discouraged,
  @HiveField(19)
  sorrowful,

  // Anxiety & Fear
  @HiveField(20)
  anxious,
  @HiveField(21)
  worried,
  @HiveField(22)
  fearful,
  @HiveField(23)
  overwhelmed,
  @HiveField(24)
  stressed,
  @HiveField(25)
  nervous,
  @HiveField(26)
  panicked,
  @HiveField(27)
  uncertain,
  @HiveField(28)
  restless,
  @HiveField(29)
  troubled,

  // Anger & Frustration
  @HiveField(30)
  angry,
  @HiveField(31)
  frustrated,
  @HiveField(32)
  irritated,
  @HiveField(33)
  resentful,
  @HiveField(34)
  bitter,
  @HiveField(35)
  annoyed,
  @HiveField(36)
  outraged,
  @HiveField(37)
  indignant,
  @HiveField(38)
  impatient,
  @HiveField(39)
  furious,

  // Spiritual & Contemplative
  @HiveField(40)
  prayerful,
  @HiveField(41)
  reflective,
  @HiveField(42)
  seeking,
  @HiveField(43)
  questioning,
  @HiveField(44)
  faithful,
  @HiveField(45)
  doubtful,
  @HiveField(46)
  reverent,
  @HiveField(47)
  contemplative,
  @HiveField(48)
  surrendering,
  @HiveField(49)
  worshipful,

  // Physical & Mental States
  @HiveField(50)
  tired,
  @HiveField(51)
  energetic,
  @HiveField(52)
  sick,
  @HiveField(53)
  healthy,
  @HiveField(54)
  confused,
  @HiveField(55)
  clear,
  @HiveField(56)
  focused,
  @HiveField(57)
  distracted,
  @HiveField(58)
  motivated,
  @HiveField(59)
  apathetic,
}

/// Extension methods for EmotionType
extension EmotionTypeExtension on EmotionType {
  /// Get the display name for the emotion
  String get displayName {
    switch (this) {
      case EmotionType.joyful:
        return 'Joyful';
      case EmotionType.grateful:
        return 'Grateful';
      case EmotionType.peaceful:
        return 'Peaceful';
      case EmotionType.hopeful:
        return 'Hopeful';
      case EmotionType.blessed:
        return 'Blessed';
      case EmotionType.content:
        return 'Content';
      case EmotionType.excited:
        return 'Excited';
      case EmotionType.loved:
        return 'Loved';
      case EmotionType.confident:
        return 'Confident';
      case EmotionType.serene:
        return 'Serene';

      case EmotionType.sad:
        return 'Sad';
      case EmotionType.lonely:
        return 'Lonely';
      case EmotionType.disappointed:
        return 'Disappointed';
      case EmotionType.heartbroken:
        return 'Heartbroken';
      case EmotionType.grieving:
        return 'Grieving';
      case EmotionType.melancholy:
        return 'Melancholy';
      case EmotionType.empty:
        return 'Empty';
      case EmotionType.lost:
        return 'Lost';
      case EmotionType.discouraged:
        return 'Discouraged';
      case EmotionType.sorrowful:
        return 'Sorrowful';

      case EmotionType.anxious:
        return 'Anxious';
      case EmotionType.worried:
        return 'Worried';
      case EmotionType.fearful:
        return 'Fearful';
      case EmotionType.overwhelmed:
        return 'Overwhelmed';
      case EmotionType.stressed:
        return 'Stressed';
      case EmotionType.nervous:
        return 'Nervous';
      case EmotionType.panicked:
        return 'Panicked';
      case EmotionType.uncertain:
        return 'Uncertain';
      case EmotionType.restless:
        return 'Restless';
      case EmotionType.troubled:
        return 'Troubled';

      case EmotionType.angry:
        return 'Angry';
      case EmotionType.frustrated:
        return 'Frustrated';
      case EmotionType.irritated:
        return 'Irritated';
      case EmotionType.resentful:
        return 'Resentful';
      case EmotionType.bitter:
        return 'Bitter';
      case EmotionType.annoyed:
        return 'Annoyed';
      case EmotionType.outraged:
        return 'Outraged';
      case EmotionType.indignant:
        return 'Indignant';
      case EmotionType.impatient:
        return 'Impatient';
      case EmotionType.furious:
        return 'Furious';

      case EmotionType.prayerful:
        return 'Prayerful';
      case EmotionType.reflective:
        return 'Reflective';
      case EmotionType.seeking:
        return 'Seeking';
      case EmotionType.questioning:
        return 'Questioning';
      case EmotionType.faithful:
        return 'Faithful';
      case EmotionType.doubtful:
        return 'Doubtful';
      case EmotionType.reverent:
        return 'Reverent';
      case EmotionType.contemplative:
        return 'Contemplative';
      case EmotionType.surrendering:
        return 'Surrendering';
      case EmotionType.worshipful:
        return 'Worshipful';

      case EmotionType.tired:
        return 'Tired';
      case EmotionType.energetic:
        return 'Energetic';
      case EmotionType.sick:
        return 'Sick';
      case EmotionType.healthy:
        return 'Healthy';
      case EmotionType.confused:
        return 'Confused';
      case EmotionType.clear:
        return 'Clear';
      case EmotionType.focused:
        return 'Focused';
      case EmotionType.distracted:
        return 'Distracted';
      case EmotionType.motivated:
        return 'Motivated';
      case EmotionType.apathetic:
        return 'Apathetic';
    }
  }

  /// Get the emoji representation for the emotion
  String get emoji {
    switch (this) {
      case EmotionType.joyful:
        return '😄';
      case EmotionType.grateful:
        return '🙏';
      case EmotionType.peaceful:
        return '😌';
      case EmotionType.hopeful:
        return '🌟';
      case EmotionType.blessed:
        return '✨';
      case EmotionType.content:
        return '😊';
      case EmotionType.excited:
        return '🤗';
      case EmotionType.loved:
        return '💕';
      case EmotionType.confident:
        return '💪';
      case EmotionType.serene:
        return '🕊️';

      case EmotionType.sad:
        return '😢';
      case EmotionType.lonely:
        return '😔';
      case EmotionType.disappointed:
        return '😞';
      case EmotionType.heartbroken:
        return '💔';
      case EmotionType.grieving:
        return '😭';
      case EmotionType.melancholy:
        return '😕';
      case EmotionType.empty:
        return '😶';
      case EmotionType.lost:
        return '😵‍💫';
      case EmotionType.discouraged:
        return '😟';
      case EmotionType.sorrowful:
        return '😥';

      case EmotionType.anxious:
        return '😰';
      case EmotionType.worried:
        return '😟';
      case EmotionType.fearful:
        return '😨';
      case EmotionType.overwhelmed:
        return '🤯';
      case EmotionType.stressed:
        return '😵';
      case EmotionType.nervous:
        return '😬';
      case EmotionType.panicked:
        return '😱';
      case EmotionType.uncertain:
        return '🤔';
      case EmotionType.restless:
        return '😤';
      case EmotionType.troubled:
        return '😣';

      case EmotionType.angry:
        return '😠';
      case EmotionType.frustrated:
        return '😤';
      case EmotionType.irritated:
        return '😒';
      case EmotionType.resentful:
        return '😑';
      case EmotionType.bitter:
        return '🙄';
      case EmotionType.annoyed:
        return '😠';
      case EmotionType.outraged:
        return '😡';
      case EmotionType.indignant:
        return '😤';
      case EmotionType.impatient:
        return '⏰';
      case EmotionType.furious:
        return '🤬';

      case EmotionType.prayerful:
        return '🙏';
      case EmotionType.reflective:
        return '🤔';
      case EmotionType.seeking:
        return '🔍';
      case EmotionType.questioning:
        return '❓';
      case EmotionType.faithful:
        return '✝️';
      case EmotionType.doubtful:
        return '🤷';
      case EmotionType.reverent:
        return '🛐';
      case EmotionType.contemplative:
        return '🧘';
      case EmotionType.surrendering:
        return '🕊️';
      case EmotionType.worshipful:
        return '🙌';

      case EmotionType.tired:
        return '😴';
      case EmotionType.energetic:
        return '⚡';
      case EmotionType.sick:
        return '🤒';
      case EmotionType.healthy:
        return '💚';
      case EmotionType.confused:
        return '😵';
      case EmotionType.clear:
        return '🌞';
      case EmotionType.focused:
        return '🎯';
      case EmotionType.distracted:
        return '🤷';
      case EmotionType.motivated:
        return '🚀';
      case EmotionType.apathetic:
        return '😐';
    }
  }

  /// Get the color associated with the emotion category
  Color get color {
    switch (category) {
      case EmotionCategory.positive:
        return Colors.green.shade400;
      case EmotionCategory.sadness:
        return Colors.blue.shade400;
      case EmotionCategory.anxiety:
        return Colors.orange.shade400;
      case EmotionCategory.anger:
        return Colors.red.shade400;
      case EmotionCategory.spiritual:
        return Colors.purple.shade400;
      case EmotionCategory.physical:
        return Colors.teal.shade400;
    }
  }

  /// Get the emotion category
  EmotionCategory get category {
    switch (this) {
      case EmotionType.joyful:
      case EmotionType.grateful:
      case EmotionType.peaceful:
      case EmotionType.hopeful:
      case EmotionType.blessed:
      case EmotionType.content:
      case EmotionType.excited:
      case EmotionType.loved:
      case EmotionType.confident:
      case EmotionType.serene:
        return EmotionCategory.positive;

      case EmotionType.sad:
      case EmotionType.lonely:
      case EmotionType.disappointed:
      case EmotionType.heartbroken:
      case EmotionType.grieving:
      case EmotionType.melancholy:
      case EmotionType.empty:
      case EmotionType.lost:
      case EmotionType.discouraged:
      case EmotionType.sorrowful:
        return EmotionCategory.sadness;

      case EmotionType.anxious:
      case EmotionType.worried:
      case EmotionType.fearful:
      case EmotionType.overwhelmed:
      case EmotionType.stressed:
      case EmotionType.nervous:
      case EmotionType.panicked:
      case EmotionType.uncertain:
      case EmotionType.restless:
      case EmotionType.troubled:
        return EmotionCategory.anxiety;

      case EmotionType.angry:
      case EmotionType.frustrated:
      case EmotionType.irritated:
      case EmotionType.resentful:
      case EmotionType.bitter:
      case EmotionType.annoyed:
      case EmotionType.outraged:
      case EmotionType.indignant:
      case EmotionType.impatient:
      case EmotionType.furious:
        return EmotionCategory.anger;

      case EmotionType.prayerful:
      case EmotionType.reflective:
      case EmotionType.seeking:
      case EmotionType.questioning:
      case EmotionType.faithful:
      case EmotionType.doubtful:
      case EmotionType.reverent:
      case EmotionType.contemplative:
      case EmotionType.surrendering:
      case EmotionType.worshipful:
        return EmotionCategory.spiritual;

      case EmotionType.tired:
      case EmotionType.energetic:
      case EmotionType.sick:
      case EmotionType.healthy:
      case EmotionType.confused:
      case EmotionType.clear:
      case EmotionType.focused:
      case EmotionType.distracted:
      case EmotionType.motivated:
      case EmotionType.apathetic:
        return EmotionCategory.physical;
    }
  }

  /// Get suggested spiritual practices for this emotion
  List<String> get suggestedPractices {
    switch (category) {
      case EmotionCategory.positive:
        return ['Gratitude Prayer', 'Praise & Worship', 'Meditation', 'Journaling'];
      case EmotionCategory.sadness:
        return ['Comfort Prayer', 'Lament', 'Scripture Reading', 'Community Prayer'];
      case EmotionCategory.anxiety:
        return ['Peace Prayer', 'Breathing Meditation', 'Trust Affirmations', 'Calming Scriptures'];
      case EmotionCategory.anger:
        return ['Forgiveness Prayer', 'Peaceful Reflection', 'Walking Meditation', 'Patience Prayer'];
      case EmotionCategory.spiritual:
        return ['Contemplative Prayer', 'Scripture Study', 'Silent Reflection', 'Spiritual Direction'];
      case EmotionCategory.physical:
        return ['Healing Prayer', 'Body Gratitude', 'Energy Meditation', 'Rest Prayer'];
    }
  }
}

/// Categories for grouping emotions
enum EmotionCategory {
  positive,
  sadness,
  anxiety,
  anger,
  spiritual,
  physical,
}

/// Extension for EmotionCategory
extension EmotionCategoryExtension on EmotionCategory {
  String get displayName {
    switch (this) {
      case EmotionCategory.positive:
        return 'Joy & Positive';
      case EmotionCategory.sadness:
        return 'Sadness & Loss';
      case EmotionCategory.anxiety:
        return 'Anxiety & Fear';
      case EmotionCategory.anger:
        return 'Anger & Frustration';
      case EmotionCategory.spiritual:
        return 'Spiritual & Contemplative';
      case EmotionCategory.physical:
        return 'Physical & Mental';
    }
  }

  IconData get icon {
    switch (this) {
      case EmotionCategory.positive:
        return Icons.sentiment_very_satisfied;
      case EmotionCategory.sadness:
        return Icons.sentiment_very_dissatisfied;
      case EmotionCategory.anxiety:
        return Icons.sentiment_neutral;
      case EmotionCategory.anger:
        return Icons.whatshot;
      case EmotionCategory.spiritual:
        return Icons.church;
      case EmotionCategory.physical:
        return Icons.fitness_center;
    }
  }
}
