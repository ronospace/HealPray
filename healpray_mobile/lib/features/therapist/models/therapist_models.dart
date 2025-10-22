import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'therapist_models.freezed.dart';
part 'therapist_models.g.dart';

/// Professional credentials and specializations for therapists
enum TherapistSpecialization {
  @JsonValue('clinical_psychology')
  clinicalPsychology,
  @JsonValue('counseling_psychology')
  counselingPsychology,
  @JsonValue('marriage_family_therapy')
  marriageFamilyTherapy,
  @JsonValue('addiction_counseling')
  addictionCounseling,
  @JsonValue('grief_counseling')
  griefCounseling,
  @JsonValue('trauma_therapy')
  traumaTherapy,
  @JsonValue('religious_counseling')
  religiousCounseling,
  @JsonValue('spiritual_direction')
  spiritualDirection,
  @JsonValue('crisis_intervention')
  crisisIntervention,
  @JsonValue('cognitive_behavioral_therapy')
  cognitiveBehavioralTherapy,
  @JsonValue('dialectical_behavior_therapy')
  dialecticalBehaviorTherapy,
  @JsonValue('pastoral_care')
  pastoralCare,
}

/// Client consent levels for data sharing
enum ConsentLevel {
  @JsonValue('none')
  none, // No data sharing
  @JsonValue('basic')
  basic, // Basic mood trends only
  @JsonValue('detailed')
  detailed, // Detailed mood data and patterns
  @JsonValue('full')
  full, // All data including prayers (anonymized)
}

/// Crisis alert severity levels
enum CrisisAlertLevel {
  @JsonValue('low')
  low,
  @JsonValue('moderate')
  moderate,
  @JsonValue('high')
  high,
  @JsonValue('severe')
  severe,
}

/// Therapist profile and credentials
@freezed
@HiveType(typeId: 50)
class TherapistProfile with _$TherapistProfile {
  const factory TherapistProfile({
    @HiveField(0) required String id,
    @HiveField(1) required String firstName,
    @HiveField(2) required String lastName,
    @HiveField(3) required String email,
    @HiveField(4) required String licenseNumber,
    @HiveField(5) required String licenseState,
    @HiveField(6) required List<TherapistSpecialization> specializations,
    @HiveField(7) required String organization,
    @HiveField(8) String? phoneNumber,
    @HiveField(9) String? bio,
    @HiveField(10) String? profileImageUrl,
    @HiveField(11) required bool isVerified,
    @HiveField(12) required bool acceptsNewClients,
    @HiveField(13) required DateTime createdAt,
    @HiveField(14) DateTime? lastLoginAt,
  }) = _TherapistProfile;

  factory TherapistProfile.fromJson(Map<String, dynamic> json) =>
      _$TherapistProfileFromJson(json);
}

/// Client connection between user and therapist
@freezed
@HiveType(typeId: 51)
class TherapistClientConnection with _$TherapistClientConnection {
  const factory TherapistClientConnection({
    @HiveField(0) required String id,
    @HiveField(1) required String therapistId,
    @HiveField(2) required String clientUserId,
    @HiveField(3) required ConsentLevel consentLevel,
    @HiveField(4) required bool isActive,
    @HiveField(5) required DateTime connectedAt,
    @HiveField(6) DateTime? lastDataAccessAt,
    @HiveField(7) String? notes,
    @HiveField(8) Map<String, dynamic>? therapistSettings,
  }) = _TherapistClientConnection;

  factory TherapistClientConnection.fromJson(Map<String, dynamic> json) =>
      _$TherapistClientConnectionFromJson(json);
}

/// Crisis alert sent to therapist
@freezed
@HiveType(typeId: 52)
class CrisisAlert with _$CrisisAlert {
  const factory CrisisAlert({
    @HiveField(0) required String id,
    @HiveField(1) required String clientUserId,
    @HiveField(2) required String therapistId,
    @HiveField(3) required CrisisAlertLevel severity,
    @HiveField(4) required String triggerReason,
    @HiveField(5) required Map<String, dynamic> contextData,
    @HiveField(6) required DateTime triggeredAt,
    @HiveField(7) DateTime? acknowledgedAt,
    @HiveField(8) DateTime? resolvedAt,
    @HiveField(9) String? therapistNotes,
    @HiveField(10) List<String>? actionsTriggered,
  }) = _CrisisAlert;

  factory CrisisAlert.fromJson(Map<String, dynamic> json) =>
      _$CrisisAlertFromJson(json);
}

