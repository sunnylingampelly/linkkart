import 'package:flutter/material.dart';

class AppColors {
  // Luxury Palette - Black & Gold
  static const Color primary = Color(0xFF000000); // Pure Black
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFF1A1A1A);
  
  // Luxury Accent - Gold
  static const Color secondary = Color(0xFFD4AF37); // Classic Gold
  static const Color secondaryDark = Color(0xFFB8860B);
  static const Color secondaryLight = Color(0xFFE5D5A4);
  
  // Accent Colors
  static const Color accent = Color(0xFFD4AF37); // Use Gold as main accent
  static const Color accentOrange = Color(0xFFB8860B); // Dark Goldenrod
  static const Color accentPurple = Color(0xFF2E1A47); // Deep Royal Purple
  
  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF); // Pure White Background
  static const Color surface = Color(0xFFFFFFFF);     // White Surface
  static const Color surfaceLight = Color(0xFFF8F8F8);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF4A4A4A); // Dark Grey
  static const Color textTertiary = Color(0xFF8E8E8E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);
  
  // Status Colors
  static const Color success = Color(0xFF2D5A27); // Deep Forest Green
  static const Color warning = Color(0xFFB8860B); // Golden Brown
  static const Color error = Color(0xFF8B0000);   // Deep Red
  static const Color info = Color(0xFF1A237E);    // Royal Blue
  
  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFF0F0F0);
  
  // Shadows
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF9E29C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
