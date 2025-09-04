/// Intensity levels for mood tracking
enum MoodIntensity {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
}

/// Extension methods for MoodIntensity
extension MoodIntensityExtension on MoodIntensity {
  String get displayName {
    switch (this) {
      case MoodIntensity.veryLow:
        return 'Very Low';
      case MoodIntensity.low:
        return 'Low';
      case MoodIntensity.moderate:
        return 'Moderate';
      case MoodIntensity.high:
        return 'High';
      case MoodIntensity.veryHigh:
        return 'Very High';
    }
  }

  int get value {
    switch (this) {
      case MoodIntensity.veryLow:
        return 1;
      case MoodIntensity.low:
        return 2;
      case MoodIntensity.moderate:
        return 3;
      case MoodIntensity.high:
        return 4;
      case MoodIntensity.veryHigh:
        return 5;
    }
  }

  static MoodIntensity fromValue(int value) {
    switch (value) {
      case 1:
        return MoodIntensity.veryLow;
      case 2:
        return MoodIntensity.low;
      case 3:
        return MoodIntensity.moderate;
      case 4:
        return MoodIntensity.high;
      case 5:
        return MoodIntensity.veryHigh;
      default:
        return MoodIntensity.moderate;
    }
  }

  String get emoji {
    switch (this) {
      case MoodIntensity.veryLow:
        return '😴';
      case MoodIntensity.low:
        return '😕';
      case MoodIntensity.moderate:
        return '😐';
      case MoodIntensity.high:
        return '😊';
      case MoodIntensity.veryHigh:
        return '🤩';
    }
  }
}

/// Common triggers that affect mood
enum MoodTrigger {
  // Spiritual & Faith-related
  prayer,
  worship,
  scripture,
  church,
  fellowship,
  ministry,
  spiritualDoubt,
  prayerAnswered,
  
  // Relationships
  family,
  friends,
  romantic,
  conflict,
  loneliness,
  community,
  socialEvent,
  
  // Work & Achievement
  workStress,
  workSuccess,
  jobSearch,
  productivity,
  deadline,
  teamwork,
  recognition,
  
  // Health & Physical
  exercise,
  sleep,
  sickness,
  pain,
  medication,
  nutrition,
  energyLevel,
  
  // Life Events
  celebration,
  loss,
  transition,
  milestone,
  disappointment,
  surprise,
  travel,
  
  // Mental & Emotional
  stress,
  anxiety,
  nostalgia,
  anticipation,
  boredom,
  overwhelm,
  clarity,
  
  // External Factors
  weather,
  news,
  environment,
  music,
  nature,
  technology,
  money,
  
  // Personal Growth
  learning,
  creativity,
  achievement,
  failure,
  forgiveness,
  gratitude,
  reflection,
  
  // Crisis & Support
  crisis,
  support,
  counseling,
  healing,
  breakthrough,
  setback,
  recovery,
  
  // Other
  unknown,
  multiple,
  other,
}

