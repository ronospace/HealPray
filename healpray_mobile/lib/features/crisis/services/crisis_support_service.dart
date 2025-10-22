import 'package:url_launcher/url_launcher.dart';

import '../../mood/services/mood_service.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/services/analytics_service.dart';

/// Crisis support level
enum CrisisLevel {
  mild, // Feeling down but manageable
  moderate, // Significant distress
  severe, // Crisis situation needing immediate help
  emergency, // Life-threatening situation
}

/// Crisis support resource
class CrisisResource {
  final String id;
  final String name;
  final String description;
  final String? phoneNumber;
  final String? website;
  final String? textNumber;
  final List<String> countries;
  final bool is24Hour;
  final List<String> languages;
  final String category;

  const CrisisResource({
    required this.id,
    required this.name,
    required this.description,
    this.phoneNumber,
    this.website,
    this.textNumber,
    required this.countries,
    required this.is24Hour,
    required this.languages,
    required this.category,
  });
}

/// Crisis support service
class CrisisSupportService {
  static CrisisSupportService? _instance;
  static CrisisSupportService get instance =>
      _instance ??= CrisisSupportService._();

  CrisisSupportService._();

  final MoodService _moodService = MoodService.instance;
  final AnalyticsService _analytics = AnalyticsService.instance;

  /// Initialize the service
  Future<void> initialize() async {
    AppLogger.info('CrisisSupportService initialized');
  }

  /// Detect potential crisis based on mood patterns
  Future<CrisisLevel?> detectCrisisLevel() async {
    try {
      final recentEntries = _moodService.getRecentMoodEntries(limit: 7);

      if (recentEntries.isEmpty) return null;

      // Check for emergency keywords in recent entries
      final emergencyKeywords = [
        'suicide',
        'kill myself',
        'end it all',
        'not worth living',
        'self harm',
        'hurt myself',
        'can\'t go on'
      ];

      final crisisKeywords = [
        'hopeless',
        'desperate',
        'can\'t cope',
        'overwhelming',
        'trapped',
        'alone',
        'worthless'
      ];

      bool hasEmergencyWords = false;
      bool hasCrisisWords = false;
      int veryLowMoodCount = 0;
      int lowMoodCount = 0;

      for (final entry in recentEntries) {
        // Check mood scores
        if (entry.score <= 2) {
          veryLowMoodCount++;
        } else if (entry.score <= 4) {
          lowMoodCount++;
        }

        // Check notes for concerning language
        final notes = entry.notes?.toLowerCase() ?? '';
        for (final keyword in emergencyKeywords) {
          if (notes.contains(keyword)) {
            hasEmergencyWords = true;
            break;
          }
        }

        for (final keyword in crisisKeywords) {
          if (notes.contains(keyword)) {
            hasCrisisWords = true;
            break;
          }
        }
      }

      // Determine crisis level
      if (hasEmergencyWords || veryLowMoodCount >= 3) {
        return CrisisLevel.emergency;
      } else if (hasCrisisWords || veryLowMoodCount >= 2) {
        return CrisisLevel.severe;
      } else if (lowMoodCount >= 4) {
        return CrisisLevel.moderate;
      } else if (lowMoodCount >= 2) {
        return CrisisLevel.mild;
      }

      return null;
    } catch (e) {
      AppLogger.error('Failed to detect crisis level', e);
      return null;
    }
  }

  /// Get crisis resources based on level and location
  List<CrisisResource> getCrisisResources({
    CrisisLevel? level,
    String country = 'US',
  }) {
    final allResources = _getAllCrisisResources();

    return allResources.where((resource) {
      // Filter by country
      if (!resource.countries.contains(country)) return false;

      // Filter by crisis level severity
      if (level == CrisisLevel.emergency || level == CrisisLevel.severe) {
        return resource.category == 'emergency' ||
            resource.category == 'crisis';
      } else if (level == CrisisLevel.moderate) {
        return resource.category != 'general';
      }

      return true;
    }).toList();
  }

  /// Get emergency resources (highest priority)
  List<CrisisResource> getEmergencyResources({String country = 'US'}) {
    return getCrisisResources(level: CrisisLevel.emergency, country: country);
  }

