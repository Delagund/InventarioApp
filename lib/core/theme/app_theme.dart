import 'package:flutter/material.dart';
import 'app_theme_extension.dart';
import '../constants/app_layout.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1E88E5); // Blue 600
  static const Color secondaryColor = Color(0xFF26A69A); // Teal 400

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.light,

      extensions: [
        AppThemeExtension(
          subtleBackground: const Color(0xFFF5F7FA),
          criticalStock: Colors.red.shade400,
          warningStock: Colors.orange.shade400,
          healthyStock: Colors.green.shade400,
          surfaceGradientStart: const Color(0xFFFFFFFF),
          surfaceGradientEnd: const Color(0xFFF0F2F5),
        ),
      ],

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusM),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        color: Colors.white,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.spaceL,
            vertical: AppLayout.spaceM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.radiusM),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusM),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.all(AppLayout.spaceM),
      ),

      dividerTheme: DividerThemeData(thickness: 1, color: Colors.grey.shade200),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: Brightness.dark,
      extensions: [
        AppThemeExtension(
          subtleBackground: const Color(0xFF1A1C1E),
          criticalStock: Colors.red.shade700,
          warningStock: Colors.orange.shade700,
          healthyStock: Colors.green.shade700,
          surfaceGradientStart: const Color(0xFF202124),
          surfaceGradientEnd: const Color(0xFF171717),
        ),
      ],
      // Estilos para dark mode se pueden pulir más adelante
    );
  }
}
