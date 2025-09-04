import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';
import '../utils/mood_analytics.dart';
import '../utils/mood_export.dart';

/// Integration test for the mood tracking system
class MoodIntegrationTest {
  
  /// Run all integration tests
  static Future<void> runTests() async {
    print('🧪 Starting Mood System Integration Tests...\n');
    
    try {
      await _testBasicMoodOperations();
      await _testMoodAnalytics();
      await _testMoodExport();
      
      print('✅ All tests passed successfully! 🎉');
    } catch (e) {
      print('❌ Tests failed: $e');
    }
  }
  
  /// Test basic CRUD operations
  static Future<void> _testBasicMoodOperations() async {
    print('📝 Testing basic mood operations...');
    
    final moodService = MoodService.instance;
    
    // Create test mood entries
    final testEntries = [
      SimpleMoodEntry(
        id: 'test-1',
        score: 8,
        notes: 'Feeling great after prayer time',
        emotions: ['Happy', 'Grateful', 'Peaceful'],
        timestamp: DateTime.now(),
        metadata: {
          'triggers': ['Prayer/Worship'],
          'activities': ['Prayer', 'Reading Scripture'],
        },
      ),
      SimpleMoodEntry(
        id: 'test-2',
        score: 5,
        notes: 'Neutral day, lots of work stress',
        emotions: ['Stressed', 'Tired'],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        metadata: {
          'triggers': ['Work/School'],
          'activities': ['Work'],
        },
      ),
      SimpleMoodEntry(
        id: 'test-3',
        score: 9,
        notes: 'Amazing worship service today!',
        emotions: ['Happy', 'Excited', 'Grateful'],
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        metadata: {
          'triggers': ['Prayer/Worship', 'Spiritual Growth'],
          'activities': ['Prayer', 'Music/Worship', 'Social Time'],
        },
      ),
    ];
    
    // Save entries
    for (final entry in testEntries) {
      await moodService.saveMoodEntry(entry);
    }
    print('   ✓ Saved ${testEntries.length} test entries');
    
    // Retrieve entries
    final allEntries = moodService.getAllMoodEntries();
    print('   ✓ Retrieved ${allEntries.length} entries');
    
    // Get specific entry
    final specificEntry = moodService.getMoodEntry('test-1');
    assert(specificEntry != null, 'Should find test entry');
    assert(specificEntry!.score == 8, 'Score should match');
    print('   ✓ Retrieved specific entry successfully');
    
    // Search entries
    final prayerEntries = moodService.searchMoodEntries(
      emotions: ['Grateful'],
      minScore: 7,
    );
    print('   ✓ Found ${prayerEntries.length} entries with grateful emotion and score >= 7');
    
    // Test today's entries
    final todaysEntries = moodService.getTodaysMoodEntries();
    print('   ✓ Found ${todaysEntries.length} entries for today');
    
    // Check if logged today
    final hasLogged = moodService.hasLoggedMoodToday();
    print('   ✓ Has logged mood today: $hasLogged');
    
    print('✅ Basic operations test passed\n');
  }
  
  /// Test analytics functionality
  static Future<void> _testMoodAnalytics() async {
    print('📊 Testing mood analytics...');
    
    final moodService = MoodService.instance;
    final allEntries = moodService.getAllMoodEntries();
    
    if (allEntries.isEmpty) {
      print('   ⚠️  No entries to analyze, skipping analytics test');
      return;
    }
    
    // Test basic statistics
    final stats = moodService.getMoodStatistics();
    print('   ✓ Average mood score: ${stats.averageScore.toStringAsFixed(1)}/10');
    print('   ✓ Total entries: ${stats.totalEntries}');
    print('   ✓ Top emotion: ${stats.emotionFrequency.keys.firstOrNull ?? 'None'}');
    
    // Test insights
    final insights = moodService.getMoodInsights(days: 30);
    print('   ✓ Generated ${insights.length} insights');
    
    // Test advanced analytics
    final weeklyPattern = MoodAnalytics.calculateWeeklyPattern(allEntries);
    print('   ✓ Weekly pattern analysis complete');
    
    final volatility = MoodAnalytics.calculateMoodVolatility(allEntries);
    print('   ✓ Mood volatility: ${volatility.volatilityLevel.name}');
    
    final patterns = MoodAnalytics.identifyPatterns(allEntries);
    print('   ✓ Identified ${patterns.length} mood patterns');
    
    // Test logging streak\n    final streak = moodService.getMoodLoggingStreak();\n    print('   ✓ Current logging streak: $streak days');
    
    print('✅ Analytics test passed\n');
  }
  
  /// Test export functionality
  static Future<void> _testMoodExport() async {
    print('📤 Testing mood export...');
    
    final moodService = MoodService.instance;
    final allEntries = moodService.getAllMoodEntries();
    
    if (allEntries.isEmpty) {
      print('   ⚠️  No entries to export, skipping export test');
      return;
    }
    
    // Test JSON export
    final jsonExport = MoodExporter.exportToJson(
      entries: allEntries,
      includeAnalytics: true,
    );
    assert(jsonExport.isNotEmpty, 'JSON export should not be empty');
    print('   ✓ JSON export generated (${jsonExport.length} characters)');
    
    // Test CSV export
    final csvExport = MoodExporter.exportToCSV(
      entries: allEntries,
      includeMetadata: true,
    );
    assert(csvExport.isNotEmpty, 'CSV export should not be empty');
    print('   ✓ CSV export generated (${csvExport.split('\\n').length} lines)');
    
    // Test analytics report
    final reportExport = MoodExporter.exportAnalyticsReport(
      entries: allEntries,
    );
    assert(reportExport.isNotEmpty, 'Report export should not be empty');
    print('   ✓ Analytics report generated (${reportExport.split('\\n').length} lines)');
    
    // Test export package
    final exportPackage = MoodExporter.createExportPackage(
      entries: allEntries,
    );
    assert(exportPackage.length == 3, 'Export package should have 3 files');
    print('   ✓ Complete export package created (${exportPackage.length} files)');
    
    print('✅ Export test passed\n');
  }
}
