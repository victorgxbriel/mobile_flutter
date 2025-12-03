import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';
import 'core/di/service_locator.dart';
import 'features/settings/presentation/notifiers/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar dependências
  await ServiceLocator().init();
  if (!kIsWeb) {
  // Isso força a inicialização do path_provider
  final tempDir = await getTemporaryDirectory();
  print('Diretório temporário: ${tempDir.path}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator.instance;
    
    return ChangeNotifierProvider<ThemeNotifier>.value(
      value: serviceLocator.themeNotifier,
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp.router(
            title: 'Lava Jato App',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeNotifier.themeMode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