/// Extension methods for MoodTrigger
extension MoodTriggerExtension on MoodTrigger {
  String get displayName {
    switch (this) {
      // Spiritual & Faith-related
      case MoodTrigger.prayer:
        return 'Prayer';
      case MoodTrigger.worship:
        return 'Worship';
      case MoodTrigger.scripture:
        return 'Scripture Reading';
      case MoodTrigger.church:
        return 'Church';
      case MoodTrigger.fellowship:
        return 'Fellowship';
      case MoodTrigger.ministry:
        return 'Ministry';
      case MoodTrigger.spiritualDoubt:
        return 'Spiritual Doubt';
      case MoodTrigger.prayerAnswered:
        return 'Answered Prayer';
        
      // Relationships
      case MoodTrigger.family:
        return 'Family';
      case MoodTrigger.friends:
        return 'Friends';
      case MoodTrigger.romantic:
        return 'Romantic';
      case MoodTrigger.conflict:
        return 'Conflict';
      case MoodTrigger.loneliness:
        return 'Loneliness';
      case MoodTrigger.community:
        return 'Community';
      case MoodTrigger.socialEvent:
        return 'Social Event';
        
      // Work & Achievement
      case MoodTrigger.workStress:
        return 'Work Stress';
      case MoodTrigger.workSuccess:
        return 'Work Success';
      case MoodTrigger.jobSearch:
        return 'Job Search';
      case MoodTrigger.productivity:
        return 'Productivity';
      case MoodTrigger.deadline:
        return 'Deadline';
      case MoodTrigger.teamwork:
        return 'Teamwork';
      case MoodTrigger.recognition:
        return 'Recognition';
        
      // Health & Physical
      case MoodTrigger.exercise:
        return 'Exercise';
      case MoodTrigger.sleep:
        return 'Sleep';
      case MoodTrigger.sickness:
        return 'Sickness';
      case MoodTrigger.pain:
        return 'Pain';
      case MoodTrigger.medication:
        return 'Medication';
      case MoodTrigger.nutrition:
        return 'Nutrition';
      case MoodTrigger.energyLevel:
        return 'Energy Level';
        
      // Life Events
      case MoodTrigger.celebration:
        return 'Celebration';
      case MoodTrigger.loss:
        return 'Loss';
      case MoodTrigger.transition:
        return 'Life Transition';
      case MoodTrigger.milestone:
        return 'Milestone';
      case MoodTrigger.disappointment:
        return 'Disappointment';
      case MoodTrigger.surprise:
        return 'Surprise';
      case MoodTrigger.travel:
        return 'Travel';
        
      // Mental & Emotional
      case MoodTrigger.stress:
        return 'Stress';
      case MoodTrigger.anxiety:
        return 'Anxiety';
      case MoodTrigger.nostalgia:
        return 'Nostalgia';
      case MoodTrigger.anticipation:
        return 'Anticipation';
      case MoodTrigger.boredom:
        return 'Boredom';
      case MoodTrigger.overwhelm:
        return 'Overwhelm';
      case MoodTrigger.clarity:
        return 'Clarity';
        
      // External Factors
      case MoodTrigger.weather:
        return 'Weather';
      case MoodTrigger.news:
        return 'News';
      case MoodTrigger.environment:
        return 'Environment';
      case MoodTrigger.music:
        return 'Music';
      case MoodTrigger.nature:
        return 'Nature';
      case MoodTrigger.technology:
        return 'Technology';
      case MoodTrigger.money:
        return 'Money';
        
      // Personal Growth
      case MoodTrigger.learning:
        return 'Learning';
      case MoodTrigger.creativity:
        return 'Creativity';
      case MoodTrigger.achievement:
        return 'Achievement';
      case MoodTrigger.failure:
        return 'Failure';
      case MoodTrigger.forgiveness:
        return 'Forgiveness';
      case MoodTrigger.gratitude:
        return 'Gratitude';
      case MoodTrigger.reflection:
        return 'Reflection';
        
      // Crisis & Support
      case MoodTrigger.crisis:
        return 'Crisis';
      case MoodTrigger.support:
        return 'Support';
      case MoodTrigger.counseling:
        return 'Counseling';
      case MoodTrigger.healing:
        return 'Healing';
      case MoodTrigger.breakthrough:
        return 'Breakthrough';
      case MoodTrigger.setback:
        return 'Setback';
      case MoodTrigger.recovery:
        return 'Recovery';
        
      // Other
      case MoodTrigger.unknown:
        return 'Unknown';
      case MoodTrigger.multiple:
        return 'Multiple Factors';
      case MoodTrigger.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      // Spiritual & Faith-related
      case MoodTrigger.prayer:
        return '🙏';
      case MoodTrigger.worship:
        return '🙌';
      case MoodTrigger.scripture:
        return '📖';
      case MoodTrigger.church:
        return '⛪';
      case MoodTrigger.fellowship:
        return '🤝';
      case MoodTrigger.ministry:
        return '✨';
      case MoodTrigger.spiritualDoubt:
        return '❓';
      case MoodTrigger.prayerAnswered:
        return '🌟';
        
      // Relationships
      case MoodTrigger.family:
        return '👨‍👩‍👧‍👦';
      case MoodTrigger.friends:
        return '👥';
      case MoodTrigger.romantic:
        return '💕';
      case MoodTrigger.conflict:
        return '⚡';
      case MoodTrigger.loneliness:
        return '😔';
      case MoodTrigger.community:
        return '🏘️';
      case MoodTrigger.socialEvent:
        return '🎉';
        
      // Work & Achievement
      case MoodTrigger.workStress:
        return '💼';
      case MoodTrigger.workSuccess:
        return '🎯';
      case MoodTrigger.jobSearch:
        return '🔍';
      case MoodTrigger.productivity:
        return '📈';
      case MoodTrigger.deadline:
        return '⏰';
      case MoodTrigger.teamwork:
        return '👥';
      case MoodTrigger.recognition:
        return '🏆';
        
      // Health & Physical
      case MoodTrigger.exercise:
        return '🏃';
      case MoodTrigger.sleep:
        return '😴';
      case MoodTrigger.sickness:
        return '🤒';
      case MoodTrigger.pain:
        return '🤕';
      case MoodTrigger.medication:
        return '💊';
      case MoodTrigger.nutrition:
        return '🍎';
      case MoodTrigger.energyLevel:
        return '⚡';
        
      // Life Events
      case MoodTrigger.celebration:
        return '🎉';
      case MoodTrigger.loss:
        return '💔';
      case MoodTrigger.transition:
        return '🔄';
      case MoodTrigger.milestone:
        return '🎖️';
      case MoodTrigger.disappointment:
        return '😞';
      case MoodTrigger.surprise:
        return '😲';
      case MoodTrigger.travel:
        return '✈️';
        
      // Mental & Emotional
      case MoodTrigger.stress:
        return '😰';
      case MoodTrigger.anxiety:
        return '😟';
      case MoodTrigger.nostalgia:
        return '🌅';
      case MoodTrigger.anticipation:
        return '🤞';
      case MoodTrigger.boredom:
        return '😑';
      case MoodTrigger.overwhelm:
        return '🤯';
      case MoodTrigger.clarity:
        return '💡';
        
      // External Factors
      case MoodTrigger.weather:
        return '🌤️';
      case MoodTrigger.news:
        return '📺';
      case MoodTrigger.environment:
        return '🏠';
      case MoodTrigger.music:
        return '🎵';
      case MoodTrigger.nature:
        return '🌿';
      case MoodTrigger.technology:
        return '💻';
      case MoodTrigger.money:
        return '💰';
        
      // Personal Growth
      case MoodTrigger.learning:
        return '📚';
      case MoodTrigger.creativity:
        return '🎨';
      case MoodTrigger.achievement:
        return '🌟';
      case MoodTrigger.failure:
        return '❌';
      case MoodTrigger.forgiveness:
        return '🕊️';
      case MoodTrigger.gratitude:
        return '🙏';
      case MoodTrigger.reflection:
        return '🤔';
        
      // Crisis & Support
      case MoodTrigger.crisis:
        return '🆘';
      case MoodTrigger.support:
        return '🤲';
      case MoodTrigger.counseling:
        return '💬';
      case MoodTrigger.healing:
        return '🌱';
      case MoodTrigger.breakthrough:
        return '🚀';
      case MoodTrigger.setback:
        return '📉';
      case MoodTrigger.recovery:
        return '🔄';
        
      // Other
      case MoodTrigger.unknown:
        return '❔';
      case MoodTrigger.multiple:
        return '🔀';
      case MoodTrigger.other:
        return '➕';
    }
  }

