import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mood_entry.dart';
import '../models/emotion_type.dart';
import '../models/mood_enums.dart';
import '../models/mood_analytics.dart';
import '../services/mood_tracking_service.dart';

/// Provider for mood entries stream (real-time updates)
final moodEntriesStreamProvider =
    StreamProvider.autoDispose<List<MoodEntry>>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getMoodEntriesStream(limit: 100);
});

/// Provider for recent mood entries (last 30 days)
final recentMoodEntriesProvider =
    FutureProvider.autoDispose<List<MoodEntry>>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
  return service.getMoodEntries(startDate: thirtyDaysAgo);
});

/// Provider for today's mood entry
final todaysMoodEntryProvider = FutureProvider.autoDispose<MoodEntry?>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getTodaysMoodEntry();
});

/// Provider to check if user has entry for today
final hasEntryTodayProvider = FutureProvider.autoDispose<bool>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.hasEntryToday();
});

/// Provider for current mood tracking streak
final currentStreakProvider = FutureProvider.autoDispose<int>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getCurrentStreak();
});

/// Provider for longest mood tracking streak
final longestStreakProvider = FutureProvider.autoDispose<int>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getLongestStreak();
});

/// Provider for mood analytics (last 30 days)
final moodAnalyticsProvider = FutureProvider.autoDispose<MoodAnalytics>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getMoodAnalytics();
});

/// Provider for mood analytics with custom date range
final customMoodAnalyticsProvider = FutureProvider.autoDispose
    .family<MoodAnalytics, DateRange>((ref, dateRange) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getMoodAnalytics(
    startDate: dateRange.start,
    endDate: dateRange.end,
  );
});

/// Provider for distress entries stream (for crisis support)
final distressEntriesStreamProvider =
    StreamProvider.autoDispose<List<MoodEntry>>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getDistressEntriesStream();
});

/// Provider for suggested spiritual practices
final suggestedPracticesProvider =
    FutureProvider.autoDispose<List<String>>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return service.getSuggestedPractices();
});

/// State notifier for mood entry form
class MoodEntryFormNotifier extends StateNotifier<MoodEntryFormState> {
  MoodEntryFormNotifier(this._service) : super(const MoodEntryFormState());

  final MoodTrackingService _service;

  /// Update selected emotions
  void updateEmotions(List<EmotionType> emotions) {
    state = state.copyWith(emotions: emotions);
  }

  /// Update mood intensity
  void updateIntensity(MoodIntensity intensity) {
    state = state.copyWith(intensity: intensity);
  }

  /// Update selected triggers
  void updateTriggers(List<MoodTrigger> triggers) {
    state = state.copyWith(triggers: triggers);
  }

  /// Update notes
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Update location
  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  /// Update tags
  void updateTags(List<String> tags) {
    state = state.copyWith(tags: tags);
  }

  /// Update context
  void updateContext(MoodContext context) {
    state = state.copyWith(context: context);
  }

  /// Update gratitude list
  void updateGratitudeList(List<String> gratitudeList) {
    state = state.copyWith(gratitudeList: gratitudeList);
  }

  /// Update prayer requests
  void updatePrayerRequests(List<String> prayerRequests) {
    state = state.copyWith(prayerRequests: prayerRequests);
  }

  /// Update verse
  void updateVerse(String verse) {
    state = state.copyWith(verse: verse);
  }

  /// Update privacy setting
  void updateIsPrivate(bool isPrivate) {
    state = state.copyWith(isPrivate: isPrivate);
  }

