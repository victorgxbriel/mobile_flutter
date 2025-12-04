import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightBlue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Ícones escuros no tema claro
        statusBarBrightness: Brightness.light,
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightBlue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Ícones claros no tema escuro
        statusBarBrightness: Brightness.dark,
      ),
    ),
  );
}