  MoodTriggerCategory get category {
    switch (this) {
      case MoodTrigger.prayer:
      case MoodTrigger.worship:
      case MoodTrigger.scripture:
      case MoodTrigger.church:
      case MoodTrigger.fellowship:
      case MoodTrigger.ministry:
      case MoodTrigger.spiritualDoubt:
      case MoodTrigger.prayerAnswered:
        return MoodTriggerCategory.spiritual;
        
      case MoodTrigger.family:
      case MoodTrigger.friends:
      case MoodTrigger.romantic:
      case MoodTrigger.conflict:
      case MoodTrigger.loneliness:
      case MoodTrigger.community:
      case MoodTrigger.socialEvent:
        return MoodTriggerCategory.relationships;
        
      case MoodTrigger.workStress:
      case MoodTrigger.workSuccess:
      case MoodTrigger.jobSearch:
      case MoodTrigger.productivity:
      case MoodTrigger.deadline:
      case MoodTrigger.teamwork:
      case MoodTrigger.recognition:
        return MoodTriggerCategory.work;
        
      case MoodTrigger.exercise:
      case MoodTrigger.sleep:
      case MoodTrigger.sickness:
      case MoodTrigger.pain:
      case MoodTrigger.medication:
      case MoodTrigger.nutrition:
      case MoodTrigger.energyLevel:
        return MoodTriggerCategory.health;
        
      case MoodTrigger.celebration:
      case MoodTrigger.loss:
      case MoodTrigger.transition:
      case MoodTrigger.milestone:
      case MoodTrigger.disappointment:
      case MoodTrigger.surprise:
      case MoodTrigger.travel:
        return MoodTriggerCategory.lifeEvents;
        
      case MoodTrigger.stress:
      case MoodTrigger.anxiety:
      case MoodTrigger.nostalgia:
      case MoodTrigger.anticipation:
      case MoodTrigger.boredom:
      case MoodTrigger.overwhelm:
      case MoodTrigger.clarity:
        return MoodTriggerCategory.mentalEmotional;
        
      case MoodTrigger.weather:
      case MoodTrigger.news:
      case MoodTrigger.environment:
      case MoodTrigger.music:
      case MoodTrigger.nature:
      case MoodTrigger.technology:
      case MoodTrigger.money:
        return MoodTriggerCategory.external;
        
      case MoodTrigger.learning:
      case MoodTrigger.creativity:
      case MoodTrigger.achievement:
      case MoodTrigger.failure:
      case MoodTrigger.forgiveness:
      case MoodTrigger.gratitude:
      case MoodTrigger.reflection:
        return MoodTriggerCategory.growth;
        
      case MoodTrigger.crisis:
      case MoodTrigger.support:
      case MoodTrigger.counseling:
      case MoodTrigger.healing:
      case MoodTrigger.breakthrough:
      case MoodTrigger.setback:
      case MoodTrigger.recovery:
        return MoodTriggerCategory.crisisSupport;
        
      case MoodTrigger.unknown:
      case MoodTrigger.multiple:
      case MoodTrigger.other:
        return MoodTriggerCategory.other;
    }
  }
}

