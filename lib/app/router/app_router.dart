import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/session_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/estabelecimento/presentation/notifiers/estabelecimento_details_notifier.dart';
import '../../features/estabelecimento/presentation/pages/estabelecimento_details_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/vehicles/presentation/notifiers/vehicles_notifier.dart';
import '../../features/vehicles/presentation/notifiers/nhtsa_notifier.dart';
import '../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_form_page.dart';
import '../../features/vehicles/presentation/pages/vehicle_edit_page.dart';

// Chaves de navegação para cada branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
//final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Getter para o SessionService
SessionService get _sessionService => ServiceLocator().sessionService;

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/login",
  
  // Redirect global para verificar autenticação
  redirect: (context, state) {
    final isAuthenticated = _sessionService.isAuthenticated;
    final isAuthRoute = state.matchedLocation == '/login' || 
                        state.matchedLocation == '/register' ||
                        state.matchedLocation == '/forgot-password' ||
                        state.matchedLocation == '/reset-password';

    // Se não está autenticado e não está em rota de auth, redireciona para login
    if (!isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // Se está autenticado e está em rota de auth, redireciona para home
    if (isAuthenticated && isAuthRoute) {
      return '/home';
    }

    return null; // Sem redirecionamento
  },
  
  // Escuta mudanças na sessão para atualizar rotas
  refreshListenable: ServiceLocator().sessionService,
  
  routes: [
    // Rotas de autenticação (fora do shell)
    GoRoute(
      path: "/login",
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: "/register",
      builder: (_, __) => const RegisterPage(),
    ),
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
    
    // Detalhes do estabelecimento (fora do shell para tela completa)
    GoRoute(
      path: "/estabelecimento/:id",
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ChangeNotifierProvider(
          create: (_) => EstabelecimentoDetailsNotifier(
            ServiceLocator().estabelecimentoDetailsRepository,
          ),
          child: EstabelecimentoDetailsPage(estabelecimentoId: id),
        );
      },
    ),
    
    // Shell com bottom navigation (área autenticada)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => HomeShell(
        navigationShell: navigationShell,
      ),
      branches: [
        // Branch 0: Início/Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/home",
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        
        // Branch 1: Agendamentos
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/appointments",
              builder: (context, state) => AppointmentsPage(),
              // Sub-rotas de agendamentos podem ser adicionadas aqui
              // routes: [
              //   GoRoute(
              //     path: "new",
              //     builder: (context, state) => NewAppointmentPage(),
              //   ),
              //   GoRoute(
              //     path: ":id",
              //     builder: (context, state) => AppointmentDetailsPage(id: state.pathParameters['id']!),
              //   ),
              // ],
            ),
          ],
        ),
        
        // Branch 2: Notificações
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/notifications",
              builder: (context, state) => const NotificationsPage(),
            ),
          ],
        ),
        
        // Branch 3: Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: "/profile",
              builder: (context, state) => const ProfilePage(),
              routes: [
                GoRoute(
                  path: "vehicles",
                  builder: (context, state) => ChangeNotifierProvider(
                    create: (_) => VehiclesNotifier(
                      ServiceLocator().vehicleRepository,
                    ),
                    child: const VehiclesPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: "add",
                      builder: (context, state) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                            create: (_) => VehiclesNotifier(
                              ServiceLocator().vehicleRepository,
                            ),
                          ),
                          ChangeNotifierProvider(
                            create: (_) => NhtsaNotifier(
                              ServiceLocator().nhtsaService,
                            ),
                          ),
                        ],
                        child: const VehicleFormPage(),
                      ),
                    ),
                    GoRoute(
                      path: ":id/edit",
                      builder: (context, state) {
                        final vehicleId = int.parse(state.pathParameters['id']!);
                        return MultiProvider(
                          providers: [
                            ChangeNotifierProvider(
                              create: (_) => VehiclesNotifier(
                                ServiceLocator().vehicleRepository,
                              ),
                            ),
                            ChangeNotifierProvider(
                              create: (_) => NhtsaNotifier(
                                ServiceLocator().nhtsaService,
                              ),
                            ),
                          ],
                          child: VehicleEditPage(vehicleId: vehicleId),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
