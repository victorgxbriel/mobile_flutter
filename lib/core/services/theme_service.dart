import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _log = logger(ThemeService);

/// Serviço para persistir a preferência de tema do usuário
class ThemeService {
  static const String _themeKey = 'theme_mode';

  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  /// Salva a preferência de tema
  Future<void> saveThemeMode(ThemeMode mode) async {
    _log.d('Salvando tema: ${mode.name}');
    await _prefs.setString(_themeKey, mode.name);
  }

  /// Carrega a preferência de tema salva
  ThemeMode loadThemeMode() {
    final savedTheme = _prefs.getString(_themeKey);
    
    if (savedTheme == null) {
      _log.t('Nenhum tema salvo, usando System');
      return ThemeMode.system;
    }

    final mode = ThemeMode.values.firstWhere(
      (mode) => mode.name == savedTheme,
      orElse: () => ThemeMode.system,
    );
    _log.t('Tema carregado: ${mode.name}');
    return mode;
  }
}