/// Aggregated client wellness summary for therapist dashboard
@freezed
class ClientWellnessSummary with _$ClientWellnessSummary {
  const factory ClientWellnessSummary({
    required String clientUserId,
    required String clientInitials, // For privacy
    required double averageMoodScore,
    required int totalMoodEntries,
    required int daysTracked,
    required List<String> commonEmotions,
    required List<String> frequentTriggers,
    required DateTime lastMoodEntry,
    required int prayerGenerationCount,
    required int meditationSessionCount,
    required List<CrisisAlert> recentCrisisAlerts,
    Map<String, dynamic>? trendAnalysis,
    DateTime? lastSessionDate,
  }) = _ClientWellnessSummary;

  factory ClientWellnessSummary.fromJson(Map<String, dynamic> json) =>
      _$ClientWellnessSummaryFromJson(json);
}

/// Session notes that therapist can add about client
@freezed
@HiveType(typeId: 53)
class TherapistSessionNote with _$TherapistSessionNote {
  const factory TherapistSessionNote({
    @HiveField(0) required String id,
    @HiveField(1) required String therapistId,
    @HiveField(2) required String clientUserId,
    @HiveField(3) required DateTime sessionDate,
    @HiveField(4) required String notes,
    @HiveField(5) String? treatmentPlan,
    @HiveField(6) List<String>? goals,
    @HiveField(7) Map<String, dynamic>? assessments,
    @HiveField(8) required DateTime createdAt,
    @HiveField(9) DateTime? updatedAt,
  }) = _TherapistSessionNote;

  factory TherapistSessionNote.fromJson(Map<String, dynamic> json) =>
      _$TherapistSessionNoteFromJson(json);
}

/// Therapist dashboard configuration and preferences
@freezed
@HiveType(typeId: 54)
class TherapistDashboardSettings with _$TherapistDashboardSettings {
  const factory TherapistDashboardSettings({
    @HiveField(0) required String therapistId,
    @HiveField(1) @Default(true) bool enableCrisisAlerts,
    @HiveField(2) @Default(true) bool enableDailyDigest,
    @HiveField(3) @Default(true) bool enableWeeklyReports,
    @HiveField(4) @Default(['email']) List<String> alertChannels,
    @HiveField(5) @Default(CrisisAlertLevel.moderate) CrisisAlertLevel minimumAlertLevel,
    @HiveField(6) @Default(30) int dataRetentionDays,
    @HiveField(7) @Default(true) bool showMoodTrends,
    @HiveField(8) @Default(true) bool showPrayerFrequency,
    @HiveField(9) @Default(false) bool showPrayerContent, // Privacy sensitive
    @HiveField(10) @Default(true) bool showMeditationData,
    @HiveField(11) Map<String, dynamic>? customSettings,
  }) = _TherapistDashboardSettings;

  factory TherapistDashboardSettings.fromJson(Map<String, dynamic> json) =>
      _$TherapistDashboardSettingsFromJson(json);
}

/// Invitation sent to client to connect with therapist
@freezed
@HiveType(typeId: 55)
class ClientInvitation with _$ClientInvitation {
  const factory ClientInvitation({
    @HiveField(0) required String id,
    @HiveField(1) required String therapistId,
    @HiveField(2) required String invitationCode,
    @HiveField(3) String? clientEmail,
    @HiveField(4) required ConsentLevel proposedConsentLevel,
    @HiveField(5) required DateTime createdAt,
    @HiveField(6) required DateTime expiresAt,
    @HiveField(7) DateTime? acceptedAt,
    @HiveField(8) String? acceptedByUserId,
    @HiveField(9) @Default(false) bool isUsed,
    @HiveField(10) String? message,
  }) = _ClientInvitation;

  factory ClientInvitation.fromJson(Map<String, dynamic> json) =>
      _$ClientInvitationFromJson(json);
}

