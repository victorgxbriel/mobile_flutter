import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightBlue,
      brightness: Brightness.light,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightBlue,
      brightness: Brightness.dark,
    ),
  );
}
