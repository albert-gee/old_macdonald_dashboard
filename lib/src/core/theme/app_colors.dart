import 'package:flutter/material.dart';

/// Centralized color definitions for the dark theme.
class AppColors {
  // Base Backgrounds
  static const Color background = Color(0xFF181818);
  static const Color surface = Color(0xFF1E1E1E);

  // Theme Colors
  static const Color primary = Color(0xFF43A047);
  static const Color accent = Color(0xFF26C6DA);
  static const Color error = Color(0xFFEF5350);

  // Text Colors
  static const Color textPrimary = Color(0xFFECECEC);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Component Colors
  static const Color icon = textPrimary;
  static const Color inputFill = surface;
  static const Color buttonForeground = textPrimary;
  static const Color divider = Color(0x1AFFFFFF);
  static const Color disabled = Color(0xFF555555);
}
