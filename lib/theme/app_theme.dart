import 'package:flutter/material.dart';

/// Tema do aplicativo Pro Volei
class AppTheme {
  // Cores principais
  static const primaryBlue = Color(0xFF1E3A5F);
  static const primaryGold = Color(0xFFD4A03C);
  static const darkBackground = Color(0xFF0D1B2A);
  static const cardBackground = Color(0xFF1B2838);
  static const surfaceLight = Color(0xFF243B53);

  // Cores de time
  static const team1Color = Color(0xFF3D5A80);
  static const team2Color = Color(0xFFE8C468);

  // Cores de feedback
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);

  // Gradientes
  static const primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF3D5A80)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const goldGradient = LinearGradient(
    colors: [primaryGold, Color(0xFFE8C468)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [darkBackground, Color(0xFF1B2838)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Tema claro (não usado atualmente, mas preparado)
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  /// Tema escuro (principal)
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: isDark ? darkBackground : Colors.grey[100],

      // Esquema de cores
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primaryGold,
        onSecondary: Colors.black,
        error: error,
        onError: Colors.white,
        surface: isDark ? cardBackground : Colors.white,
        onSurface: isDark ? Colors.white : Colors.black87,
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackground : primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? cardBackground : Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Texto
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),

      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? surfaceLight : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
      ),
    );
  }
}
