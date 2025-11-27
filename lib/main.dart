import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/theme/colors.dart';
import 'app/router/app_router.dart';
import 'app/theme/app_theme.dart';
import 'core/di/service_locator.dart';

void main() {
  // Inicializar dependências
  ServiceLocator().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lava Jato App',
      //theme: AppTheme.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightBlue)
      ),
      routerConfig: appRouter,
    );
  }
}
