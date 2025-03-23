import 'package:flutter/material.dart';

/// App color scheme
class AppColors {
  static const primary = Color(0xFF6B4EFF);
  static const secondary = Color(0xFF8C79FF);
  static const background = Color(0xFFF5F5F5);
  static const text = Color(0xFF1A1A1A);
  static const error = Color(0xFFFF4D4D);
  static const success = Color(0xFF4CAF50);
  static const textPrimary = Color(0xFF1A1A1A); // Near black
  static const textSecondary = Color(0xFF666666); // Dark gray
  static const cardBackground = Colors.white;
  static const safeZone = Color(0xFFFFD700); // Yellow for safe zones
}

/// App text styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

/// App spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}
