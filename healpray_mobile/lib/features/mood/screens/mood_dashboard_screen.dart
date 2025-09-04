import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';
import '../utils/mood_analytics.dart';
import '../widgets/mood_chart_widget.dart';
import '../widgets/mood_insights_widget.dart';
import '../widgets/mood_stats_card.dart';

/// Comprehensive mood analytics dashboard
class MoodDashboardScreen extends ConsumerStatefulWidget {
  const MoodDashboardScreen({super.key});

  @override
  ConsumerState<MoodDashboardScreen> createState() => _MoodDashboardScreenState();
}

class _MoodDashboardScreenState extends ConsumerState<MoodDashboardScreen> {
  final MoodService _moodService = MoodService.instance;
  
  String _selectedPeriod = 'Last 30 Days';
  final List<String> _periods = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 90 Days',
    'This Year',
    'All Time'
  ];
  
  List<SimpleMoodEntry> _filteredEntries = [];
  MoodStatistics? _statistics;
  List<MoodInsight> _insights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      await _moodService.initialize();
      final allEntries = _moodService.getAllMoodEntries();
      
      _filteredEntries = _filterEntriesByPeriod(allEntries, _selectedPeriod);
      _statistics = _moodService.getMoodStatistics(
        startDate: _getStartDateForPeriod(_selectedPeriod),
        endDate: DateTime.now(),
      );
      _insights = _moodService.getMoodInsights(days: _getDaysForPeriod(_selectedPeriod));
      
    } catch (e) {
      debugPrint('Error loading mood data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<SimpleMoodEntry> _filterEntriesByPeriod(List<SimpleMoodEntry> entries, String period) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case 'Last 7 Days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Last 30 Days':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 Days':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'This Year':
        startDate = DateTime(now.year, 1, 1);
        break;
      case 'All Time':
        return entries;
      default:
        startDate = now.subtract(const Duration(days: 30));
    }
    
    return entries.where((entry) => entry.timestamp.isAfter(startDate)).toList();
  }

  DateTime? _getStartDateForPeriod(String period) {
    final now = DateTime.now();
    
    switch (period) {
      case 'Last 7 Days':
        return now.subtract(const Duration(days: 7));
      case 'Last 30 Days':
        return now.subtract(const Duration(days: 30));
      case 'Last 90 Days':
        return now.subtract(const Duration(days: 90));
      case 'This Year':
        return DateTime(now.year, 1, 1);
      case 'All Time':
        return null;
      default:
        return now.subtract(const Duration(days: 30));
    }
  }

  int _getDaysForPeriod(String period) {
    switch (period) {
      case 'Last 7 Days':
        return 7;
      case 'Last 30 Days':
        return 30;
      case 'Last 90 Days':
        return 90;
      case 'This Year':
        return DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
      case 'All Time':
        return 365; // Max for insights
      default:
        return 30;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Mood Analytics',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showExportOptions,
            icon: const Icon(
              Icons.download_outlined,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.healingTeal),
            ),
          )
        : _filteredEntries.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppTheme.healingTeal,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 24),
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      _buildMoodChart(),
                      const SizedBox(height: 24),
                      _buildInsights(),
                      const SizedBox(height: 24),
                      _buildEmotionAnalysis(),
                      const SizedBox(height: 24),
                      _buildPatterns(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppTheme.morningGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Mood Data Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your mood to see\ninsightful analytics and patterns',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/mood/entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.healingTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Log Your First Mood',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
                _loadData();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.healingTeal : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    if (_statistics == null) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: MoodStatsCard(
                title: 'Average Mood',
                value: _statistics!.averageScore.toStringAsFixed(1),
                subtitle: '/ 10',
                icon: Icons.sentiment_satisfied_alt,
                color: _getMoodColor(_statistics!.averageScore),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MoodStatsCard(
                title: 'Total Entries',
                value: _statistics!.totalEntries.toString(),
                subtitle: _selectedPeriod.toLowerCase(),
                icon: Icons.calendar_today,
                color: AppTheme.healingTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MoodStatsCard(
                title: 'Best Score',
                value: _statistics!.maxScore.toString(),
                subtitle: '/ 10',
                icon: Icons.trending_up,
                color: AppTheme.sunriseGold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MoodStatsCard(
                title: 'Mood Trend',
                value: _getTrendText(_statistics!.trend),
                subtitle: _selectedPeriod.toLowerCase(),
                icon: _getTrendIcon(_statistics!.trend),
                color: _getTrendColor(_statistics!.trend),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMoodChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood Timeline',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MoodChartWidget(entries: _filteredEntries),
      ],
    );
  }

  Widget _buildInsights() {
    if (_insights.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        MoodInsightsWidget(insights: _insights),
      ],
    );
  }

  Widget _buildEmotionAnalysis() {
    if (_statistics == null || _statistics!.emotionFrequency.isEmpty) {
      return const SizedBox();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Emotions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: _statistics!.emotionFrequency.entries
                .take(5)
                .map((entry) => _buildEmotionItem(entry.key, entry.value))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionItem(String emotion, int count) {
    final percentage = _statistics!.totalEntries > 0 
        ? (count / _statistics!.totalEntries * 100) 
        : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            _getEmotionEmoji(emotion),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotion,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.healingTeal),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatterns() {
    final patterns = MoodAnalytics.identifyPatterns(_filteredEntries);
    
    if (patterns.isEmpty) return const SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patterns & Trends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...patterns.take(3).map((pattern) => _buildPatternCard(pattern)).toList(),
      ],
    );
  }

  Widget _buildPatternCard(MoodPattern pattern) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: pattern.type == PatternType.positiveCorrelation
                  ? AppTheme.sunriseGold.withOpacity(0.2)
                  : AppTheme.healingTeal.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pattern.type == PatternType.positiveCorrelation
                  ? Icons.trending_up
                  : Icons.trending_down,
              color: pattern.type == PatternType.positiveCorrelation
                  ? AppTheme.sunriseGold
                  : AppTheme.healingTeal,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pattern.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: ${(pattern.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Mood Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              'JSON Format',
              'Complete data with analytics',
              Icons.code,
              () => _exportData('json'),
            ),
            _buildExportOption(
              'CSV Spreadsheet',
              'For Excel or Google Sheets',
              Icons.table_chart,
              () => _exportData('csv'),
            ),
            _buildExportOption(
              'Analytics Report',
              'Detailed insights report',
              Icons.analytics,
              () => _exportData('report'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.healingTeal),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      onTap: () {
        context.pop();
        onTap();
      },
    );
  }

  void _exportData(String format) {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting data in $format format...'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  Color _getMoodColor(double score) {
    if (score >= 8) return AppTheme.sunriseGold;
    if (score >= 6) return AppTheme.healingTeal;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getTrendText(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return 'Improving';
      case MoodTrend.declining:
        return 'Declining';
      case MoodTrend.stable:
        return 'Stable';
    }
  }

  IconData _getTrendIcon(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return Icons.trending_up;
      case MoodTrend.declining:
        return Icons.trending_down;
      case MoodTrend.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(MoodTrend trend) {
    switch (trend) {
      case MoodTrend.improving:
        return AppTheme.sunriseGold;
      case MoodTrend.declining:
        return Colors.red;
      case MoodTrend.stable:
        return AppTheme.healingTeal;
    }
  }

  String _getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😄';
      case 'grateful':
        return '🙏';
      case 'peaceful':
        return '😌';
      case 'anxious':
        return '😰';
      case 'sad':
        return '😢';
      case 'angry':
        return '😠';
      case 'excited':
        return '🤗';
      case 'tired':
        return '😴';
      case 'hopeful':
        return '🌟';
      case 'lonely':
        return '😔';
      case 'stressed':
        return '😵';
      case 'content':
        return '😊';
      default:
        return '😊';
    }
  }
}