/// Extensions for better UX
extension TherapistSpecializationExt on TherapistSpecialization {
  String get displayName {
    switch (this) {
      case TherapistSpecialization.clinicalPsychology:
        return 'Clinical Psychology';
      case TherapistSpecialization.counselingPsychology:
        return 'Counseling Psychology';
      case TherapistSpecialization.marriageFamilyTherapy:
        return 'Marriage & Family Therapy';
      case TherapistSpecialization.addictionCounseling:
        return 'Addiction Counseling';
      case TherapistSpecialization.griefCounseling:
        return 'Grief Counseling';
      case TherapistSpecialization.traumaTherapy:
        return 'Trauma Therapy';
      case TherapistSpecialization.religiousCounseling:
        return 'Religious Counseling';
      case TherapistSpecialization.spiritualDirection:
        return 'Spiritual Direction';
      case TherapistSpecialization.crisisIntervention:
        return 'Crisis Intervention';
      case TherapistSpecialization.cognitiveBehavioralTherapy:
        return 'Cognitive Behavioral Therapy (CBT)';
      case TherapistSpecialization.dialecticalBehaviorTherapy:
        return 'Dialectical Behavior Therapy (DBT)';
      case TherapistSpecialization.pastoralCare:
        return 'Pastoral Care';
    }
  }

  String get description {
    switch (this) {
      case TherapistSpecialization.clinicalPsychology:
        return 'Diagnosis and treatment of mental health disorders';
      case TherapistSpecialization.counselingPsychology:
        return 'Helping individuals cope with life challenges';
      case TherapistSpecialization.marriageFamilyTherapy:
        return 'Relationship and family system therapy';
      case TherapistSpecialization.addictionCounseling:
        return 'Substance abuse and addiction recovery';
      case TherapistSpecialization.griefCounseling:
        return 'Support for loss and bereavement';
      case TherapistSpecialization.traumaTherapy:
        return 'Treatment for trauma and PTSD';
      case TherapistSpecialization.religiousCounseling:
        return 'Faith-based therapeutic approaches';
      case TherapistSpecialization.spiritualDirection:
        return 'Spiritual growth and discernment guidance';
      case TherapistSpecialization.crisisIntervention:
        return 'Emergency mental health support';
      case TherapistSpecialization.cognitiveBehavioralTherapy:
        return 'Thought and behavior pattern modification';
      case TherapistSpecialization.dialecticalBehaviorTherapy:
        return 'Emotional regulation and distress tolerance';
      case TherapistSpecialization.pastoralCare:
        return 'Spiritual care and religious support';
    }
  }
}

extension ConsentLevelExt on ConsentLevel {
  String get displayName {
    switch (this) {
      case ConsentLevel.none:
        return 'No Data Sharing';
      case ConsentLevel.basic:
        return 'Basic Mood Trends';
      case ConsentLevel.detailed:
        return 'Detailed Mood Data';
      case ConsentLevel.full:
        return 'Full Wellness Data';
    }
  }

  String get description {
    switch (this) {
      case ConsentLevel.none:
        return 'Therapist cannot access any HealPray data';
      case ConsentLevel.basic:
        return 'Basic mood score trends and averages only';
      case ConsentLevel.detailed:
        return 'Detailed mood data, triggers, and patterns';
      case ConsentLevel.full:
        return 'All wellness data (prayers anonymized)';
    }
  }

  List<String> get dataIncluded {
    switch (this) {
      case ConsentLevel.none:
        return [];
      case ConsentLevel.basic:
        return ['Mood score averages', 'Entry frequency'];
      case ConsentLevel.detailed:
        return [
          'Mood score averages',
          'Entry frequency',
          'Emotion categories',
          'Common triggers',
          'Activity patterns',
          'Crisis detection alerts'
        ];
      case ConsentLevel.full:
        return [
          'All mood data',
          'Emotion categories',
          'Triggers and activities',
          'Crisis detection alerts',
          'Prayer generation frequency',
          'Meditation session data',
          'Community participation (anonymized)',
          'Usage patterns and trends'
        ];
    }
  }
}

extension CrisisAlertLevelExt on CrisisAlertLevel {
  String get displayName {
    switch (this) {
      case CrisisAlertLevel.low:
        return 'Low Priority';
      case CrisisAlertLevel.moderate:
        return 'Moderate Priority';
      case CrisisAlertLevel.high:
        return 'High Priority';
      case CrisisAlertLevel.severe:
        return 'Severe - Immediate Attention';
    }
  }

  String get colorCode {
    switch (this) {
      case CrisisAlertLevel.low:
        return '#FFA726'; // Orange
      case CrisisAlertLevel.moderate:
        return '#FF7043'; // Deep Orange
      case CrisisAlertLevel.high:
        return '#E53935'; // Red
      case CrisisAlertLevel.severe:
        return '#B71C1C'; // Dark Red
    }
  }

  bool get requiresImmediateAction {
    return this == CrisisAlertLevel.severe;
  }
}
