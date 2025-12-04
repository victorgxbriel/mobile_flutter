import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_theme.dart';
import 'app/router/app_router.dart';
import 'app/utils/app_logger.dart';
import 'core/di/service_locator.dart';
import 'features/settings/presentation/notifiers/theme_notifier.dart';
import 'features/notifications/presentation/notifiers/notifications_notifier.dart';

final _log = logger(MyApp);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  _log.i('Iniciando aplicacao Lava Jato...');
  
  // Inicializar dependências
  await ServiceLocator().init();
  _log.i('ServiceLocator inicializado');
  
  if (!kIsWeb) {
    // Isso força a inicialização do path_provider
    final tempDir = await getTemporaryDirectory();
    _log.d('Diretorio temporario: ${tempDir.path}');
  }
  
  _log.i('Aplicacao pronta para execucao');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceLocator = ServiceLocator.instance;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>.value(
          value: serviceLocator.themeNotifier,
        ),
        ChangeNotifierProvider<NotificationsNotifier>(
          create: (_) => NotificationsNotifier(),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, child) {
          return MaterialApp.router(
            title: 'Lava Jato App',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeNotifier.themeMode,
            routerConfig: appRouter,
            builder: (context, child) {
              return SafeArea(
                top: false, // Mantém a barra de notificações
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}
