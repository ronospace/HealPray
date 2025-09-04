import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_theme.dart';
import '../models/simple_mood_entry.dart';
import '../services/mood_service.dart';
import '../widgets/mood_entry_card.dart';

/// Calendar view for mood history with visual mood indicators
class MoodCalendarScreen extends ConsumerStatefulWidget {
  const MoodCalendarScreen({super.key});

  @override
  ConsumerState<MoodCalendarScreen> createState() => _MoodCalendarScreenState();
}

class _MoodCalendarScreenState extends ConsumerState<MoodCalendarScreen> {
  final MoodService _moodService = MoodService.instance;
  
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late PageController _pageController;
  
  Map<DateTime, List<SimpleMoodEntry>> _groupedEntries = {};
  List<SimpleMoodEntry> _selectedDayEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _pageController = PageController();
    _loadMoodEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodEntries() async {
    setState(() => _isLoading = true);
    
    try {
      await _moodService.initialize();
      final entries = _moodService.getAllMoodEntries();
      
      // Group entries by date (without time)
      _groupedEntries = {};
      for (final entry in entries) {
        final dateKey = DateTime(
          entry.timestamp.year,
          entry.timestamp.month,
          entry.timestamp.day,
        );
        
        _groupedEntries.putIfAbsent(dateKey, () => []).add(entry);
      }
      
      // Sort entries within each day by timestamp
      _groupedEntries.forEach((date, entries) {
        entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      });
      
      _updateSelectedDayEntries();
      
    } catch (e) {
      debugPrint('Error loading mood entries: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateSelectedDayEntries() {
    _selectedDayEntries = _groupedEntries[_selectedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(
        title: const Text(
          'Mood Calendar',
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
            onPressed: () => _showCalendarLegend(),
            icon: const Icon(
              Icons.help_outline,
              color: AppTheme.textPrimary,
            ),
          ),
          IconButton(
            onPressed: () => context.push('/mood/entry'),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppTheme.healingTeal,
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
          : RefreshIndicator(
              onRefresh: _loadMoodEntries,
              color: AppTheme.healingTeal,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildSelectedDaySection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
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
      child: TableCalendar<SimpleMoodEntry>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => _groupedEntries[day] ?? [],
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarFormat: CalendarFormat.month,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppTheme.healingTeal,
            size: 28,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppTheme.healingTeal,
            size: 28,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          defaultTextStyle: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          todayDecoration: BoxDecoration(
            color: AppTheme.sunriseGold.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppTheme.healingTeal,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppTheme.healingTeal,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 1,
          canMarkersOverflow: false,
        ),
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _updateSelectedDayEntries();
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();
            
            final entries = events.cast<SimpleMoodEntry>();
            final averageMood = _calculateAverageMood(entries);
            
            return Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _getMoodColor(averageMood),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entries.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectedDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.today,
              color: AppTheme.healingTeal,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _formatSelectedDate(_selectedDay),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (_selectedDayEntries.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.healingTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_selectedDayEntries.length} ${_selectedDayEntries.length == 1 ? 'entry' : 'entries'}',
                  style: const TextStyle(
                    color: AppTheme.healingTeal,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _selectedDayEntries.isEmpty
            ? _buildEmptyDayState()
            : _buildDayEntries(),
      ],
    );
  }

  Widget _buildEmptyDayState() {
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isPast = _selectedDay.isBefore(DateTime.now());
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
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
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.healingTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sentiment_neutral,
              size: 32,
              color: AppTheme.healingTeal,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isToday 
                ? 'No mood entries for today'
                : isPast
                    ? 'No mood entries for this day'
                    : 'Future date',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isToday
                ? 'How are you feeling right now?'
                : isPast
                    ? 'You didn\'t log your mood this day'
                    : 'You can only log mood for today',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          if (isToday) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.push('/mood/entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.healingTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Log Mood',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayEntries() {
    // Calculate average mood for the day
    final averageMood = _calculateAverageMood(_selectedDayEntries);
    
    return Column(
      children: [
        // Day summary card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getMoodColor(averageMood),
                _getMoodColor(averageMood).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _getMoodColor(averageMood).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _getMoodEmoji(averageMood.round()),
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                'Average: ${averageMood.toStringAsFixed(1)}/10',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                _getMoodDescription(averageMood.round()),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Individual entries
        ..._selectedDayEntries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MoodEntryCard(
            entry: entry,
            onTap: () => _showEntryDetails(entry),
          ),
        )).toList(),
      ],
    );
  }

  void _showEntryDetails(SimpleMoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getMoodColor(entry.score.toDouble()).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              _getMoodEmoji(entry.score),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.score}/10 - ${_getMoodDescription(entry.score)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                _formatEntryTime(entry.timestamp),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Emotions
                    if (entry.emotions.isNotEmpty) ...[
                      const Text(
                        'Emotions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: entry.emotions.map((emotion) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.healingTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            emotion,
                            style: const TextStyle(
                              color: AppTheme.healingTeal,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Triggers
                    if (entry.metadata['triggers'] != null) ...[
                      const Text(
                        'Triggers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (entry.metadata['triggers'] as List).map((trigger) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.sunriseGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            trigger.toString(),
                            style: const TextStyle(
                              color: AppTheme.sunriseGold,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Activities
                    if (entry.metadata['activities'] != null) ...[
                      const Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: (entry.metadata['activities'] as List).map((activity) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.midnightBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            activity.toString(),
                            style: const TextStyle(
                              color: AppTheme.midnightBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Notes
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.notes!,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Calendar Legend',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLegendItem(
              _getMoodColor(9), 
              'Great Mood (8-10)',
              'Excellent and amazing days'
            ),
            _buildLegendItem(
              _getMoodColor(7), 
              'Good Mood (6-7)',
              'Good and very good days'
            ),
            _buildLegendItem(
              _getMoodColor(5), 
              'Neutral Mood (4-5)',
              'Average and neutral days'
            ),
            _buildLegendItem(
              _getMoodColor(2), 
              'Low Mood (1-3)',
              'Challenging and difficult days'
            ),
            const SizedBox(height: 16),
            const Text(
              'Numbers on circles show entry count for that day.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it',
              style: TextStyle(
                color: AppTheme.healingTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateAverageMood(List<SimpleMoodEntry> entries) {
    if (entries.isEmpty) return 0.0;
    final sum = entries.fold<int>(0, (sum, entry) => sum + entry.score);
    return sum / entries.length;
  }

  Color _getMoodColor(double score) {
    if (score >= 8) return AppTheme.sunriseGold;
    if (score >= 6) return AppTheme.healingTeal;
    if (score >= 4) return Colors.orange;
    return Colors.red;
  }

  String _getMoodEmoji(int score) {
    switch (score) {
      case 1: return '😢';
      case 2: return '😞';
      case 3: return '😕';
      case 4: return '😐';
      case 5: return '🙂';
      case 6: return '😊';
      case 7: return '😄';
      case 8: return '😁';
      case 9: return '🤗';
      case 10: return '🥳';
      default: return '🙂';
    }
  }

  String _getMoodDescription(int score) {
    switch (score) {
      case 1: return 'Very Low';
      case 2: return 'Low';
      case 3: return 'Below Average';
      case 4: return 'Slightly Low';
      case 5: return 'Neutral';
      case 6: return 'Good';
      case 7: return 'Very Good';
      case 8: return 'Great';
      case 9: return 'Excellent';
      case 10: return 'Amazing';
      default: return 'Neutral';
    }
  }

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Today';
    } else if (isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _formatEntryTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    if (hour == 0) {
      return '12:${minute} AM';
    } else if (hour < 12) {
      return '$hour:$minute AM';
    } else if (hour == 12) {
      return '12:$minute PM';
    } else {
      return '${hour - 12}:$minute PM';
    }
  }
}
