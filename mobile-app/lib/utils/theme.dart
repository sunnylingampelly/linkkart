import 'package:flutter/material.dart';

// Temporary theme constants for backward compatibility
// These screens will be migrated to use app_theme.dart later
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF000000); // Black
  static const Color secondaryColor = Color(0xFFD4AF37); // Gold
  static const Color successColor = Color(0xFF2D5A27);
  static const Color errorColor = Color(0xFF8B0000);
  static const Color warningColor = Color(0xFFB8860B);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkText = Color(0xFF000000);
  static const Color lightText = Color(0xFF4A4A4A);
  
  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  
  // Border Radius (Sharp design)
  static const double radiusSmall = 0.0;
  static const double radiusMedium = 0.0;
  static const double radiusLarge = 0.0;
  
  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get secondaryGradient => const LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF9E29C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: darkText,
    height: 1.2,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkText,
    height: 1.3,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkText,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkText,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: lightText,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: lightText,
    height: 1.5,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
