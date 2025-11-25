import 'package:flutter/material.dart';

class AppColors {
  // Paleta de cores do app
  static const darkBlue = Color(0xFF004697);    // Azul escuro - primary
  static const mediumBlue = Color(0xFF008ED5);  // Azul médio - secondary
  static const lightBlue = Color(0xFF43C8E6);   // Azul claro - tertiary
  static const background = Color(0xFFF0F2F5);  // Cinza claro - background

  static final lightColorScheme = ColorScheme.light(
    primary: darkBlue,              // Cor principal (botões, appbar, etc)
    onPrimary: Colors.white,        // Texto sobre primary
    primaryContainer: mediumBlue,   // Variação mais clara do primary
    onPrimaryContainer: Colors.white,
    
    secondary: mediumBlue,          // Cor secundária
    onSecondary: Colors.white,      // Texto sobre secondary
    secondaryContainer: lightBlue,  // Variação mais clara do secondary
    onSecondaryContainer: darkBlue,
    
    tertiary: lightBlue,            // Cor terciária (destaques, links)
    onTertiary: darkBlue,           // Texto sobre tertiary
    
    surface: Colors.white,          // Superfícies (cards, dialogs)
    onSurface: Colors.black87,      // Texto sobre surface
    
    background: background,         // Fundo da tela
    onBackground: Colors.black87,   // Texto sobre background
    
    error: Colors.red.shade700,     // Cor de erro
    onError: Colors.white,          // Texto sobre error
  );
}
