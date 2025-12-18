import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../features/appointments/presentation/client/notifiers/agendamentos_notifier.dart';
import '../../../features/appointments/presentation/client/notifiers/agendamento_details_notifier.dart';
import '../../../features/appointments/presentation/client/notifiers/create_agendamento_notifier.dart';
import '../../../features/appointments/presentation/client/pages/appointments_page.dart';
import '../../../features/appointments/presentation/client/pages/agendamento_details_page.dart';
import '../../../features/appointments/presentation/client/pages/create_agendamento_page.dart';
import '../../../features/estabelecimento/data/models/servico_model.dart';
import '../../../features/estabelecimento/presentation/notifiers/estabelecimento_details_notifier.dart';
import '../../../features/estabelecimento/presentation/pages/estabelecimento_details_page.dart';
import '../../../features/home/presentation/client/pages/home_shell.dart';
import '../../../features/home/presentation/client/pages/dashboard_page.dart';
import '../../../features/notifications/presentation/pages/notifications_page.dart';
import '../../../features/profile/presentation/client/pages/profile_page.dart';
import '../../../features/vehicles/presentation/notifiers/vehicles_notifier.dart';
import '../../../features/vehicles/presentation/notifiers/nhtsa_notifier.dart';
import '../../../features/vehicles/presentation/pages/vehicles_page.dart';
import '../../../features/vehicles/presentation/pages/vehicle_form_page.dart';
import '../../../features/vehicles/presentation/pages/vehicle_edit_page.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';

/// Rotas que ficam fora do shell (tela completa)
List<RouteBase> getClientFullScreenRoutes(
  GlobalKey<NavigatorState> rootNavigatorKey,
) {
  return [
    // Detalhes do estabelecimento
    GoRoute(
      path: "/estabelecimento/:id",
      parentNavigatorKey: rootNavigatorKey,
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

    // Criação de agendamento
    GoRoute(
      path: "/agendar/:estabelecimentoId",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final estabelecimentoId = int.parse(
          state.pathParameters['estabelecimentoId']!,
        );
        final extra = state.extra as Map<String, dynamic>?;
        final estabelecimentoNome =
            extra?['estabelecimentoNome'] as String? ?? '';
        final servicos = extra?['servicos'] as List<ServicoModel>? ?? [];
        final servicoPreSelecionadoId =
            extra?['servicoPreSelecionadoId'] as int?;

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) =>
                  VehiclesNotifier(ServiceLocator().vehicleRepository),
            ),
            ChangeNotifierProvider(
              create: (_) => CreateAgendamentoNotifier(
                ServiceLocator().agendamentoRepository,
              ),
            ),
          ],
          child: CreateAgendamentoPage(
            estabelecimentoId: estabelecimentoId,
            estabelecimentoNome: estabelecimentoNome,
            servicos: servicos,
            servicoPreSelecionadoId: servicoPreSelecionadoId,
          ),
        );
      },
    ),

    // Detalhes do agendamento
    GoRoute(
      path: "/agendamento/:id",
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ChangeNotifierProvider(
          create: (_) => AgendamentoDetailsNotifier(
            ServiceLocator().agendamentoRepository,
          ),
          child: AgendamentoDetailsPage(agendamentoId: id),
        );
      },
    ),

    // Rota Avulsa para Adicionar Veículo (Para ser chamada de dentro de outros fluxos)
    GoRoute(
      path: "/common/vehicle/add", // Um path genérico
      parentNavigatorKey: rootNavigatorKey, // Garante que abre por cima de tudo
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
  ];
}

/// Shell com bottom navigation (área autenticada do cliente)
StatefulShellRoute getClientShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        HomeShell(navigationShell: navigationShell),
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
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) =>
                  AgendamentosNotifier(ServiceLocator().agendamentoRepository),
              child: const AppointmentsPage(),
            ),
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
                  create: (_) =>
                      VehiclesNotifier(ServiceLocator().vehicleRepository),
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
                          create: (_) =>
                              NhtsaNotifier(ServiceLocator().nhtsaService),
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
                            create: (_) =>
                                NhtsaNotifier(ServiceLocator().nhtsaService),
                          ),
                        ],
                        child: VehicleEditPage(vehicleId: vehicleId),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: "settings",
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
