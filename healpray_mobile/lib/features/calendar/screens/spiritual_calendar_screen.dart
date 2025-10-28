import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';

/// Event types for calendar
enum EventType {
  prayer,
  meditation,
  scripture,
  journal,
  mood,
  community,
}

extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.prayer:
        return 'Prayer';
      case EventType.meditation:
        return 'Meditation';
      case EventType.scripture:
        return 'Scripture';
      case EventType.journal:
        return 'Journal';
      case EventType.mood:
        return 'Mood Check';
      case EventType.community:
        return 'Community';
    }
  }

  IconData get icon {
    switch (this) {
      case EventType.prayer:
        return Icons.favorite;
      case EventType.meditation:
        return Icons.self_improvement;
      case EventType.scripture:
        return Icons.menu_book;
      case EventType.journal:
        return Icons.book;
      case EventType.mood:
        return Icons.mood;
      case EventType.community:
        return Icons.groups;
    }
  }

  Color get color {
    switch (this) {
      case EventType.prayer:
        return AppTheme.healingTeal;
      case EventType.meditation:
        return AppTheme.mysticalPurple;
      case EventType.scripture:
        return AppTheme.wisdomGold;
      case EventType.journal:
        return AppTheme.celestialCyan;
      case EventType.mood:
        return AppTheme.sunriseGold;
      case EventType.community:
        return AppTheme.hopeOrange;
    }
  }
}

/// Calendar event model
class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final String? description;
  final double? moodScore;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    this.description,
    this.moodScore,
  });
}

/// Spiritual Calendar screen with mood history and prayer schedule
class SpiritualCalendarScreen extends ConsumerStatefulWidget {
  const SpiritualCalendarScreen({super.key});

  @override
  ConsumerState<SpiritualCalendarScreen> createState() => _SpiritualCalendarScreenState();
}

class _SpiritualCalendarScreenState extends ConsumerState<SpiritualCalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Set<EventType> _selectedEventTypes = EventType.values.toSet();

  // Sample events
  final Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _generateSampleEvents();
  }

  void _generateSampleEvents() {
    final now = DateTime.now();
    
    // Add sample events for the past week
    for (int i = 0; i < 7; i++) {
      final date = DateTime(now.year, now.month, now.day - i);
      
      _events[date] = [
        CalendarEvent(
          id: 'mood_$i',
          title: 'Daily mood check-in',
          date: date,
          type: EventType.mood,
          moodScore: 7 + (i % 3).toDouble(),
        ),
        if (i % 2 == 0)
          CalendarEvent(
            id: 'prayer_$i',
            title: 'Morning prayer',
            date: date,
            type: EventType.prayer,
            description: 'Started the day with gratitude',
          ),
        if (i % 3 == 0)
          CalendarEvent(
            id: 'meditation_$i',
            title: '15-minute meditation',
            date: date,
            type: EventType.meditation,
          ),
      ];
    }

    // Future prayer schedule
    _events[DateTime(now.year, now.month, now.day + 1)] = [
      CalendarEvent(
        id: 'future_1',
        title: 'Morning prayer',
        date: DateTime(now.year, now.month, now.day + 1, 7, 0),
        type: EventType.prayer,
      ),
    ];
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final events = _events[normalizedDay] ?? [];
    return events.where((e) => _selectedEventTypes.contains(e.type)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedEvents = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Spiritual Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            // Calendar
            GlassCard(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.sunday,
                calendarStyle: CalendarStyle(
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppTheme.healingTeal.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppTheme.healingTeal,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppTheme.sunriseGold,
                    shape: BoxShape.circle,
                  ),
                  defaultTextStyle: const TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: AppTheme.hopeOrange),
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  todayTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  weekendStyle: TextStyle(color: AppTheme.hopeOrange.withValues(alpha: 0.8)),
                ),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),

            // Events for selected day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(_selectedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (selectedEvents.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.healingTeal.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${selectedEvents.length} ${selectedEvents.length == 1 ? 'event' : 'events'}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Events List
            Expanded(
              child: selectedEvents.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        return _buildEventCard(selectedEvents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEvent,
        icon: const Icon(Icons.add),
        label: const Text('Add Event'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Type Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: event.type.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(event.type.icon, color: event.type.color, size: 28),
          ),

          const SizedBox(width: 16),

          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: event.type.color.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.type.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (event.moodScore != null) ...[
                      const SizedBox(width: 8),
                      _buildMoodIndicator(event.moodScore!),
                    ],
                  ],
                ),
                if (event.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Time (if available)
          if (event.date.hour != 0 || event.date.minute != 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                DateFormat('h:mm a').format(event.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMoodIndicator(double score) {
    IconData icon;
    Color color;

    if (score >= 8) {
      icon = Icons.sentiment_very_satisfied;
      color = AppTheme.sunriseGold;
    } else if (score >= 6) {
      icon = Icons.sentiment_satisfied;
      color = AppTheme.healingTeal;
    } else if (score >= 4) {
      icon = Icons.sentiment_neutral;
      color = AppTheme.celestialCyan;
    } else {
      icon = Icons.sentiment_dissatisfied;
      color = AppTheme.mysticalPurple;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.celestialCyan, AppTheme.sacredBlue],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          const Text(
            'No events for this day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first spiritual activity',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Filter Events', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: EventType.values.map((type) {
                final isSelected = _selectedEventTypes.contains(type);
                return CheckboxListTile(
                  title: Row(
                    children: [
                      Icon(type.icon, color: type.color, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        type.displayName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (value) {
                    setDialogState(() {
                      if (value == true) {
                        _selectedEventTypes.add(type);
                      } else {
                        _selectedEventTypes.remove(type);
                      }
                    });
                  },
                  activeColor: type.color,
                  checkColor: Colors.white,
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _addEvent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.mysticalPurple.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Event', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Event scheduling coming soon!',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'For now, your activities are automatically tracked.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.healingTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
