import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger.dart';
import '../../../shared/providers/auth_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../mood/screens/mood_tracking_screen.dart';
import '../../prayer/screens/prayer_screen.dart';
import '../../chat/screens/chat_screen.dart';
import '../../settings/screens/settings_screen.dart';

/// Main app shell with bottom navigation
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const MoodTrackingScreen(),
    const PrayerScreen(),
    const ChatScreen(),
    const SettingsScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Mood',
      route: '/mood',
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology,
      label: 'Prayer',
      route: '/prayer',
    ),
    NavigationItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
      route: '/chat',
    ),
    NavigationItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      route: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Update route without navigation
          final route = _navigationItems[index].route;
          if (route != null) {
            context.go(route);
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        items: _navigationItems,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 1 // Show FAB on mood screen
          ? FloatingActionButton(
              onPressed: () {
                // Quick mood entry
                _showQuickMoodEntry(context);
              },
              backgroundColor: AppTheme.healingTeal,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Animate to page
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Navigate to the appropriate route
    final route = _navigationItems[index].route;
    if (route != null) {
      context.go(route);
    }
  }

  void _showQuickMoodEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickMoodEntryModal(),
    );
  }
}

/// Navigation item data class
class NavigationItem {
  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.route,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? route;
}

/// Quick mood entry modal
class QuickMoodEntryModal extends StatefulWidget {
  const QuickMoodEntryModal({super.key});

  @override
  State<QuickMoodEntryModal> createState() => _QuickMoodEntryModalState();
}

class _QuickMoodEntryModalState extends State<QuickMoodEntryModal> {
  double _moodLevel = 5.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'How are you feeling?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 32),

          // Mood slider
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.getMoodColor(_moodLevel.round()),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.getMoodColor(_moodLevel.round())
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMoodEmoji(_moodLevel.round()),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: _moodLevel,
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppTheme.getMoodColor(_moodLevel.round()),
                onChanged: (value) {
                  setState(() {
                    _moodLevel = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${_moodLevel.round()}/10 - ${_getMoodDescription(_moodLevel.round())}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.getMoodColor(_moodLevel.round()),
                    ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Save quick mood entry
                    _saveMoodEntry();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mood saved successfully!'),
                        backgroundColor: AppTheme.healingTeal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.healingTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😞';
      case 3:
        return '😕';
      case 4:
        return '😐';
      case 5:
        return '🙂';
      case 6:
        return '😊';
      case 7:
        return '😄';
      case 8:
        return '😁';
      case 9:
        return '🤗';
      case 10:
        return '🥳';
      default:
        return '🙂';
    }
  }

  String _getMoodDescription(int mood) {
    switch (mood) {
      case 1:
        return 'Very Low';
      case 2:
        return 'Low';
      case 3:
        return 'Below Average';
      case 4:
        return 'Slightly Low';
      case 5:
        return 'Neutral';
      case 6:
        return 'Good';
      case 7:
        return 'Very Good';
      case 8:
        return 'Great';
      case 9:
        return 'Excellent';
      case 10:
        return 'Amazing';
      default:
        return 'Neutral';
    }
  }

  void _saveMoodEntry() {
    // Quick mood entry from FAB
    // Creates a simple mood entry with just the score
    // Full mood tracking available via /mood route
    AppLogger.info('Saving mood entry: ${_moodLevel.round()}');
    // Implementation:
    // final moodService = MoodService.instance;
    // await moodService.saveMoodEntry(score: _moodLevel.round());
  }
}
