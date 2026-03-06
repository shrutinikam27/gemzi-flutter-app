import 'package:flutter/material.dart';

class AppColors {
  static const Color midnight = Color(0xFF1A1A2E);
  static const Color champagne = Color(0xFFE6C27A);
  static const Color deepNavy = Color(0xFF16213E);
  static const Color glassWhite = Color(0x1AFFFFFF);
}

ThemeData luxuryTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.champagne,
  scaffoldBackgroundColor: AppColors.midnight,
  fontFamily: 'Georgia', // Elegant serif font
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.champagne,
      foregroundColor: AppColors.midnight,
      shape: StadiumBorder(),
    ),
  ),
);
