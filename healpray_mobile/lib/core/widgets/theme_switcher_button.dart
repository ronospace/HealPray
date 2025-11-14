import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

/// Floating theme switcher button for easy theme toggling
class ThemeSwitcherButton extends ConsumerWidget {
  final bool showLabel;
  final bool mini;
  
  const ThemeSwitcherButton({
    super.key,
    this.showLabel = false,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return FloatingActionButton(
      mini: mini,
      heroTag: 'theme_switcher',
      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      backgroundColor: isDark 
          ? AppTheme.healingTeal.withValues(alpha: 0.9)
          : AppTheme.primaryColor.withValues(alpha: 0.9),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Compact theme switcher for app bars
class CompactThemeSwitcher extends ConsumerWidget {
  const CompactThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return IconButton(
      onPressed: () => ref.read(themeModeProvider.notifier).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(isDark),
        ),
      ),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}
