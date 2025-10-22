import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/prayer.dart';
import '../../../core/utils/logger.dart';

/// Provider for prayer repository
final prayerRepositoryProvider = Provider<PrayerRepository>((ref) {
  return InMemoryPrayerRepository();
});

/// Abstract prayer repository interface
abstract class PrayerRepository {
  Future<void> savePrayer(Prayer prayer);
  Future<List<Prayer>> getAllPrayers();
  Future<List<Prayer>> getFavoritePrayers();
  Future<Prayer?> getPrayerById(String id);
  Future<void> deletePrayer(String id);
  Future<Prayer> toggleFavorite(Prayer prayer);
  Future<List<Prayer>> searchPrayers(String query);
  Future<List<Prayer>> getPrayersByCategory(String category);
  Future<Map<String, int>> getCategoryCounts();
}

/// In-memory implementation of prayer repository
/// This will be replaced with Hive/SQLite implementation later
class InMemoryPrayerRepository implements PrayerRepository {
  final List<Prayer> _prayers = [];

  @override
  Future<void> savePrayer(Prayer prayer) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));

    // Update existing or add new
    final existingIndex = _prayers.indexWhere((p) => p.id == prayer.id);
    if (existingIndex != -1) {
      _prayers[existingIndex] = prayer.copyWith(updatedAt: DateTime.now());
    } else {
      _prayers.add(prayer);
    }

    AppLogger.info('Prayer saved: ${prayer.title}');
  }

  @override
  Future<List<Prayer>> getAllPrayers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List<Prayer>.from(_prayers.reversed); // Most recent first
  }

  @override
  Future<List<Prayer>> getFavoritePrayers() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _prayers
        .where((prayer) => prayer.isFavorite)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<Prayer?> getPrayerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _prayers.firstWhere((prayer) => prayer.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deletePrayer(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _prayers.removeWhere((prayer) => prayer.id == id);
    AppLogger.info('Prayer deleted: $id');
  }

  @override
  Future<Prayer> toggleFavorite(Prayer prayer) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final updatedPrayer = prayer.copyWith(
      isFavorite: !prayer.isFavorite,
      updatedAt: DateTime.now(),
    );

    await savePrayer(updatedPrayer);
    return updatedPrayer;
  }

  @override
  Future<List<Prayer>> searchPrayers(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final lowercaseQuery = query.toLowerCase();
    return _prayers
        .where((prayer) {
          return prayer.title.toLowerCase().contains(lowercaseQuery) ||
              prayer.content.toLowerCase().contains(lowercaseQuery) ||
              prayer.category.toLowerCase().contains(lowercaseQuery) ||
              prayer.tags
                  .any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
              (prayer.customIntention?.toLowerCase().contains(lowercaseQuery) ??
                  false);
        })
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<List<Prayer>> getPrayersByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _prayers
        .where((prayer) => prayer.category == category)
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<Map<String, int>> getCategoryCounts() async {
    await Future.delayed(const Duration(milliseconds: 50));

    final counts = <String, int>{};
    for (final prayer in _prayers) {
      counts[prayer.category] = (counts[prayer.category] ?? 0) + 1;
    }

    return counts;
  }
}