  /// Submit mood entry
  Future<void> submitMoodEntry() async {
    if (state.emotions.isEmpty) {
      state = state.copyWith(
        status: MoodEntryFormStatus.error,
        errorMessage: 'Please select at least one emotion',
      );
      return;
    }

    state = state.copyWith(status: MoodEntryFormStatus.loading);

    try {
      await _service.createMoodEntry(
        emotions: state.emotions,
        intensity: state.intensity,
        triggers: state.triggers,
        notes: state.notes?.isNotEmpty == true ? state.notes : null,
        location: state.location?.isNotEmpty == true ? state.location : null,
        tags: state.tags.isNotEmpty ? state.tags : null,
        context: state.context,
        gratitudeList:
            state.gratitudeList.isNotEmpty ? state.gratitudeList : null,
        prayerRequests:
            state.prayerRequests.isNotEmpty ? state.prayerRequests : null,
        verse: state.verse?.isNotEmpty == true ? state.verse : null,
        isPrivate: state.isPrivate,
      );

      state = state.copyWith(status: MoodEntryFormStatus.success);

      // Reset form after successful submission
      reset();
    } catch (error) {
      state = state.copyWith(
        status: MoodEntryFormStatus.error,
        errorMessage: 'Failed to save mood entry: ${error.toString()}',
      );
    }
  }

  /// Update existing mood entry
  Future<void> updateMoodEntry(MoodEntry existingEntry) async {
    if (state.emotions.isEmpty) {
      state = state.copyWith(
        status: MoodEntryFormStatus.error,
        errorMessage: 'Please select at least one emotion',
      );
      return;
    }

    state = state.copyWith(status: MoodEntryFormStatus.loading);

    try {
      final updatedEntry = existingEntry.copyWith(
        emotions: state.emotions,
        intensity: state.intensity,
        triggers: state.triggers,
        notes: state.notes?.isNotEmpty == true ? state.notes : null,
        location: state.location?.isNotEmpty == true ? state.location : null,
        tags: state.tags.isNotEmpty ? state.tags : null,
        context: state.context,
        gratitudeList:
            state.gratitudeList.isNotEmpty ? state.gratitudeList : null,
        prayerRequests:
            state.prayerRequests.isNotEmpty ? state.prayerRequests : null,
        verse: state.verse?.isNotEmpty == true ? state.verse : null,
        isPrivate: state.isPrivate,
      );

      await _service.updateMoodEntry(updatedEntry);

      state = state.copyWith(status: MoodEntryFormStatus.success);
    } catch (error) {
      state = state.copyWith(
        status: MoodEntryFormStatus.error,
        errorMessage: 'Failed to update mood entry: ${error.toString()}',
      );
    }
  }

  /// Load existing mood entry into form
  void loadMoodEntry(MoodEntry entry) {
    state = state.copyWith(
      emotions: entry.emotions,
      intensity: entry.intensity,
      triggers: entry.triggers,
      notes: entry.notes,
      location: entry.location,
      tags: entry.tags ?? [],
      context: entry.context,
      gratitudeList: entry.gratitudeList ?? [],
      prayerRequests: entry.prayerRequests ?? [],
      verse: entry.verse,
      isPrivate: entry.isPrivate ?? false,
      status: MoodEntryFormStatus.initial,
      errorMessage: null,
    );
  }

  /// Reset form to initial state
  void reset() {
    state = const MoodEntryFormState();
  }
}

/// State for mood entry form
class MoodEntryFormState {
  const MoodEntryFormState({
    this.emotions = const [],
    this.intensity = MoodIntensity.moderate,
    this.triggers = const [],
    this.notes,
    this.location,
    this.tags = const [],
    this.context,
    this.gratitudeList = const [],
    this.prayerRequests = const [],
    this.verse,
    this.isPrivate = false,
    this.status = MoodEntryFormStatus.initial,
    this.errorMessage,
  });

  final List<EmotionType> emotions;
  final MoodIntensity intensity;
  final List<MoodTrigger> triggers;
  final String? notes;
  final String? location;
  final List<String> tags;
  final MoodContext? context;
  final List<String> gratitudeList;
  final List<String> prayerRequests;
  final String? verse;
  final bool isPrivate;
  final MoodEntryFormStatus status;
  final String? errorMessage;

