import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/adaptive_app_bar.dart';
import '../../../core/widgets/animated_gradient_background.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math';

/// Complete Scripture Reading screen with daily verses and reading plans
class ScriptureReadingScreen extends ConsumerStatefulWidget {
  const ScriptureReadingScreen({super.key});

  @override
  ConsumerState<ScriptureReadingScreen> createState() => _ScriptureReadingScreenState();
}

class _ScriptureReadingScreenState extends ConsumerState<ScriptureReadingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dailyVerses = _DailyVerseData.verses;
  int _currentVerseIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentVerseIndex = DateTime.now().day % _dailyVerses.length;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVerse = _dailyVerses[_currentVerseIndex];

    return Scaffold(
      appBar: AdaptiveAppBar(
        title: const Text('Scripture Reading'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.today), text: 'Daily'),
            Tab(icon: Icon(Icons.book), text: 'Reading Plans'),
            Tab(icon: Icon(Icons.bookmark), text: 'Saved'),
          ],
        ),
      ),
      body: AnimatedGradientBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDailyVerseTab(currentVerse),
            _buildReadingPlansTab(),
            _buildSavedVersesTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _shareVerse(currentVerse),
        icon: const Icon(Icons.share),
        label: const Text('Share'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }

  Widget _buildDailyVerseTab(Map<String, String> verse) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Verse of the Day Card
          GlassCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.sunriseGold, AppTheme.hopeOrange],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verse of the Day',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Daily inspiration for your journey',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Verse Text
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        verse['text']!,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '— ${verse['reference']} —',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.sunriseGold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.bookmark_border,
                        label: 'Save',
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.refresh,
                        label: 'New Verse',
                        onTap: () {
                          setState(() {
                            _currentVerseIndex = Random().nextInt(_dailyVerses.length);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Reflection Section
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.wisdomGold),
                    const SizedBox(width: 12),
                    const Text(
                      'Reflection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  verse['reflection']!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingPlansTab() {
    final plans = _ReadingPlanData.plans;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        return GlassCard(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: plan['colors'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(plan['icon'] as IconData, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan['title'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan['duration']} • ${plan['readings']} readings',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan['description'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: plan['progress'] as double,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(
                  (plan['colors'] as List<Color>)[0],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${((plan['progress'] as double) * 100).round()}% Complete',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedVersesTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved verses yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the bookmark icon to save verses',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareVerse(Map<String, String> verse) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${verse['reference']}'),
        backgroundColor: AppTheme.healingTeal,
      ),
    );
  }
}

// Sample data
class _DailyVerseData {
  static final verses = [
    {
      'text': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.',
      'reference': 'Jeremiah 29:11',
      'reflection': 'God has a purpose for your life. Even in uncertain times, trust that His plans are for your good and filled with hope.',
    },
    {
      'text': 'Be still, and know that I am God.',
      'reference': 'Psalm 46:10',
      'reflection': 'In the chaos of life, find peace in stillness. God is present in the quiet moments when we pause to listen.',
    },
    {
      'text': 'The Lord is my shepherd; I shall not want.',
      'reference': 'Psalm 23:1',
      'reflection': 'When God leads us, we lack nothing truly important. Trust in His provision and guidance.',
    },
    {
      'text': 'I can do all things through Christ who strengthens me.',
      'reference': 'Philippians 4:13',
      'reflection': 'Your strength comes from a power greater than yourself. With faith, no challenge is insurmountable.',
    },
    {
      'text': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.',
      'reference': '1 Corinthians 13:4',
      'reflection': 'True love reflects divine character. Let patience and kindness guide all your relationships.',
    },
  ];
}

class _ReadingPlanData {
  static final plans = [
    {
      'title': 'Psalms of Comfort',
      'description': 'Find peace and reassurance through the beautiful poetry of Psalms',
      'duration': '7 days',
      'readings': 7,
      'progress': 0.43,
      'icon': Icons.favorite,
      'colors': [AppTheme.healingTeal, AppTheme.celestialCyan],
    },
    {
      'title': 'Gospel Journey',
      'description': 'Walk through the life and teachings of Jesus in the Gospels',
      'duration': '30 days',
      'readings': 30,
      'progress': 0.20,
      'icon': Icons.menu_book,
      'colors': [AppTheme.sunriseGold, AppTheme.wisdomGold],
    },
    {
      'title': 'Proverbs Wisdom',
      'description': 'Daily wisdom for practical living from the book of Proverbs',
      'duration': '31 days',
      'readings': 31,
      'progress': 0.0,
      'icon': Icons.lightbulb,
      'colors': [AppTheme.mysticalPurple, AppTheme.sacredBlue],
    },
  ];
}
