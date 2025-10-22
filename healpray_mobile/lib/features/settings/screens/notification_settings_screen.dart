import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/services/notification_service.dart';
import '../../../core/utils/logger.dart';

/// Notification settings provider
final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(const NotificationPreferences()) {
    _loadCurrentPreferences();
  }

  final NotificationService _notificationService = NotificationService.instance;

  void _loadCurrentPreferences() {
    state = _notificationService.preferences;
  }

  Future<void> updatePreferences(NotificationPreferences newPreferences) async {
    state = newPreferences;
    await _notificationService.updatePreferences(newPreferences);
  }

  void toggleMeditationReminders(bool enabled) {
    final updated = state.copyWith(meditationReminders: enabled);
    updatePreferences(updated);
  }

  void updateMeditationTime(TimeOfDay time) {
    final updated = state.copyWith(meditationTime: time);
    updatePreferences(updated);
  }

  void updateMeditationDays(List<int> days) {
    final updated = state.copyWith(meditationDays: days);
    updatePreferences(updated);
  }

  void toggleMoodCheckins(bool enabled) {
    final updated = state.copyWith(moodCheckins: enabled);
    updatePreferences(updated);
  }

  void updateMoodCheckinTime(TimeOfDay time) {
    final updated = state.copyWith(moodCheckinTime: time);
    updatePreferences(updated);
  }

  void toggleVerseOfDay(bool enabled) {
    final updated = state.copyWith(verseOfDay: enabled);
    updatePreferences(updated);
  }

  void updateVerseOfDayTime(TimeOfDay time) {
    final updated = state.copyWith(verseOfDayTime: time);
    updatePreferences(updated);
  }

  void togglePrayerReminders(bool enabled) {
    final updated = state.copyWith(prayerReminders: enabled);
    updatePreferences(updated);
  }

  void addPrayerTime(TimeOfDay time) {
    final updatedTimes = List<TimeOfDay>.from(state.prayerTimes)..add(time);
    final updated = state.copyWith(prayerTimes: updatedTimes);
    updatePreferences(updated);
  }

  void removePrayerTime(int index) {
    final updatedTimes = List<TimeOfDay>.from(state.prayerTimes)
      ..removeAt(index);
    final updated = state.copyWith(prayerTimes: updatedTimes);
    updatePreferences(updated);
  }

  void toggleSpiritualInsights(bool enabled) {
    final updated = state.copyWith(spiritualInsights: enabled);
    updatePreferences(updated);
  }

  void toggleCrisisAlerts(bool enabled) {
    final updated = state.copyWith(crisisAlerts: enabled);
    updatePreferences(updated);
  }
}

