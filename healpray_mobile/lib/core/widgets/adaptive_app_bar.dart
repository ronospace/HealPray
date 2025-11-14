import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Adaptive AppBar that works on gradient backgrounds
/// with proper text visibility in both light and dark modes
class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.bottom,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final double elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use semi-transparent background with better contrast for light mode
    final effectiveBackgroundColor = backgroundColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.9));

    // Text and icon colors that adapt to theme
    final textColor = isDark ? Colors.white : Colors.black87;
    final iconColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            effectiveBackgroundColor,
            effectiveBackgroundColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: AppBar(
        title: title,
        actions: actions,
        leading: leading,
        backgroundColor: Colors.transparent,
        elevation: elevation,
        centerTitle: centerTitle,
        bottom: bottom,
        foregroundColor: textColor,
        iconTheme: IconThemeData(color: iconColor),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          shadows: isDark ? [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ] : null,
        ),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// Extension to create AdaptiveAppBar easily
extension AdaptiveAppBarX on AppBar {
  static AdaptiveAppBar adaptive({
    Key? key,
    Widget? title,
    List<Widget>? actions,
    Widget? leading,
    Color? backgroundColor,
    double elevation = 0,
    bool centerTitle = false,
    PreferredSizeWidget? bottom,
  }) {
    return AdaptiveAppBar(
      key: key,
      title: title,
      actions: actions,
      leading: leading,
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      bottom: bottom,
    );
  }
}
