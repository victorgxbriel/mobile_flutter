import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/services/theme_service.dart';

final _log = logger(ThemeNotifier);

/// Notifier global para gerenciar o tema do app
class ThemeNotifier extends ChangeNotifier {
  final ThemeService _themeService;
  
  ThemeMode _themeMode = ThemeMode.system;

  ThemeNotifier(this._themeService) {
    _loadSavedTheme();
  }

  ThemeMode get themeMode => _themeMode;

  /// Verifica se o tema atual é escuro (considerando o sistema)
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Carrega o tema salvo nas preferências
  void _loadSavedTheme() {
    _themeMode = _themeService.loadThemeMode();
    _log.d('Tema carregado: ${themeModeName}');
    notifyListeners();
  }

  /// Altera o tema e persiste a escolha
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _log.i('Alterando tema para: ${_getModeName(mode)}');
    _themeMode = mode;
    await _themeService.saveThemeMode(mode);
    notifyListeners();
  }

  String _getModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light: return 'Claro';
      case ThemeMode.dark: return 'Escuro';
      case ThemeMode.system: return 'Sistema';
    }
  }

  /// Alterna entre light e dark (ignora system)
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Retorna o nome amigável do tema atual
  String get themeModeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  /// Retorna o ícone correspondente ao tema
  IconData get themeModeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }
}
