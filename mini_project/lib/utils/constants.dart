import 'package:flutter/material.dart';

/// App Constants and Theme Configurations
/// Contains colors, typography, genres, pricing, and themes for Movie Explorer.
class AppConstants {
  // App Information
  static const String appName = 'Movie Explorer';
  static const String appTagline = 'Your Ultimate Cinema Hub';

  // Primary Palette (Cinematic Dark Red Aesthetic)
  static const Color primaryCrimson = Color(0xFFE50914);
  static const Color primaryDark = Color(0xFF0C0D14);
  static const Color surfaceDark = Color(0xFF161722);
  static const Color cardDark = Color(0xFF20212E);
  static const Color borderDark = Color(0xFF2C2D3E);
  static const Color textLight = Color(0xFFF1F1F5);
  static const Color textMuted = Color(0xFF9E9EA7);
  static const Color goldRating = Color(0xFFFFB800);
  static const Color successGreen = Color(0xFF10B981);

  // Seat Type Pricing
  static const Map<String, double> seatPrices = {
    'Regular': 180.0,
    'Premium': 280.0,
    'Recliner': 420.0,
  };

  // Add-on Prices
  static const double popcornComboPrice = 250.0;

  // Available Showtimes
  static const List<String> showtimes = [
    '10:00 AM (Morning Show)',
    '01:30 PM (Matinee)',
    '05:00 PM (Evening Show)',
    '09:00 PM (Night Prime)',
  ];

  // Movie Genres
  static const List<String> genres = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Horror',
    'Romance',
    'Thriller',
    'Animation',
  ];

  // Genre Details Helper (Icon and Gradient colors)
  static IconData getGenreIcon(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return Icons.sports_kabaddi_rounded;
      case 'comedy':
        return Icons.sentiment_very_satisfied_rounded;
      case 'drama':
        return Icons.theater_comedy_rounded;
      case 'sci-fi':
        return Icons.rocket_launch_rounded;
      case 'horror':
        return Icons.nightlight_round;
      case 'romance':
        return Icons.favorite_rounded;
      case 'thriller':
        return Icons.psychology_rounded;
      case 'animation':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.movie_rounded;
    }
  }

  static List<Color> getGenreGradient(String genre) {
    switch (genre.toLowerCase()) {
      case 'action':
        return [const Color(0xFFE50914), const Color(0xFF8B0000)];
      case 'comedy':
        return [const Color(0xFFFF8C00), const Color(0xFFD97706)];
      case 'drama':
        return [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)];
      case 'sci-fi':
        return [const Color(0xFF06B6D4), const Color(0xFF0284C7)];
      case 'horror':
        return [const Color(0xFFDC2626), const Color(0xFF1E1B4B)];
      case 'romance':
        return [const Color(0xFFEC4899), const Color(0xFFBE185D)];
      case 'thriller':
        return [const Color(0xFF10B981), const Color(0xFF047857)];
      case 'animation':
        return [const Color(0xFFF59E0B), const Color(0xFFEA580C)];
      default:
        return [const Color(0xFF4B5563), const Color(0xFF1F2937)];
    }
  }

  /// Dark Theme for Cinematic Feel
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCrimson,
        brightness: Brightness.dark,
        primary: primaryCrimson,
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: primaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textLight,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryCrimson,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCrimson, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }

  /// Light Theme option for Theme Switcher
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCrimson,
        brightness: Brightness.light,
        primary: primaryCrimson,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E1E24),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1E1E24)),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryCrimson,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCrimson,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCrimson, width: 2),
        ),
      ),
    );
  }
}
