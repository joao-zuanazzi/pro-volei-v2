import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';

/// Tema do aplicativo Pro Volei
class AppTheme {
  // Cores principais (fixas em ambos os temas)
  static const primaryBlue = Color(0xFF1E3A5F);
  static const primaryGold = Color(0xFFD4A03C);

  // Cores de time (fixas)
  static const team1Color = Color(0xFF3D5A80);
  static const team2Color = Color(0xFFE8C468);

  // Cores de feedback (fixas)
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFF9800);

  // --- Cores do tema ESCURO ---
  static const darkBackground = Color(0xFF0D1B2A);
  static const darkCardBackground = Color(0xFF1B2838);
  static const darkSurfaceLight = Color(0xFF243B53);

  // --- Cores do tema CLARO ---
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightCardBackground = Color(0xFFFAFBFC);
  static const lightSurfaceLight = Color(0xFFE8ECF1);

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

  static const lightGradient = LinearGradient(
    colors: [lightBackground, Color(0xFFEDF0F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Retorna as cores corretas baseado no tema atual.
  /// Seguro para uso tanto em build() quanto em event handlers.
  /// A reatividade é garantida pelo `Consumer<ThemeProvider>` no MaterialApp.
  static AppThemeColors of(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    return isDark ? AppThemeColors.dark() : AppThemeColors.light();
  }

  /// Alias para of() — mantido para compatibilidade
  static AppThemeColors read(BuildContext context) => of(context);

  /// Tema claro
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  /// Tema escuro (principal)
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: isDark ? darkBackground : lightBackground,

      // Esquema de cores
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryBlue,
        onPrimary: Colors.white,
        secondary: primaryGold,
        onSecondary: Colors.black,
        error: error,
        onError: Colors.white,
        surface: isDark ? darkCardBackground : lightCardBackground,
        onSurface: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkBackground : primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? darkCardBackground : lightCardBackground,
        elevation: isDark ? 4 : 2,
        shadowColor: isDark ? Colors.black26 : Colors.black12,
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
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : const Color(0xFF5A5A7A),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white70 : const Color(0xFF5A5A7A),
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),

      // Dropdown
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : const Color(0xFF1A1A2E),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkSurfaceLight : lightSurfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: isDark ? Colors.white38 : const Color(0xFF9A9AB0),
        ),
      ),
    );
  }
}

/// Cores contextuais que mudam entre tema claro e escuro
class AppThemeColors {
  final Color background;
  final Color card;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  final Color border;
  final Color dialogBackground;
  final Color cancelButton;
  final Color dropdownColor;
  final LinearGradient backgroundGradient;
  final bool isDark;

  const AppThemeColors._({
    required this.background,
    required this.card,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.border,
    required this.dialogBackground,
    required this.cancelButton,
    required this.dropdownColor,
    required this.backgroundGradient,
    required this.isDark,
  });

  factory AppThemeColors.dark() {
    return const AppThemeColors._(
      background: AppTheme.darkBackground,
      card: AppTheme.darkCardBackground,
      surface: AppTheme.darkSurfaceLight,
      text: Colors.white,
      textSecondary: Colors.white70,
      textTertiary: Colors.white54,
      textHint: Colors.white38,
      border: Colors.white24,
      dialogBackground: AppTheme.darkCardBackground,
      cancelButton: Colors.white70,
      dropdownColor: AppTheme.darkSurfaceLight,
      backgroundGradient: AppTheme.darkGradient,
      isDark: true,
    );
  }

  factory AppThemeColors.light() {
    return const AppThemeColors._(
      background: AppTheme.lightBackground,
      card: AppTheme.lightCardBackground,
      surface: AppTheme.lightSurfaceLight,
      text: Color(0xFF1A1A2E),
      textSecondary: Color(0xFF5A5A7A),
      textTertiary: Color(0xFF7A7A94),
      textHint: Color(0xFF9A9AB0),
      border: Color(0xFFE1E5EA),
      dialogBackground: Colors.white,
      cancelButton: Color(0xFF5A5A7A),
      dropdownColor: Color(0xFFE8ECF1),
      backgroundGradient: AppTheme.lightGradient,
      isDark: false,
    );
  }

  /// Logo asset path baseado no tema
  String get logoAsset => isDark ? 'assets/logo.png' : 'assets/logo_dark.png';
}