  /// Check if form is valid for submission
  bool get isValid => emotions.isNotEmpty;

  /// Check if form is loading
  bool get isLoading => status == MoodEntryFormStatus.loading;

  /// Check if form has error
  bool get hasError => status == MoodEntryFormStatus.error;

  /// Check if form submission was successful
  bool get isSuccess => status == MoodEntryFormStatus.success;

  MoodEntryFormState copyWith({
    List<EmotionType>? emotions,
    MoodIntensity? intensity,
    List<MoodTrigger>? triggers,
    String? notes,
    String? location,
    List<String>? tags,
    MoodContext? context,
    List<String>? gratitudeList,
    List<String>? prayerRequests,
    String? verse,
    bool? isPrivate,
    MoodEntryFormStatus? status,
    String? errorMessage,
  }) {
    return MoodEntryFormState(
      emotions: emotions ?? this.emotions,
      intensity: intensity ?? this.intensity,
      triggers: triggers ?? this.triggers,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      context: context ?? this.context,
      gratitudeList: gratitudeList ?? this.gratitudeList,
      prayerRequests: prayerRequests ?? this.prayerRequests,
      verse: verse ?? this.verse,
      isPrivate: isPrivate ?? this.isPrivate,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Status enum for mood entry form
enum MoodEntryFormStatus {
  initial,
  loading,
  success,
  error,
}

/// Provider for mood entry form notifier
final moodEntryFormProvider = StateNotifierProvider.autoDispose<
    MoodEntryFormNotifier, MoodEntryFormState>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return MoodEntryFormNotifier(service);
});

/// Provider for quick mood selection (simplified form)
final quickMoodProvider = StateProvider.autoDispose<QuickMoodState>((ref) {
  return const QuickMoodState();
});

/// State for quick mood entry
class QuickMoodState {
  const QuickMoodState({
    this.selectedEmotion,
    this.intensity = MoodIntensity.moderate,
  });

  final EmotionType? selectedEmotion;
  final MoodIntensity intensity;

  QuickMoodState copyWith({
    EmotionType? selectedEmotion,
    MoodIntensity? intensity,
  }) {
    return QuickMoodState(
      selectedEmotion: selectedEmotion ?? this.selectedEmotion,
      intensity: intensity ?? this.intensity,
    );
  }
}

/// Provider for mood analytics filters
final moodAnalyticsFiltersProvider =
    StateProvider.autoDispose<MoodAnalyticsFilters>((ref) {
  return MoodAnalyticsFilters(
    dateRange: DateRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    ),
  );
});

/// Filters for mood analytics
class MoodAnalyticsFilters {
  const MoodAnalyticsFilters({
    required this.dateRange,
    this.emotionCategory,
    this.triggerCategory,
  });

  final DateRange dateRange;
  final EmotionCategory? emotionCategory;
  final MoodTriggerCategory? triggerCategory;

  MoodAnalyticsFilters copyWith({
    DateRange? dateRange,
    EmotionCategory? emotionCategory,
    MoodTriggerCategory? triggerCategory,
  }) {
    return MoodAnalyticsFilters(
      dateRange: dateRange ?? this.dateRange,
      emotionCategory: emotionCategory ?? this.emotionCategory,
      triggerCategory: triggerCategory ?? this.triggerCategory,
    );
  }
}

/// Notifier for managing mood entry operations
class MoodEntryOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  MoodEntryOperationsNotifier(this._service)
      : super(const AsyncValue.data(null));

  final MoodTrackingService _service;

  /// Delete mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    state = const AsyncValue.loading();

    try {
      await _service.deleteMoodEntry(entryId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Provider for mood entry operations
final moodEntryOperationsProvider = StateNotifierProvider.autoDispose<
    MoodEntryOperationsNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(moodTrackingServiceProvider);
  return MoodEntryOperationsNotifier(service);
});
