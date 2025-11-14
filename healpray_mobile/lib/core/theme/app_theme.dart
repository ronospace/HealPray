import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// HealPray design system and theming
/// Enhanced with Flow-Ai inspired gradients and color transitions
class AppTheme {
  AppTheme._();

  // === CORE SPIRITUAL COLORS ===

  // Primary Healing Palette (Enhanced)
  static const Color healingTeal = Color(0xFF4ECDC4); // Turquoise healing
  static const Color sacredBlue = Color(0xFF667eea); // Deep spiritual blue
  static const Color divinePurple = Color(0xFF764ba2); // Mystical purple
  static const Color celestialCyan = Color(0xFF4DD0E1); // Heavenly cyan

  // Sunrise Inspiration Palette (Enhanced)
  static const Color sunriseGold = Color(0xFFffeaa7); // Warm golden light
  static const Color hopeOrange = Color(0xFFfab1a0); // Dawn orange
  static const Color joyPink = Color(0xFFfd79a8); // Blissful pink
  static const Color miracleYellow = Color(0xFFfdcb6e); // Divine yellow

  // Midnight Prayer Palette (Enhanced)
  static const Color midnightBlue = Color(0xFF2d3436); // Deep contemplation
  static const Color wisdomNavy = Color(0xFF636e72); // Ancient wisdom
  static const Color mysticalPurple = Color(0xFF6c5ce7); // Spiritual insight
  static const Color starLight = Color(0xFF74b9ff); // Guiding star

  // Nature & Growth Palette
  static const Color faithGreen = Color(0xFF00b894); // Growing faith
  static const Color peaceGreen = Color(0xFF55efc4); // Peaceful nature
  static const Color graceWhite = Color(0xFFffffff); // Pure grace
  static const Color gentleGray = Color(0x000ffddd); // Soft neutrality

  // Legacy aliases for compatibility
  static const Color sunriseOrange = hopeOrange;
  static const Color sunriseNova = joyPink;
  static const Color healingBlue = celestialCyan;
  static const Color healingDark = faithGreen;
  static const Color midnightMid = wisdomNavy;
  static const Color midnightLight = starLight;

  static const Color pureWhite = graceWhite;
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color lightGray = gentleGray;

  // === SPIRITUAL GRADIENT COLLECTIONS ===

  // Morning Prayer Gradients
  static const List<Color> morningBlessing = [
    Color(0xFFffeaa7), // Soft golden light
    Color(0xFFfab1a0), // Warm dawn
    Color(0xFFfd79a8), // Gentle rose
  ];

  static const List<Color> sunriseGrace = [
    Color(0xFFfdcb6e), // Divine gold
    Color(0xFFe17055), // Sacred orange
    Color(0xFFd63031), // Holy fire
  ];

  // Healing Prayer Gradients
  static const List<Color> healingFlow = [
    Color(0xFF4ECDC4), // Healing teal
    Color(0xFF44a08d), // Deep healing
    Color(0xFF093637), // Restored wholeness
  ];

  static const List<Color> divineHealing = [
    Color(0xFF667eea), // Spiritual blue
    Color(0xFF764ba2), // Mystical purple
    Color(0xFF89CFF0), // Heavenly peace
  ];

  // Evening Prayer Gradients
  static const List<Color> eveningPeace = [
    Color(0xFF2d3436), // Deep contemplation
    Color(0xFF636e72), // Wisdom gray
    Color(0xFF74b9ff), // Star guidance
  ];

  static const List<Color> nightPrayer = [
    Color(0xFF6c5ce7), // Mystical purple
    Color(0xFFa29bfe), // Gentle lavender
    Color(0xFFfd79a8), // Loving pink
  ];

  // Crisis Support Gradients
  static const List<Color> urgentCare = [
    Color(0xFFd63031), // Urgent red
    Color(0xFFe17055), // Compassionate orange
    Color(0xFFfdcb6e), // Hope yellow
  ];

  static const List<Color> comfortingSupport = [
    Color(0xFF74b9ff), // Calming blue
    Color(0xFF0984e3), // Trust blue
    Color(0xFF6c5ce7), // Peaceful purple
  ];

  // === DYNAMIC SPIRITUAL GRADIENTS ===