/// Categories for grouping mood triggers
enum MoodTriggerCategory {
  spiritual,
  relationships,
  work,
  health,
  lifeEvents,
  mentalEmotional,
  external,
  growth,
  crisisSupport,
  other,
}

/// Extension for MoodTriggerCategory
extension MoodTriggerCategoryExtension on MoodTriggerCategory {
  String get displayName {
    switch (this) {
      case MoodTriggerCategory.spiritual:
        return 'Spiritual & Faith';
      case MoodTriggerCategory.relationships:
        return 'Relationships';
      case MoodTriggerCategory.work:
        return 'Work & Achievement';
      case MoodTriggerCategory.health:
        return 'Health & Physical';
      case MoodTriggerCategory.lifeEvents:
        return 'Life Events';
      case MoodTriggerCategory.mentalEmotional:
        return 'Mental & Emotional';
      case MoodTriggerCategory.external:
        return 'External Factors';
      case MoodTriggerCategory.growth:
        return 'Personal Growth';
      case MoodTriggerCategory.crisisSupport:
        return 'Crisis & Support';
      case MoodTriggerCategory.other:
        return 'Other';
    }
  }
}

/// Trend period for mood analytics
enum TrendPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Pattern types for mood analytics
enum PatternType {
  timeOfDay,
  dayOfWeek,
  activity,
  weather,
  seasonal,
}

/// Insight categories for mood analytics
enum InsightCategory {
  trend,
  pattern,
  warning,
  achievement,
  suggestion,
}

/// Insight severity levels
enum InsightSeverity {
  low,
  medium,
  high,
  critical,
}

/// Recommendation priorities
enum RecommendationPriority {
  low,
  medium,
  high,
  urgent,
}

/// Recommendation categories
enum RecommendationCategory {
  activity,
  lifestyle,
  spiritual,
  health,
  social,
}
