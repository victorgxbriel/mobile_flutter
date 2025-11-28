import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';
import '../../features/home/presentation/pages/dashboard_page.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

// Chaves de navegação para cada branch
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: "/login",
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
              // Sub-rotas de perfil podem ser adicionadas aqui
              // routes: [
              //   GoRoute(
              //     path: "edit",
              //     builder: (context, state) => EditProfilePage(),
              //   ),
              //   GoRoute(
              //     path: "vehicles",
              //     builder: (context, state) => VehiclesPage(),
              //   ),
              // ],
            ),
          ],
        ),
      ],
    ),
  ],
);
