import 'package:flutter_test/flutter_test.dart';
import 'package:healpray/features/crisis/services/crisis_detection_service.dart';
import 'package:healpray/features/crisis/models/crisis_level.dart';
import 'package:healpray/core/config/app_config.dart';

void main() {
  group('Crisis Detection System Tests', () {
    late CrisisDetectionService crisisService;
    
    setUpAll(() async {
      await AppConfig.initialize();
      crisisService = CrisisDetectionService.instance;
    });

    group('Crisis Level Determination', () {
      test('should identify severe crisis from high risk score', () {
        final service = CrisisDetectionService.instance;
        final level = service._determineCrisisLevel(0.9);
        expect(level, equals(CrisisLevel.severe));
      });

      test('should identify high crisis from moderate-high risk score', () {
        final service = CrisisDetectionService.instance;
        final level = service._determineCrisisLevel(0.7);
        expect(level, equals(CrisisLevel.high));
      });

      test('should identify moderate crisis from medium risk score', () {
        final service = CrisisDetectionService.instance;
        final level = service._determineCrisisLevel(0.5);
        expect(level, equals(CrisisLevel.moderate));
      });

      test('should identify low crisis from low risk score', () {
        final service = CrisisDetectionService.instance;
        final level = service._determineCrisisLevel(0.3);
        expect(level, equals(CrisisLevel.low));
      });

      test('should identify no crisis from very low risk score', () {
        final service = CrisisDetectionService.instance;
        final level = service._determineCrisisLevel(0.1);
        expect(level, equals(CrisisLevel.none));
      });
    });

    group('Crisis Keywords Detection', () {
      test('should identify high severity keywords', () {
        final service = CrisisDetectionService.instance;
        expect(service._isHighSeverityKeyword('kill myself'), isTrue);
        expect(service._isHighSeverityKeyword('suicide'), isTrue);
        expect(service._isHighSeverityKeyword('hurt myself'), isTrue);
        expect(service._isHighSeverityKeyword('happy'), isFalse);
      });

      test('should identify moderate severity keywords', () {
        final service = CrisisDetectionService.instance;
        expect(service._isModerateSeverityKeyword('hopeless'), isTrue);
        expect(service._isModerateSeverityKeyword('overwhelmed'), isTrue);
        expect(service._isModerateSeverityKeyword('panic attack'), isTrue);
        expect(service._isModerateSeverityKeyword('excited'), isFalse);
      });
    });

    group('Recommended Actions', () {
      test('should provide severe crisis actions for severe level', () {
        final service = CrisisDetectionService.instance;
        final actions = service._getRecommendedActions(CrisisLevel.severe);
        
        expect(actions.isNotEmpty, isTrue);
        expect(actions.any((action) => action.contains('911')), isTrue);
        expect(actions.any((action) => action.contains('emergency')), isTrue);
      });

      test('should provide appropriate actions for high crisis level', () {
        final service = CrisisDetectionService.instance;
        final actions = service._getRecommendedActions(CrisisLevel.high);
        
        expect(actions.isNotEmpty, isTrue);
        expect(actions.any((action) => action.contains('therapist') || action.contains('counselor')), isTrue);
        expect(actions.any((action) => action.contains('helpline')), isTrue);
      });

      test('should provide moderate actions for moderate level', () {
        final service = CrisisDetectionService.instance;
        final actions = service._getRecommendedActions(CrisisLevel.moderate);
        
        expect(actions.isNotEmpty, isTrue);
        expect(actions.any((action) => action.contains('mental health professional')), isTrue);
        expect(actions.any((action) => action.contains('self-care')), isTrue);
      });

      test('should provide low-level actions for low crisis level', () {
        final service = CrisisDetectionService.instance;
        final actions = service._getRecommendedActions(CrisisLevel.low);
        
        expect(actions.isNotEmpty, isTrue);
        expect(actions.any((action) => action.contains('mindfulness') || action.contains('meditation')), isTrue);
      });

      test('should provide no actions for no crisis', () {
        final service = CrisisDetectionService.instance;
        final actions = service._getRecommendedActions(CrisisLevel.none);
        
        expect(actions.isEmpty, isTrue);
      });
    });

    group('Emergency Contacts', () {
      test('should provide standard emergency contacts', () {
        final service = CrisisDetectionService.instance;
        final contacts = service._getEmergencyContacts();
        
        expect(contacts.isNotEmpty, isTrue);
        expect(contacts.any((contact) => contact.contains('911')), isTrue);
        expect(contacts.any((contact) => contact.contains('988')), isTrue); // Suicide prevention lifeline
        expect(contacts.any((contact) => contact.contains('741741')), isTrue); // Crisis text line
      });
    });

    group('Support Resources', () {
      test('should provide appropriate resources for severe crisis', () {
        final service = CrisisDetectionService.instance;
        final resources = service._getSupportResources(CrisisLevel.severe);
        
        expect(resources.isNotEmpty, isTrue);
        // Resources should include immediate professional help
      });

      test('should provide appropriate resources for moderate crisis', () {
        final service = CrisisDetectionService.instance;
        final resources = service._getSupportResources(CrisisLevel.moderate);
        
        expect(resources.isNotEmpty, isTrue);
        // Resources should include professional and self-help options
      });
    });

    group('Trigger Factor Identification', () {
      test('should identify trigger factors from risk scores', () {
        final service = CrisisDetectionService.instance;
        final factors = service._identifyTriggerFactors(0.6, 0.5, 0.4, 0.3, 0.7);
        
        expect(factors.contains('Persistent low mood'), isTrue);
        expect(factors.contains('High-risk emotions detected'), isTrue);
        expect(factors.contains('Crisis language detected'), isTrue);
      });

      test('should not identify factors from low risk scores', () {
        final service = CrisisDetectionService.instance;
        final factors = service._identifyTriggerFactors(0.1, 0.1, 0.1, 0.1, 0.1);
        
        expect(factors.isEmpty, isTrue);
      });
    });
  });
}

// Note: Due to the complexity of testing with actual MoodEntry objects and the
// SimpleMoodEntry vs MoodEntry type mismatch issues, these tests focus on the
// core algorithmic functionality that can be tested in isolation.
// In a production environment, these issues would need to be resolved first.
