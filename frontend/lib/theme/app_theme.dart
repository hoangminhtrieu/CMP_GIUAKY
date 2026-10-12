// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette (Prepwise Royal Blue from design)
  static const primary = Color(0xFF1668E8);       // Prepwise Blue
  static const primaryLight = Color(0xFFEAF2FF);  // Light badge blue
  static const primaryDark = Color(0xFF0E52CF);   // Deep Blue
  static const accent = Color(0xFF06B6D4);        // Cyan accent

  // Gradient stops
  static const gradientStart = Color(0xFF1668E8);
  static const gradientEnd = Color(0xFF0E52CF);   // Vibrant Blue gradient

  // Semantic colors
  static const success = Color(0xFF10B981);       // Emerald
  static const warning = Color(0xFFF59E0B);       // Amber
  static const danger = Color(0xFFEF4444);        // Red
  static const info = Color(0xFF3B82F6);          // Blue

  // Neutral
  static const bg = Color(0xFFF8FAFF);
  static const surface = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);
}

class AppGradients {
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.gradientEnd],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
}

class AppDecorations {
  static BoxDecoration cardDecoration({Color? borderColor}) => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration gradientCard({List<Color>? colors}) => BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [AppColors.gradientStart, AppColors.gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
