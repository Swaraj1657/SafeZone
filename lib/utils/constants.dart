import 'package:flutter/material.dart';

/// App-wide color definitions
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFC50048); // Deep magenta/pink
  static const Color secondary = Color(0xFF140014); // Dark purple/burgundy

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFFFCCD5); // Light pink

  // Alert Colors
  static const Color safeZone = Color(0xFFFFD700); // Yellow
  static const Color danger = Colors.red;

  // UI Colors
  static const Color cardBackground = Color(0xFF1A001A);
  static const Color divider = Color(0xFF2A002A);
}

/// App-wide text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
}

/// App-wide spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
