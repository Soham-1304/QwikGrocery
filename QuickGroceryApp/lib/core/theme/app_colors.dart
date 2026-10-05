import 'package:flutter/material.dart';

/// Semantic color palette for Blinkit-tier grocery experience.
class AppColors {
  const AppColors._();

  // Emerald Green primary brand colors
  static const Color emeraldPrimary = Color(0xFF0C831F);
  static const Color emeraldDark = Color(0xFF065A14);
  static const Color emeraldLight = Color(0xFFE8F5E9);
  static const Color emeraldContainer = Color(0xFFE8F5E9);

  // Warm Yellow / Amber accent colors
  static const Color warmYellow = Color(0xFFFFC72C);
  static const Color warmYellowDark = Color(0xFFE5A800);
  static const Color warmYellowLight = Color(0xFFFFF9C4);
  static const Color yellowContainer = Color(0xFFFFF8E1);

  // Surface and background shades
  static const Color background = Color(0xFFF7F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFF1F3F5);
  static const Color surfaceContainerHigh = Color(0xFFE9ECEF);

  // Neutral text & border colors
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textTertiary = Color(0xFF98A2B3);
  static const Color outline = Color(0xFFE4E7EC);
  static const Color outlineVariant = Color(0xFFF2F4F7);

  // Functional status & feedback colors
  static const Color discountPill = Color(0xFF0C831F);
  static const Color discountPillBackground = Color(0xFFE8F5E9);
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color error = Color(0xFFF04438);

  // Legacy aliases for backward compatibility with initial screens
  static const Color green = Color(0xFF2E6B45);
  static const Color yellow = Color(0xFFF2C84B);
  static const Color black = Color(0xFF171A17);
  static const Color muted = Color(0xFF5E6A61);
  static const Color paleGreen = Color(0xFFE9F1E9);
  static const Color paleYellow = Color(0xFFFFF4CF);
  static const Color oldGreen = Color(0xFF2E6B45);
  static const Color oldYellow = Color(0xFFF2C84B);
}
