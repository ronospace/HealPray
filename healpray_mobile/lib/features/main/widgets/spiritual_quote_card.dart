import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/enhanced_glass_card.dart';

/// Spiritual quote card for daily inspiration
class SpiritualQuoteCard extends StatelessWidget {
  const SpiritualQuoteCard({super.key});

  // List of inspirational spiritual quotes
  static const List<Map<String, String>> _quotes = [
    {
      'quote': 'Be still and know that I am God.',
      'source': 'Psalm 46:10',
    },
    {
      'quote': 'Peace I leave with you; my peace I give you.',
      'source': 'John 14:27',
    },
    {
      'quote': 'The Lord your God is with you, the Mighty Warrior who saves.',
      'source': 'Zephaniah 3:17',
    },
    {
      'quote': 'Cast all your anxiety on him because he cares for you.',
      'source': '1 Peter 5:7',
    },
    {
      'quote': 'For I know the plans I have for you, plans to prosper you.',
      'source': 'Jeremiah 29:11',
    },
    {
      'quote': 'The Lord is my shepherd, I lack nothing.',
      'source': 'Psalm 23:1',
    },
    {
      'quote': 'Trust in the Lord with all your heart.',
      'source': 'Proverbs 3:5',
    },
    {
      'quote': 'I can do all things through Christ who strengthens me.',
      'source': 'Philippians 4:13',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Get today's quote based on day of year
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final quote = _quotes[dayOfYear % _quotes.length];

    return EnhancedGlassCard(
      enableShimmer: true,
      borderRadius: 20,
      blur: 20,
      opacity: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Daily Inspiration',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            quote['quote']!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            '— ${quote['source']}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