  /// Get time-based spiritual gradient that changes throughout the day
  static List<Color> getTimeBasedGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      // Morning Prayer - Dawn colors
      return morningBlessing;
    } else if (hour >= 12 && hour < 17) {
      // Midday Prayer - Healing colors
      return healingFlow;
    } else if (hour >= 17 && hour < 21) {
      // Evening Prayer - Sunset colors
      return sunriseGrace;
    } else {
      // Night Prayer - Deep contemplation
      return eveningPeace;
    }
  }

  /// Get spiritual context gradient
  static List<Color> getSpiritualContextGradient(String context) {
    switch (context.toLowerCase()) {
      case 'morning':
      case 'dawn':
        return morningBlessing;
      case 'healing':
      case 'recovery':
        return divineHealing;
      case 'peace':
      case 'meditation':
        return healingFlow;
      case 'hope':
      case 'inspiration':
        return sunriseGrace;
      case 'crisis':
      case 'emergency':
        return urgentCare;
      case 'support':
      case 'comfort':
        return comfortingSupport;
      case 'evening':
      case 'night':
        return eveningPeace;
      default:
        return divineHealing;
    }
  }

  /// Get mood-based gradient
  static List<Color> getMoodGradient(double moodLevel) {
    if (moodLevel >= 8) return sunriseGrace; // Joyful
    if (moodLevel >= 6) return morningBlessing; // Hopeful
    if (moodLevel >= 4) return healingFlow; // Peaceful
    if (moodLevel >= 2) return comfortingSupport; // Struggling
    return urgentCare; // Crisis
  }

  // Mood-based colors (Enhanced)
  static const Color joyColor = sunriseGold;
  static const Color hopeColor = hopeOrange;
  static const Color peaceColor = healingTeal;
  static const Color struggleColor = starLight;
  static const Color crisisColor = joyPink;

  // Semantic colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // === SPIRITUAL GRADIENT CREATION HELPERS ===

  /// Create a spiritual LinearGradient from color list
  static LinearGradient createSpiritualGradient({
    required List<Color> colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin ?? Alignment.topLeft,
      end: end ?? Alignment.bottomRight,
      colors: colors,
      stops: stops,
    );
  }

  /// Create a radial spiritual glow effect
  static RadialGradient createSpiritualGlow({
    required List<Color> colors,
    Alignment? center,
    double? radius,
  }) {
    return RadialGradient(
      center: center ?? Alignment.center,
      radius: radius ?? 1.0,
      colors: colors.map((c) => c.withValues(alpha: 0.8)).toList() +
          [colors.last.withValues(alpha: 0.1)],
    );
  }

  /// Create glassmorphism effect with spiritual colors
  static BoxDecoration createSpiritualGlassmorphism({
    List<Color>? gradientColors,
    double opacity = 0.1,
    BorderRadius? borderRadius,
  }) {
    final colors = gradientColors ?? healingFlow;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: colors.map((c) => c.withValues(alpha: opacity)).toList(),
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: colors.first.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: colors.first.withValues(alpha: 0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Additional theme colors (Enhanced)
  static const Color lightBackground = offWhite;
  static const Color textPrimary = midnightBlue;
  static const Color textSecondary = starLight;
  static const Color calmBlue = celestialCyan;
  static const Color spiritualPurple = mysticalPurple;
  static const Color wisdomGold = sunriseGold;

  // Theme color aliases for compatibility
  static const Color primary = healingTeal;
  static const Color primaryColor = healingTeal;
  static const Color surface = pureWhite;
  static const Color successColor = success;
  static const Color warningColor = warning;
  static const Color errorColor = error;

  /// Get color based on mood level (1-10)
  static Color getMoodColor(int moodLevel) {
    if (moodLevel <= 2) return crisisColor;
    if (moodLevel <= 4) return struggleColor;
    if (moodLevel <= 6) return peaceColor;
    if (moodLevel <= 8) return hopeColor;
    return joyColor;
  }

  // Static text styles for compatibility
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: midnightBlue,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: midnightBlue,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: midnightBlue,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: midnightBlue,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'NunitoSans',
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: midnightLight,
    height: 1.4,
  );

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Smooth theme transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: healingTeal,
        onPrimary: pureWhite,
        primaryContainer: Color(0xFFE0F7F6),
        onPrimaryContainer: Color(0xFF002020),
        secondary: sunriseGold,
        onSecondary: midnightBlue,
        secondaryContainer: Color(0xFFFFF8DC),
        onSecondaryContainer: Color(0xFF1A1A00),
        tertiary: midnightBlue,
        onTertiary: pureWhite,
        tertiaryContainer: Color(0xFFD6E3F0),
        onTertiaryContainer: Color(0xFF0F1419),
        error: error,
        onError: pureWhite,
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: pureWhite,
        onSurface: midnightBlue,
        surfaceContainerHighest: offWhite,
        onSurfaceVariant: midnightLight,
        outline: lightGray,
        shadow: Color(0xFF000000),
        inversePrimary: Color(0xFF4DD0E1),
        inverseSurface: Color(0xFF2D3135),
        onInverseSurface: Color(0xFFE1E3E6),
      ),

      // Typography
      textTheme: _buildTextTheme(Brightness.light),

      // App Bar Theme - Enhanced for better visibility
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: pureWhite.withValues(alpha: 0.9),
        foregroundColor: midnightBlue,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: midnightBlue,
        ),
        iconTheme: const IconThemeData(
          color: midnightBlue,
        ),
        actionsIconTheme: const IconThemeData(
          color: midnightBlue,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        color: pureWhite,
        shadowColor: midnightBlue.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: healingTeal,
          foregroundColor: pureWhite,
          elevation: 4,
          shadowColor: healingTeal.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: healingTeal,
          side: const BorderSide(color: healingTeal, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: midnightBlue,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: healingTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: midnightLight,
          fontSize: 16,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: pureWhite,
        selectedItemColor: healingTeal,
        unselectedItemColor: midnightLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: sunriseGold,
        foregroundColor: midnightBlue,
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: healingTeal,
        linearTrackColor: lightGray,
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: healingTeal,
        inactiveTrackColor: lightGray,
        thumbColor: sunriseGold,
        overlayColor: sunriseGold.withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Smooth theme transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5EDCD4),
        onPrimary: Color(0xFF002020),
        primaryContainer: Color(0xFF003C3A),
        onPrimaryContainer: Color(0xFF7DF3EB),
        secondary: Color(0xFFFFE55C),
        onSecondary: Color(0xFF1A1A00),
        secondaryContainer: Color(0xFF2A2600),
        onSecondaryContainer: Color(0xFFFFF1C4),
        tertiary: Color(0xFF4A90E2),
        onTertiary: Color(0xFF0F1419),
        tertiaryContainer: Color(0xFF1E3A52),
        onTertiaryContainer: Color(0xFFB8D4F0),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: Color(0xFF1A1A1A),
        onSurface: Color(0xFFE1E3E6),
        surfaceContainerHighest: Color(0xFF2D2D2D),
        onSurfaceVariant: Color(0xFFB0B0B0),
        outline: Color(0xFF808080),
        shadow: Color(0xFF000000),
        inversePrimary: healingTeal,
        inverseSurface: Color(0xFFE1E3E6),
        onInverseSurface: Color(0xFF2D3135),
      ),

      // Typography
      textTheme: _buildTextTheme(Brightness.dark),

      // App Bar Theme - Enhanced for better visibility
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        foregroundColor: const Color(0xFFE1E3E6),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E3E6),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFE1E3E6),
        ),
        actionsIconTheme: const IconThemeData(
          color: Color(0xFFE1E3E6),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        color: const Color(0xFF2D2D2D),
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5EDCD4),
          foregroundColor: const Color(0xFF002020),
          elevation: 4,
          shadowColor: const Color(0xFF5EDCD4).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF5EDCD4),
          side: const BorderSide(color: Color(0xFF5EDCD4), width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFE1E3E6),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5EDCD4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: Color(0xFFB0B0B0),
          fontSize: 16,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Color(0xFF5EDCD4),
        unselectedItemColor: Color(0xFFB0B0B0),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFE55C),
        foregroundColor: Color(0xFF1A1A00),
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF5EDCD4),
        linearTrackColor: Color(0xFF808080),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: const Color(0xFF5EDCD4),
        inactiveTrackColor: const Color(0xFF808080),
        thumbColor: const Color(0xFFFFE55C),
        overlayColor: const Color(0xFFFFE55C).withValues(alpha: 0.2),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
    );
  }

  /// Build text theme for the specified brightness
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor =
        brightness == Brightness.light ? midnightBlue : const Color(0xFFE1E3E6);

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.1,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.2,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        height: 1.2,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.3,
      ),

      // Title styles
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),

      // Body styles
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: baseColor.withValues(alpha: 0.7),
        height: 1.4,
      ),

      // Label styles
      labelLarge: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontFamily: 'NunitoSans',
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: baseColor.withValues(alpha: 0.7),
        height: 1.4,
      ),
    );
  }

  /// Enhanced spiritual gradients using new color system
  static LinearGradient get morningGradient => createSpiritualGradient(
        colors: morningBlessing,
      );

  static LinearGradient get middayGradient => createSpiritualGradient(
        colors: healingFlow,
      );

  static LinearGradient get eveningGradient => createSpiritualGradient(
        colors: eveningPeace,
      );

  /// Enhanced healing glow with spiritual resonance
  static RadialGradient get healingGlow => createSpiritualGlow(
        colors: divineHealing,
      );

  /// Dynamic gradient based on current time
  static LinearGradient get timeBasedGradient => createSpiritualGradient(
        colors: getTimeBasedGradient(),
      );

  /// Spiritual blessing gradient for special moments
  static LinearGradient get blessingGradient => createSpiritualGradient(
        colors: [sacredBlue, divinePurple, celestialCyan],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  /// Crisis support gradient for emergency situations
  static LinearGradient get emergencyGradient => createSpiritualGradient(
        colors: urgentCare,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );
}

/// App-specific color extensions
class AppColors {
  AppColors._();

  // Alias for easier access
  static const Color primary = AppTheme.healingTeal;
  static const Color secondary = AppTheme.sunriseGold;
  static const Color accent = AppTheme.midnightBlue;
  static const Color backgroundLight = AppTheme.offWhite;
  static const Color backgroundDark = Color(0xFF1A1A1A);

  // Prayer category colors
  static const Color hopeCategory = AppTheme.sunriseGold;
  static const Color strengthCategory = AppTheme.healingTeal;
  static const Color peaceCategory = AppTheme.midnightBlue;
  static const Color gratitudeCategory = AppTheme.sunriseNova;
}
