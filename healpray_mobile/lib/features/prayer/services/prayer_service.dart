import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_config.dart';
import '../../../shared/models/prayer.dart';
import '../repositories/prayer_repository.dart';

/// Provider for prayer service
final prayerServiceProvider = Provider<PrayerService>((ref) {
  final repository = ref.read(prayerRepositoryProvider);
  return PrayerService(repository);
});

/// Prayer service for AI-powered prayer generation and management
class PrayerService {
  final _uuid = const Uuid();
  late final GenerativeModel _model;
  final PrayerRepository _repository;

  PrayerService(this._repository) {
    // Initialize Google Gemini AI model
    final apiKey = AppConfig.geminiApiKey;
    
    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.8,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
      );
    } else {
      throw Exception('Gemini API key not configured');
    }
  }

  /// Generate a personalized prayer using AI
  Future<Prayer> generatePrayer({
    required String category,
    required String tone,
    required String length,
    String? customIntention,
  }) async {
    try {
      final prompt = _buildPrayerPrompt(
        category: category,
        tone: tone,
        length: length,
        customIntention: customIntention,
      );

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from AI service');
      }

      // Parse the generated prayer
      final prayerText = _cleanupPrayerText(response.text!);
      
      return Prayer(
        id: _uuid.v4(),
        title: _generatePrayerTitle(category),
        content: prayerText,
        category: category,
        tone: tone,
        length: length,
        customIntention: customIntention,
        createdAt: DateTime.now(),
        isFavorite: false,
        tags: _generateTags(category, customIntention),
      );
    } catch (e) {
      throw Exception('Failed to generate prayer: $e');
    }
  }

  /// Save a prayer to local storage
  Future<void> savePrayer(Prayer prayer) async {
    await _repository.savePrayer(prayer);
  }

  /// Get saved prayers
  Future<List<Prayer>> getSavedPrayers() async {
    return await _repository.getAllPrayers();
  }

  /// Get favorite prayers
  Future<List<Prayer>> getFavoritePrayers() async {
    return await _repository.getFavoritePrayers();
  }

  /// Get prayer by ID
  Future<Prayer?> getPrayerById(String id) async {
    return await _repository.getPrayerById(id);
  }

  /// Delete a prayer
  Future<void> deletePrayer(String prayerId) async {
    await _repository.deletePrayer(prayerId);
  }

  /// Toggle favorite status
  Future<Prayer> toggleFavorite(Prayer prayer) async {
    return await _repository.toggleFavorite(prayer);
  }

  /// Search prayers
  Future<List<Prayer>> searchPrayers(String query) async {
    return await _repository.searchPrayers(query);
  }

  /// Get prayers by category
  Future<List<Prayer>> getPrayersByCategory(String category) async {
    return await _repository.getPrayersByCategory(category);
  }

  /// Get category counts
  Future<Map<String, int>> getCategoryCounts() async {
    return await _repository.getCategoryCounts();
  }

  /// Build the AI prompt for prayer generation
  String _buildPrayerPrompt({
    required String category,
    required String tone,
    required String length,
    String? customIntention,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Generate a heartfelt, spiritual prayer with the following parameters:');
    buffer.writeln();
    
    // Category context
    switch (category) {
      case 'gratitude':
        buffer.writeln('Category: Gratitude - A prayer expressing thankfulness and appreciation');
        break;
      case 'healing':
        buffer.writeln('Category: Healing - A prayer for physical, emotional, or spiritual healing');
        break;
      case 'strength':
        buffer.writeln('Category: Strength - A prayer asking for inner strength and courage');
        break;
      case 'peace':
        buffer.writeln('Category: Peace - A prayer seeking inner peace and tranquility');
        break;
      case 'guidance':
        buffer.writeln('Category: Guidance - A prayer asking for divine guidance and wisdom');
        break;
      case 'forgiveness':
        buffer.writeln('Category: Forgiveness - A prayer about forgiveness and mercy');
        break;
      case 'protection':
        buffer.writeln('Category: Protection - A prayer for safety and divine protection');
        break;
      case 'hope':
        buffer.writeln('Category: Hope - A prayer for hope and faith during difficult times');
        break;
      default:
        buffer.writeln('Category: General - A general spiritual prayer');
    }
    
    // Tone context
    switch (tone) {
      case 'warm':
        buffer.writeln('Tone: Warm and comforting, like a gentle embrace');
        break;
      case 'reverent':
        buffer.writeln('Tone: Reverent and respectful, with deep spiritual honor');
        break;
      case 'intimate':
        buffer.writeln('Tone: Intimate and personal, like speaking with a close friend');
        break;
      case 'hopeful':
        buffer.writeln('Tone: Hopeful and uplifting, inspiring faith and optimism');
        break;
      default:
        buffer.writeln('Tone: Warm and comforting');
    }
    
    // Length context
    switch (length) {
      case 'short':
        buffer.writeln('Length: Short and concise (2-3 sentences)');
        break;
      case 'medium':
        buffer.writeln('Length: Medium length (4-6 sentences)');
        break;
      case 'long':
        buffer.writeln('Length: Longer and more detailed (7-10 sentences)');
        break;
      default:
        buffer.writeln('Length: Medium length');
    }
    
    // Custom intention
    if (customIntention != null && customIntention.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Personal intention/specific needs: "$customIntention"');
      buffer.writeln('Please incorporate this personal intention naturally into the prayer.');
    }
    
    buffer.writeln();
    buffer.writeln('Requirements:');
    buffer.writeln('- Use inclusive, non-denominational language that speaks to all faiths');
    buffer.writeln('- Make it deeply personal and emotionally resonant');
    buffer.writeln('- Include elements of hope, love, and spiritual connection');
    buffer.writeln('- Use beautiful, poetic language that inspires the soul');
    buffer.writeln('- End with "Amen" or similar appropriate closing');
    buffer.writeln('- Avoid overly formal or archaic language');
    buffer.writeln();
    buffer.writeln('Generate only the prayer text, without any additional commentary or formatting.');

    return buffer.toString();
  }

  /// Clean up the generated prayer text
  String _cleanupPrayerText(String rawText) {
    // Remove any extra whitespace and formatting
    String cleaned = rawText.trim();
    
    // Remove any markdown or formatting artifacts
    cleaned = cleaned.replaceAll('**', '');
    cleaned = cleaned.replaceAll('*', '');
    cleaned = cleaned.replaceAll('_', '');
    
    // Ensure proper capitalization and punctuation
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }
    
    // Ensure it ends with proper punctuation
    if (!cleaned.endsWith('.') && !cleaned.endsWith('!') && !cleaned.toLowerCase().endsWith('amen.')) {
      cleaned += '.';
    }
    
    return cleaned;
  }

  /// Generate a title for the prayer based on category
  String _generatePrayerTitle(String category) {
    switch (category) {
      case 'gratitude':
        return 'Prayer of Gratitude';
      case 'healing':
        return 'Prayer for Healing';
      case 'strength':
        return 'Prayer for Strength';
      case 'peace':
        return 'Prayer for Peace';
      case 'guidance':
        return 'Prayer for Guidance';
      case 'forgiveness':
        return 'Prayer of Forgiveness';
      case 'protection':
        return 'Prayer for Protection';
      case 'hope':
        return 'Prayer of Hope';
      default:
        return 'Personal Prayer';
    }
  }

  /// Generate relevant tags for the prayer
  List<String> _generateTags(String category, String? customIntention) {
    final tags = <String>[category];
    
    if (customIntention != null && customIntention.isNotEmpty) {
      // Simple keyword extraction from custom intention
      final words = customIntention.toLowerCase().split(' ');
      for (final word in words) {
        if (word.length > 3 && !_commonWords.contains(word)) {
          tags.add(word);
        }
      }
    }
    
    return tags;
  }

  /// Common words to exclude from tags
  static const _commonWords = {
    'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 
    'her', 'was', 'one', 'our', 'out', 'day', 'get', 'has', 'him', 'his',
    'how', 'its', 'may', 'new', 'old', 'see', 'two', 'way', 'who',
    'boy', 'did', 'she', 'use', 'down', 'part',
    'with', 'that', 'have', 'this', 'will', 'been', 'they', 'were', 'said',
    'each', 'word', 'time', 'very', 'when', 'come', 'here', 'just', 'like',
    'over', 'also', 'back', 'after', 'well', 'year', 'work', 'three',
    'where', 'would', 'there', 'could', 'other', 'then', 'them', 'these',
    'many', 'some', 'what', 'know', 'water', 'than', 'call', 'made',
    'right', 'look', 'think', 'help', 'feel', 'need', 'want',
    'please', 'thank', 'pray', 'prayer', 'god', 'lord', 'jesus', 'christ',
    'holy', 'spirit', 'amen', 'bless', 'blessed', 'blessing'
  };
}
