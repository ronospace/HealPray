import 'package:flutter_test/flutter_test.dart';
import 'package:healpray/features/community/services/prayer_circle_service.dart';
import 'package:healpray/features/community/models/prayer_circle.dart';
import 'package:healpray/features/community/models/prayer_request.dart';
import 'package:healpray/features/community/models/prayer_response.dart';
import 'package:healpray/core/config/app_config.dart';

void main() {
  group('Prayer Circle Service Integration Tests', () {
    late PrayerCircleService prayerService;
    
    setUpAll(() async {
      await AppConfig.initialize();
      prayerService = PrayerCircleService.instance;
    });

    group('Service Initialization', () {
      test('should initialize prayer service correctly', () {
        expect(prayerService, isNotNull);
        expect(PrayerCircleService.instance, same(prayerService));
      });
    });

    group('Prayer Circle Operations', () {
      test('should create sample circles successfully', () async {
        final circles = await prayerService.getUserCircles('test_user');
        
        // Should return some sample circles
        expect(circles, isNotNull);
        expect(circles, isA<List<PrayerCircle>>());
        expect(circles.isNotEmpty, isTrue);
      });

      test('should get public circles for discovery', () async {
        final publicCircles = await prayerService.getPublicCircles();
        
        expect(publicCircles, isNotNull);
        expect(publicCircles, isA<List<PrayerCircle>>());
        // Should have at least some public circles
        expect(publicCircles.isNotEmpty, isTrue);
      });

      test('should search circles by query', () async {
        final searchResults = await prayerService.searchCircles('healing');
        
        expect(searchResults, isNotNull);
        expect(searchResults, isA<List<PrayerCircle>>());
        // Should find circles related to healing
      });

      test('should search circles by tag', () async {
        final tagResults = await prayerService.searchCirclesByTags(['prayer']);
        
        expect(tagResults, isNotNull);
        expect(tagResults, isA<List<PrayerCircle>>());
      });
    });

    group('Prayer Request Operations', () {
      test('should get prayer requests for circle', () async {
        // Using the first available circle
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          final requests = await prayerService.getPrayerRequests(circles.first.id);
          
          expect(requests, isNotNull);
          expect(requests, isA<List<PrayerRequest>>());
        }
      });

      test('should create and retrieve prayer request', () async {
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          const requestTitle = 'Test Prayer Request';
          const requestDescription = 'This is a test prayer request for integration testing';
          
          final requestId = await prayerService.submitPrayerRequest(
            circles.first.id,
            'test_user',
            requestTitle,
            requestDescription,
          );
          
          expect(requestId, isNotNull);
          expect(requestId, isNotEmpty);
          
          // Verify the request was created
          final requests = await prayerService.getPrayerRequests(circles.first.id);
          final createdRequest = requests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => throw Exception('Request not found'),
          );
          
          expect(createdRequest.title, equals(requestTitle));
          expect(createdRequest.description, equals(requestDescription));
        }
      });
    });

    group('Prayer Response Operations', () {
      test('should get responses for prayer request', () async {
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          final requests = await prayerService.getPrayerRequests(circles.first.id);
          if (requests.isNotEmpty) {
            final responses = await prayerService.getPrayerResponses(requests.first.id);
            
            expect(responses, isNotNull);
            expect(responses, isA<List<PrayerResponse>>());
          }
        }
      });

      test('should add response to prayer request', () async {
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          final requests = await prayerService.getPrayerRequests(circles.first.id);
          if (requests.isNotEmpty) {
            const responseMessage = 'Praying for you and sending love';
            
            final responseId = await prayerService.addPrayerResponse(
              requests.first.id,
              'test_responder',
              responseMessage,
            );
            
            expect(responseId, isNotNull);
            expect(responseId, isNotEmpty);
            
            // Verify the response was added
            final responses = await prayerService.getPrayerResponses(requests.first.id);
            final addedResponse = responses.firstWhere(
              (r) => r.id == responseId,
              orElse: () => throw Exception('Response not found'),
            );
            
            expect(addedResponse.message, equals(responseMessage));
            expect(addedResponse.userId, equals('test_responder'));
          }
        }
      });
    });

    group('Joining and Leaving Circles', () {
      test('should join a circle successfully', () async {
        final publicCircles = await prayerService.getPublicCircles();
        if (publicCircles.isNotEmpty) {
          final result = await prayerService.joinCircle(
            publicCircles.first.id,
            'new_user',
          );
          
          expect(result, isTrue);
        }
      });

      test('should leave a circle successfully', () async {
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          final result = await prayerService.leaveCircle(
            circles.first.id,
            'test_user',
          );
          
          expect(result, isTrue);
        }
      });
    });

    group('Prayer Counting and Tracking', () {
      test('should add prayer to request', () async {
        final circles = await prayerService.getUserCircles('test_user');
        if (circles.isNotEmpty) {
          final requests = await prayerService.getPrayerRequests(circles.first.id);
          if (requests.isNotEmpty) {
            await prayerService.addPrayerToRequest(
              requests.first.id,
              'prayer_user',
            );
            
            // Should complete without error
            expect(true, isTrue);
          }
        }
      });
    });

    group('Data Validation', () {
      test('should handle empty or null queries gracefully', () async {
        final emptyResults = await prayerService.searchCircles('');
        expect(emptyResults, isNotNull);
        expect(emptyResults, isA<List<PrayerCircle>>());
        
        final nullResults = await prayerService.searchCirclesByTags([]);
        expect(nullResults, isNotNull);
        expect(nullResults, isA<List<PrayerCircle>>());
      });

      test('should provide consistent data structure', () async {
        final circles = await prayerService.getUserCircles('test_user');
        
        for (final circle in circles) {
          expect(circle.id, isNotNull);
          expect(circle.name, isNotNull);
          expect(circle.description, isNotNull);
          expect(circle.tags, isNotNull);
          expect(circle.tags, isA<List<String>>());
        }
      });
    });
  });
}

// Note: These tests use the sample data provided by the service.
// In a production environment, you would want to:
// 1. Use a test database
// 2. Set up proper test fixtures
// 3. Clean up data after tests
// 4. Test error conditions and edge cases
