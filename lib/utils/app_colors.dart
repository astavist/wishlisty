import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryDark = Color(0xFF357ABD);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFD93D);
  
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F4);
  
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGray = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE5E5E5);
  
  // Social buttons
  static const Color google = Color(0xFFDB4437);
  static const Color facebook = Color(0xFF4267B2);
  static const Color apple = Color(0xFF000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, Color(0xFFFF8E8E)],
  );
} 