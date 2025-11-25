import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
// import '../../features/splash/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: "/login",
  routes: [
    /*
    GoRoute(
      path: "/splash",
      builder: (_, __) => const SplashPage(),
    ),
    */
    GoRoute(path: "/login", builder: (_, __) => const LoginPage()),
    GoRoute(path: "/register", builder: (_, __) => const RegisterPage()),
  ],
);
