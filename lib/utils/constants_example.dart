import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color income = Colors.green;
  static const Color expense = Colors.red;
  static const Color profit = Colors.blue;
  static const Color balance = Colors.orange;
  static const Color agriculture = Colors.brown;
  static const Color forex = Colors.indigo;
}

class AppConstants {
  static const String appName = 'NUMBERS';
  static const String appDescription =
      'Smart Record-Keeping and Financial Analytics';

  // Currency
  static const String currencySymbol = '\$';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Replace with your actual Gemini API key
  static String get geminiApiKey => 'YOUR_GEMINI_API_KEY_HERE';
}
