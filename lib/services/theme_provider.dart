import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerenciador de tema do aplicativo
class ThemeProvider extends ChangeNotifier {
  static const _key = 'is_dark_mode';
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  /// Inicializa o provider carregando a preferência salva
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  /// Alterna entre tema claro e escuro
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isDarkMode);
  }
}
