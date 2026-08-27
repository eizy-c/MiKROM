import 'package:flutter/material.dart';

/// Corporate and strict palette for MiKROM Network Manager.
/// Strictly no emojis. Professional, sober, router-dashboard aesthetics.
class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color scaffoldBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color divider = Color(0xFFE2E8F0);
  
  // Brand & Accents
  static const Color primary = Color(0xFFD32F2F); // Mercusys Red
  static const Color primaryLight = Color(0xFFFFEBEE);
  static const Color primaryDark = Color(0xFFB71C1C);
  
  static const Color secondary = Color(0xFF0284C7); // Network Blue (Sky 600)
  static const Color secondaryLight = Color(0xFFE0F2FE);
  
  static const Color darkSlate = Color(0xFF0F172A); // Slate 900
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Status Colors
  static const Color statusSuccess = Color(0xFF16A34A); // Green 600
  static const Color statusSuccessBg = Color(0xFFDCFCE7); // Green 100
  static const Color statusWarning = Color(0xFFD97706); // Amber 600
  static const Color statusWarningBg = Color(0xFFFEF3C7); // Amber 100
  static const Color statusDanger = Color(0xFFDC2626); // Red 600
  static const Color statusDangerBg = Color(0xFFFEE2E2); // Red 100
  static const Color statusNeutral = Color(0xFF64748B);
  static const Color statusNeutralBg = Color(0xFFF1F5F9);
}