/// Notification settings screen
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(notificationPreferencesProvider);
    final notifier = ref.read(notificationPreferencesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.midnightBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Stay Connected to Your Spiritual Journey',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.midnightBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),

            const SizedBox(height: 8),

            Text(
              'Customize when and how you receive gentle reminders and spiritual insights.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),

            const SizedBox(height: 32),

            // Meditation Reminders
            _buildNotificationSection(
              context,
              title: 'Meditation Reminders',
              subtitle: 'Daily reminders for mindful moments',
              icon: Icons.self_improvement,
              color: AppTheme.healingTeal,
              enabled: preferences.meditationReminders,
              onToggle: notifier.toggleMeditationReminders,
              children: preferences.meditationReminders
                  ? [
                      _buildTimeSelector(
                        context,
                        'Meditation Time',
                        preferences.meditationTime ??
                            const TimeOfDay(hour: 8, minute: 0),
                        (time) => notifier.updateMeditationTime(time),
                      ),
                      _buildDaySelector(
                        context,
                        'Meditation Days',
                        preferences.meditationDays,
                        (days) => notifier.updateMeditationDays(days),
                      ),
                    ]
                  : null,
            ),

            const SizedBox(height: 24),

            // Mood Check-ins
            _buildNotificationSection(
              context,
              title: 'Mood Check-ins',
              subtitle: 'Regular emotional wellness reminders',
              icon: Icons.favorite,
              color: AppTheme.sunriseGold,
              enabled: preferences.moodCheckins,
              onToggle: notifier.toggleMoodCheckins,
              children: preferences.moodCheckins
                  ? [
                      _buildTimeSelector(
                        context,
                        'Check-in Time',
                        preferences.moodCheckinTime ??
                            const TimeOfDay(hour: 20, minute: 0),
                        (time) => notifier.updateMoodCheckinTime(time),
                      ),
                    ]
                  : null,
            ),

            const SizedBox(height: 24),

            // Daily Verse
            _buildNotificationSection(
              context,
              title: 'Daily Verse',
              subtitle: 'Morning scripture inspiration',
              icon: Icons.menu_book,
              color: AppTheme.midnightBlue,
              enabled: preferences.verseOfDay,
              onToggle: notifier.toggleVerseOfDay,
              children: preferences.verseOfDay
                  ? [
                      _buildTimeSelector(
                        context,
                        'Daily Verse Time',
                        preferences.verseOfDayTime ??
                            const TimeOfDay(hour: 7, minute: 0),
                        (time) => notifier.updateVerseOfDayTime(time),
                      ),
                    ]
                  : null,
            ),

            const SizedBox(height: 24),

            // Prayer Reminders
            _buildNotificationSection(
              context,
              title: 'Prayer Reminders',
              subtitle: 'Custom prayer time notifications',
              icon: Icons.church,
              color: AppTheme.healingBlue,
              enabled: preferences.prayerReminders,
              onToggle: notifier.togglePrayerReminders,
              children: preferences.prayerReminders
                  ? [
                      _buildPrayerTimesManager(
                          context, preferences.prayerTimes, notifier),
                    ]
                  : null,
            ),

            const SizedBox(height: 24),

            // General Notifications
            _buildGeneralNotifications(context, preferences, notifier),

            const SizedBox(height: 32),

            // Test notification button
            _buildTestButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
    required Function(bool) onToggle,
    List<Widget>? children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.midnightBlue,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: enabled,
                onChanged: onToggle,
                activeColor: color,
              ),
            ],
          ),
          if (children != null && enabled) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.grey, thickness: 0.5),
            const SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    TimeOfDay currentTime,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.midnightBlue,
              ),
        ),
        TextButton(
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: currentTime,
            );
            if (time != null) {
              onTimeChanged(time);
            }
          },
          child: Text(
            currentTime.format(context),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(
    BuildContext context,
    String label,
    List<int> selectedDays,
    Function(List<int>) onDaysChanged,
  ) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.midnightBlue,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final dayIndex = index + 1; // 1-7 for Monday-Sunday
            final isSelected = selectedDays.contains(dayIndex);

            return GestureDetector(
              onTap: () {
                final updatedDays = List<int>.from(selectedDays);
                if (isSelected) {
                  updatedDays.remove(dayIndex);
                } else {
                  updatedDays.add(dayIndex);
                }
                updatedDays.sort();
                onDaysChanged(updatedDays);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.healingTeal : Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesManager(
    BuildContext context,
    List<TimeOfDay> prayerTimes,
    NotificationPreferencesNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Prayer Times',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.midnightBlue,
                  ),
            ),
            TextButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 12, minute: 0),
                );
                if (time != null) {
                  notifier.addPrayerTime(time);
                }
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Time'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (prayerTimes.isEmpty)
          Text(
            'No prayer times set. Tap "Add Time" to create reminders.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
          )
        else
          ...prayerTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time.format(context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  IconButton(
                    onPressed: () => notifier.removePrayerTime(index),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.grey[600],
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildGeneralNotifications(
    BuildContext context,
    NotificationPreferences preferences,
    NotificationPreferencesNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'General Notifications',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.midnightBlue,
                ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            context,
            'Spiritual Insights',
            'Personalized guidance and recommendations',
            preferences.spiritualInsights,
            notifier.toggleSpiritualInsights,
            Icons.lightbulb_outline,
            AppTheme.sunriseNova,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            context,
            'Crisis Support',
            'Important mental health and safety alerts',
            preferences.crisisAlerts,
            notifier.toggleCrisisAlerts,
            Icons.favorite,
            Colors.red[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.midnightBlue,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: color,
        ),
      ],
    );
  }

  Widget _buildTestButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _testNotifications(context),
        icon: const Icon(Icons.notifications_outlined),
        label: const Text('Test Notifications'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppTheme.healingTeal),
          foregroundColor: AppTheme.healingTeal,
        ),
      ),
    );
  }

  Future<void> _testNotifications(BuildContext context) async {
    try {
      final notificationService = NotificationService.instance;

      await notificationService.showImmediateNotification(
        title: 'Test Notification 🧘',
        body: 'Your notification settings are working perfectly!',
        channel: NotificationChannel.meditation,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test notification sent!'),
            backgroundColor: AppTheme.healingTeal,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to send test notification', e);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send notification: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
