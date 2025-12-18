import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/session_service.dart';
import '../../core/di/service_locator.dart';
import 'routes/auth_routes.dart';
import 'routes/client_routes.dart';
import 'routes/establishment_routes.dart';

// Chave de navegação raiz
final _rootNavigatorKey = GlobalKey<NavigatorState>();

SessionService get _sessionService => ServiceLocator().sessionService;

/// Redirect global para verificar autenticação e proteção de rotas
String? _globalRedirect(context, state) {
  final isAuthenticated = _sessionService.isAuthenticated;
  final isAuthRoute =
      state.matchedLocation == '/login' ||
      state.matchedLocation == '/register' ||
      state.matchedLocation == '/forgot-password' ||
      state.matchedLocation == '/reset-password';
  final isRootRoute = state.matchedLocation == '/';

  // Se está na rota raiz, redireciona para o home correto ou login
  if (isRootRoute) {
    if (!isAuthenticated) return '/login';
    return _sessionService.isEstabelecimento ? '/establishment/home' : '/home';
  }

  // Se não está autenticado e não está em rota de auth, redireciona para login
  if (!isAuthenticated && !isAuthRoute) return '/login';

  // Se está autenticado e está em rota de auth, redireciona para home
  if (isAuthenticated && isAuthRoute) {
    return _sessionService.isEstabelecimento ? '/establishment/home' : '/home';
  }

  // Proteção de Rota Cruzada (Segurança)
  if (isAuthenticated &&
      state.matchedLocation.startsWith('/establishment') &&
      !_sessionService.isEstabelecimento) {
    return '/home';
  }

  if (isAuthenticated &&
      !state.matchedLocation.startsWith('/establishment') &&
      _sessionService.isEstabelecimento) {
    return '/establishment/home';
  }

  return null; // Sem redirecionamento
}

/// Router principal da aplicação
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/",
  redirect: _globalRedirect,
  refreshListenable: _sessionService,
  routes: [
    // Rotas de autenticação
    ...getAuthRoutes(),

    // Rotas full-screen do cliente (fora do shell)
    ...getClientFullScreenRoutes(_rootNavigatorKey),

    // Shell do cliente (com bottom navigation)
    getClientShellRoute(),

    // Shell do estabelecimento (com bottom navigation)
    getEstablishmentShellRoute(),
  ],
);
