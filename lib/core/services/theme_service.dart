import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para persistir a preferência de tema do usuário
class ThemeService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  /// Salva a preferência de tema
  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }

  /// Carrega a preferência de tema salva
  ThemeMode loadThemeMode() {
    final savedTheme = _prefs.getString(_themeKey);
    
    if (savedTheme == null) {
      return ThemeMode.system; // Padrão: seguir sistema
    }

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
  }
}
