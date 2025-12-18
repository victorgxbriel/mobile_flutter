import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/auth/presentation/pages/register_page.dart';
import '../../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../../features/auth/presentation/pages/reset_password_page.dart';

/// Rotas de autenticação (fora do shell)
List<RouteBase> getAuthRoutes() {
  return [
    GoRoute(path: "/login", builder: (_, __) => const LoginPage()),
    GoRoute(path: "/register", builder: (_, __) => const RegisterPage()),
    GoRoute(
      path: "/forgot-password",
      builder: (_, __) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: "/reset-password",
      builder: (_, state) {
        final email = state.extra as String?;
        return ResetPasswordPage(email: email);
      },
    ),
  ];
}