  /// Call emergency number
  Future<void> callEmergencyNumber(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);

        // Track analytics (anonymized)
        await _analytics.logEvent('crisis_call_initiated', {
          'resource_type': 'emergency',
          'country': 'anonymized',
        });

        AppLogger.info('Emergency call initiated');
      } else {
        throw Exception('Unable to make phone call');
      }
    } catch (e) {
      AppLogger.error('Failed to call emergency number', e);
      rethrow;
    }
  }

  /// Open crisis chat website
  Future<void> openCrisisChat(String website) async {
    try {
      final Uri webUri = Uri.parse(website);

      if (await canLaunchUrl(webUri)) {
        await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );

        await _analytics.logEvent('crisis_chat_opened', {
          'resource_type': 'chat',
        });

        AppLogger.info('Crisis chat website opened');
      } else {
        throw Exception('Unable to open website');
      }
    } catch (e) {
      AppLogger.error('Failed to open crisis chat', e);
      rethrow;
    }
  }

  /// Send crisis text message
  Future<void> sendCrisisText(String textNumber) async {
    try {
      final Uri smsUri = Uri(scheme: 'sms', path: textNumber);

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);

        await _analytics.logEvent('crisis_text_initiated', {
          'resource_type': 'text',
        });

        AppLogger.info('Crisis text message initiated');
      } else {
        throw Exception('Unable to send text message');
      }
    } catch (e) {
      AppLogger.error('Failed to send crisis text', e);
      rethrow;
    }
  }

  /// Get crisis intervention message based on level
  String getCrisisMessage(CrisisLevel level) {
    switch (level) {
      case CrisisLevel.emergency:
        return '''🚨 IMMEDIATE HELP NEEDED 🚨

If you are having thoughts of suicide or self-harm, please reach out for help immediately. You are not alone, and there are people who care about you.

• Call 988 (Suicide & Crisis Lifeline) - Available 24/7
• Text "HELLO" to 741741 (Crisis Text Line)
• Call 911 for immediate emergency help

Your life has value and meaning. Please stay safe.''';

      case CrisisLevel.severe:
        return '''⚠️ CRISIS SUPPORT AVAILABLE ⚠️

It looks like you're going through an extremely difficult time. Please consider reaching out for professional support right now.

• National Suicide Prevention Lifeline: 988
• Crisis Text Line: Text HOME to 741741
• SAMHSA National Helpline: 1-800-662-4357

You don't have to face this alone. Help is available 24/7.''';

      case CrisisLevel.moderate:
        return '''💙 SUPPORT IS AVAILABLE 💙

Your recent mood patterns show you're experiencing significant distress. It's important to reach out for support during difficult times.

• Crisis Text Line: 741741
• National Alliance on Mental Illness: 1-800-950-6264
• Psychology Today Therapist Finder

Consider talking to a counselor, trusted friend, or spiritual advisor.''';

      case CrisisLevel.mild:
        return '''🌟 YOU'RE NOT ALONE 🌟

It seems like you've been struggling lately. Remember that it's normal to have difficult days, and seeking support is a sign of strength.

• Consider talking to a friend, family member, or counselor
• Practice self-care activities that bring you comfort
• Remember that difficult feelings are temporary

Your mental health matters. Consider professional support if feelings persist.''';
    }
  }

  /// Get spiritual comfort message
  String getSpiritualComfortMessage(CrisisLevel level) {
    switch (level) {
      case CrisisLevel.emergency:
      case CrisisLevel.severe:
        return '''🙏 GOD'S LOVE FOR YOU 🙏

"The Lord is close to the brokenhearted and saves those who are crushed in spirit." - Psalm 34:18

Even in your darkest moment, God loves you deeply and has a plan for your life. Please reach out for help - both professional and spiritual. Your church community and pastoral care can provide additional support alongside crisis services.

You are loved, you are valuable, and you are not alone.''';

      case CrisisLevel.moderate:
        return '''💝 HELD IN GOD'S CARE 💝

"Cast all your anxiety on him because he cares for you." - 1 Peter 5:7

God sees your struggle and wants to carry your burdens with you. Consider reaching out to your spiritual community - pastors, spiritual directors, or trusted believers who can pray with you and provide support.

This difficult season will pass. You are held in God's loving care.''';

      case CrisisLevel.mild:
        return '''🌈 GOD'S PEACE & HOPE 🌈

"And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus." - Philippians 4:7

God wants to give you His peace in the midst of difficult emotions. Consider spending time in prayer, reading Scripture, or connecting with your faith community.

Remember: This too shall pass, and God is with you every step of the way.''';
    }
  }

  /// Check if crisis intervention should be shown
  Future<bool> shouldShowCrisisIntervention() async {
    final crisisLevel = await detectCrisisLevel();
    return crisisLevel != null &&
        (crisisLevel == CrisisLevel.severe ||
            crisisLevel == CrisisLevel.emergency);
  }

  /// Get all available crisis resources
  List<CrisisResource> _getAllCrisisResources() {
    return [
      // Emergency Resources (US)
      CrisisResource(
        id: 'us_suicide_lifeline',
        name: 'Suicide & Crisis Lifeline',
        description:
            '24/7, free and confidential support for people in distress',
        phoneNumber: '988',
        website: 'https://suicidepreventionlifeline.org',
        countries: ['US'],
        is24Hour: true,
        languages: ['English', 'Spanish'],
        category: 'emergency',
      ),

      CrisisResource(
        id: 'us_crisis_text',
        name: 'Crisis Text Line',
        description: 'Text-based crisis support available 24/7',
        textNumber: '741741',
        website: 'https://crisistextline.org',
        countries: ['US', 'CA', 'UK'],
        is24Hour: true,
        languages: ['English'],
        category: 'emergency',
      ),

      CrisisResource(
        id: 'us_samhsa',
        name: 'SAMHSA National Helpline',
        description:
            'Treatment referral and information service for mental health and substance abuse',
        phoneNumber: '1-800-662-4357',
        website: 'https://samhsa.gov',
        countries: ['US'],
        is24Hour: true,
        languages: ['English', 'Spanish'],
        category: 'crisis',
      ),

      // International Resources
      CrisisResource(
        id: 'uk_samaritans',
        name: 'Samaritans',
        description: 'Free confidential emotional support 24/7',
        phoneNumber: '116 123',
        website: 'https://samaritans.org',
        countries: ['UK', 'IE'],
        is24Hour: true,
        languages: ['English'],
        category: 'emergency',
      ),

      CrisisResource(
        id: 'ca_talk_suicide',
        name: 'Talk Suicide Canada',
        description: 'Canada-wide suicide prevention service',
        phoneNumber: '1-833-456-4566',
        website: 'https://talksuicide.ca',
        countries: ['CA'],
        is24Hour: true,
        languages: ['English', 'French'],
        category: 'emergency',
      ),

      // Support Resources
      CrisisResource(
        id: 'us_nami',
        name: 'National Alliance on Mental Illness',
        description: 'Mental health support and information',
        phoneNumber: '1-800-950-6264',
        website: 'https://nami.org',
        countries: ['US'],
        is24Hour: false,
        languages: ['English'],
        category: 'support',
      ),

      CrisisResource(
        id: 'us_warmline_directory',
        name: 'National Warm Line Directory',
        description: 'Non-crisis emotional support phone lines',
        website: 'https://warmline.org',
        countries: ['US'],
        is24Hour: false,
        languages: ['English'],
        category: 'support',
      ),

      // Faith-Based Resources
      CrisisResource(
        id: 'us_stephen_ministries',
        name: 'Stephen Ministries',
        description: 'Christian peer support and care',
        website: 'https://stephenministries.org',
        countries: ['US', 'CA'],
        is24Hour: false,
        languages: ['English'],
        category: 'spiritual',
      ),

      CrisisResource(
        id: 'us_fresh_hope',
        name: 'Fresh Hope for Mental Health',
        description: 'Faith-based mental health support groups',
        website: 'https://freshhope.us',
        countries: ['US'],
        is24Hour: false,
        languages: ['English'],
        category: 'spiritual',
      ),
    ];
  }
}
