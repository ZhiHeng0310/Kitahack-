import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Scheme - Green & White
  static const Color primaryGreen = Color(0xFF2D6A4F);
  static const Color lightGreen = Color(0xFF52B788);
  static const Color accentGreen = Color(0xFF74C69D);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color darkGray = Color(0xFF495057);
  static const Color errorRed = Color(0xFFDC3545);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color successGreen = Color(0xFF40916C);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGreen,
        surface: backgroundWhite,
        background: lightGray,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkGray,
        onBackground: darkGray,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: lightGray,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: backgroundWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }
}

class AppConstants {
  // App Info
  static const String appName = 'EcoSnap';
  static const String appVersion = '1.0.0';
  
  // Feature Toggles
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = false;
  
  // ML Model Settings
  static const String modelFileName = 'waste_classifier.tflite';
  static const String labelsFileName = 'labels.txt';
  static const int imageSize = 224;
  static const double confidenceThreshold = 0.6;
  
  // Recycling Centers (Static Data for Malaysia)
  static const List<Map<String, dynamic>> recyclingCenters = [
    {
      'name': 'KL Recycling Hub',
      'address': 'Jalan Raja Laut, 50350 Kuala Lumpur',
      'phone': '+603-2698-xxxx',
      'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal', 'E-waste'],
    },
    {
      'name': 'Community E-waste Point',
      'address': 'KLCC, Kuala Lumpur City Centre',
      'phone': '+603-2382-xxxx',
      'acceptedItems': ['E-waste', 'Batteries'],
    },
    {
      'name': 'Alam Flora Recycling Centre',
      'address': 'Taman Tun Dr Ismail, 60000 Kuala Lumpur',
      'phone': '+603-7784-xxxx',
      'acceptedItems': ['Paper', 'Plastic', 'Glass', 'Metal'],
    },
  ];
  
  // Reuse Categories
  static const Map<String, List<Map<String, dynamic>>> reuseIdeas = {
    'Glass Bottle': [
      {
        'title': 'Plant Pot',
        'difficulty': 'Easy',
        'description': 'Transform into a beautiful indoor planter',
        'estimatedValue': {'min': 8, 'max': 15},
      },
      {
        'title': 'Desk Organizer',
        'difficulty': 'Medium',
        'description': 'Store pens, brushes, or utensils',
        'estimatedValue': {'min': 10, 'max': 20},
      },
      {
        'title': 'Decorative Lamp',
        'difficulty': 'Hard',
        'description': 'Create a unique lighting fixture',
        'estimatedValue': {'min': 25, 'max': 50},
      },
    ],
    'Plastic Container': [
      {
        'title': 'Storage Box',
        'difficulty': 'Easy',
        'description': 'Organize small items efficiently',
        'estimatedValue': {'min': 5, 'max': 10},
      },
      {
        'title': 'Seed Starter',
        'difficulty': 'Easy',
        'description': 'Perfect for growing seedlings',
        'estimatedValue': {'min': 3, 'max': 8},
      },
    ],
    'Cardboard Box': [
      {
        'title': 'Pet House',
        'difficulty': 'Medium',
        'description': 'Cozy shelter for cats or small pets',
        'estimatedValue': {'min': 15, 'max': 30},
      },
      {
        'title': 'Storage Organizer',
        'difficulty': 'Easy',
        'description': 'Divide and organize drawers',
        'estimatedValue': {'min': 5, 'max': 12},
      },
    ],
    'Tin Can': [
      {
        'title': 'Pencil Holder',
        'difficulty': 'Easy',
        'description': 'Wrap with fabric or paint decoratively',
        'estimatedValue': {'min': 8, 'max': 15},
      },
      {
        'title': 'Herb Planter',
        'difficulty': 'Easy',
        'description': 'Grow kitchen herbs',
        'estimatedValue': {'min': 10, 'max': 18},
      },
    ],
  };
}
