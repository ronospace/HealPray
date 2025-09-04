import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// HealPray design system and theming
class AppTheme {
  AppTheme._();

  // Brand Colors (from style guide)
  static const Color sunriseGold = Color(0xFFFFD700);
  static const Color sunriseOrange = Color(0xFFFFA500);
  static const Color sunriseNova = Color(0xFFFF6B6B);

  static const Color healingTeal = Color(0xFF4ECDC4);
  static const Color healingBlue = Color(0xFF45B7B8);
  static const Color healingDark = Color(0xFF3D9970);

  static const Color midnightBlue = Color(0xFF2C3E50);
  static const Color midnightMid = Color(0xFF34495E);
  static const Color midnightLight = Color(0xFF5D6D7E);

  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFE9ECEF);

  // Mood-based colors
  static const Color joyColor = sunriseGold;
  static const Color hopeColor = sunriseOrange;
  static const Color peaceColor = healingTeal;
  static const Color struggleColor = midnightBlue;
  static const Color crisisColor = sunriseNova;

  // Semantic colors
  static const Color success = Color(0xFF28A745);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC3545);
  static const Color info = Color(0xFF17A2B8);

  // Additional theme colors
  static const Color lightBackground = offWhite;
  static const Color textPrimary = midnightBlue;
  static const Color textSecondary = midnightLight;
  static const Color calmBlue = healingBlue;
  static const Color spiritualPurple = Color(0xFF7B68EE);
  static const Color wisdomGold = sunriseGold;

  /// Get color based on mood level (1-10)
  static Color getMoodColor(int moodLevel) {
    if (moodLevel <= 2) return crisisColor;
    if (moodLevel <= 4) return struggleColor;
    if (moodLevel <= 6) return peaceColor;
    if (moodLevel <= 8) return hopeColor;
    return joyColor;
  }

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
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
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: midnightBlue,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: midnightBlue,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        color: pureWhite,
        shadowColor: midnightBlue.withOpacity(0.1),
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
          shadowColor: healingTeal.withOpacity(0.3),
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
        overlayColor: sunriseGold.withOpacity(0.2),
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
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE1E3E6),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE1E3E6),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 8,
        color: const Color(0xFF2D2D2D),
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Similar button and input themes adapted for dark mode...
    );
  }

  /// Build text theme for the specified brightness
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light 
        ? midnightBlue 
        : const Color(0xFFE1E3E6);
    
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
        color: baseColor.withOpacity(0.7),
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
        color: baseColor.withOpacity(0.7),
        height: 1.4,
      ),
    );
  }

  /// Gradient for morning prayers
  static const LinearGradient morningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunriseGold, sunriseOrange, sunriseNova],
  );

  /// Gradient for midday prayers
  static const LinearGradient middayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [healingTeal, healingBlue, healingDark],
  );

  /// Gradient for evening prayers
  static const LinearGradient eveningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [midnightBlue, midnightMid, midnightLight],
  );

  /// Healing glow effect
  static RadialGradient get healingGlow => RadialGradient(
    center: Alignment.center,
    colors: [
      pureWhite.withOpacity(0.3),
      sunriseGold.withOpacity(0.1),
      healingTeal.withOpacity(0.05),
    ],
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
