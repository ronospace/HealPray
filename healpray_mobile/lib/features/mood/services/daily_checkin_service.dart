import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage daily mood check-in logic
class DailyCheckInService {
  static const String _lastCheckInKey = 'last_mood_checkin_date';
  static const String _checkInCountKey = 'total_checkin_count';
  static const String _streakCountKey = 'checkin_streak_count';

  /// Check if user should be prompted for daily check-in
  static Future<bool> shouldShowCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckIn = prefs.getString(_lastCheckInKey);

    if (lastCheckIn == null) {
      // First time user - show check-in
      return true;
    }

    final lastDate = DateTime.parse(lastCheckIn);
    final now = DateTime.now();

    // Check if it's a new day
    final isNewDay = now.year != lastDate.year ||
        now.month != lastDate.month ||
        now.day != lastDate.day;

    return isNewDay;
  }

  /// Record that check-in was completed
  static Future<void> recordCheckIn() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Save today's date
    await prefs.setString(_lastCheckInKey, today.toIso8601String());

    // Increment total count
    final totalCount = prefs.getInt(_checkInCountKey) ?? 0;
    await prefs.setInt(_checkInCountKey, totalCount + 1);

    // Update streak
    await _updateStreak(prefs, today);
  }

  /// Update check-in streak
  static Future<void> _updateStreak(SharedPreferences prefs, DateTime today) async {
    final lastCheckIn = prefs.getString(_lastCheckInKey);
    if (lastCheckIn == null) {
      // First check-in
      await prefs.setInt(_streakCountKey, 1);
      return;
    }

    final lastDate = DateTime.parse(lastCheckIn);
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastDate.year == yesterday.year &&
        lastDate.month == yesterday.month &&
        lastDate.day == yesterday.day) {
      // Consecutive day - increment streak
      final currentStreak = prefs.getInt(_streakCountKey) ?? 0;
      await prefs.setInt(_streakCountKey, currentStreak + 1);
    } else if (lastDate.year == today.year &&
        lastDate.month == today.month &&
        lastDate.day == today.day) {
      // Same day - keep streak as is
      return;
    } else {
      // Streak broken - reset to 1
      await prefs.setInt(_streakCountKey, 1);
    }
  }

  /// Get current check-in streak
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakCountKey) ?? 0;
  }

  /// Get total check-in count
  static Future<int> getTotalCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_checkInCountKey) ?? 0;
  }

  /// Get last check-in date
  static Future<DateTime?> getLastCheckInDate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheckIn = prefs.getString(_lastCheckInKey);
    if (lastCheckIn == null) return null;
    return DateTime.parse(lastCheckIn);
  }

  /// Reset all check-in data (for testing or user request)
  static Future<void> resetCheckInData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckInKey);
    await prefs.remove(_checkInCountKey);
    await prefs.remove(_streakCountKey);
  }
}
