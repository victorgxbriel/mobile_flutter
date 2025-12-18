import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/features/treatments/presentation/notifiers/atendimentos_notifier.dart';
import 'package:mobile_flutter/features/treatments/presentation/pages/treatments_page.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../features/appointments/presentation/establishment/notifiers/agendamentos_notifier.dart';
import '../../../features/appointments/presentation/establishment/notifiers/agendamento_details_notifier.dart';
import '../../../features/appointments/presentation/establishment/pages/agendamentos_page.dart';
import '../../../features/appointments/presentation/establishment/pages/agendamento_details_page.dart';
import '../../../features/home/presentation/establishment/pages/home_establishment_page.dart';
import '../../../features/home/presentation/establishment/pages/home_establishment_shell.dart';
import '../../../features/profile/presentation/establishment/pages/profile_page.dart';
import '../../../features/services/data/models/servico_model.dart';
import '../../../features/services/presentation/notifiers/servicos_notifier.dart';
import '../../../features/services/presentation/pages/service_edit_page.dart';
import '../../../features/services/presentation/pages/service_form_page.dart';
import '../../../features/services/presentation/pages/services_page.dart';
import '../../../features/accessories/data/models/acessorio_model.dart';
import '../../../features/accessories/presentation/notifiers/acessorios_notifier.dart';
import '../../../features/accessories/presentation/pages/accessories_page.dart';
import '../../../features/accessories/presentation/pages/accessory_form_page.dart';
import '../../../features/accessories/presentation/pages/accessory_edit_page.dart';
import '../../../features/employees/data/models/employee_model.dart';
import '../../../features/employees/presentation/notifiers/employees_notifier.dart';
import '../../../features/employees/presentation/pages/employees_page.dart';
import '../../../features/employees/presentation/pages/employee_form_page.dart';
import '../../../features/employees/presentation/pages/employee_edit_page.dart';
import '../../../features/schedule/presentation/notifiers/schedule_notifier.dart';
import '../../../features/settings/presentation/pages/settings_page.dart';

/// Shell com bottom navigation (área autenticada do estabelecimento)
StatefulShellRoute getEstablishmentShellRoute() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) =>
        HomeEstablishmentShell(navigationShell: navigationShell),
    branches: [
      // Branch 0: Inicio/Dashboard
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: "/establishment/home",
            builder: (context, state) {
              final sl = ServiceLocator.instance;
              final estabelecimentoId = sl.sessionService.estabelecimentoId;

              // Se o estabelecimentoId ainda não está disponível, mostra loading
              if (estabelecimentoId == null) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              return HomeEstablishmentPage(
                notifier: ScheduleNotifier(
                  sl.programacaoDiariaRepository,
                  estabelecimentoId,
                ),
              );
            },
          ),
        ],
      ),

      // Branch 1: Agendamentos
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: "/establishment/agendamentos",
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) =>
                  AgendamentosNotifier(ServiceLocator().agendamentoRepository),
              child: const AgendamentosPage(),
            ),
            routes: [
              GoRoute(
                path: ":id",
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return ChangeNotifierProvider(
                    create: (_) => EstablishmentAgendamentoDetailsNotifier(
                      ServiceLocator().agendamentoRepository,
                    ),
                    child: EstablishmentAgendamentoDetailsPage(
                      agendamentoId: id,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Branch ADD (novo atendimento)
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: "/establishment/atendimento",
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text("novo atendimento"))),
          ),
        ],
      ),

      // Branch 2: Atendimentos
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: "/establishment/atendimentos",
            builder: (context, state) => ChangeNotifierProvider(
              create: (_) =>
                  AtendimentosNotifier(ServiceLocator().atendimentoRepository),
              child: const TreatmentsPage(),
            ),
          ),
        ],
      ),

      // Branch 3: Perfil
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: "/establishment/profile",
            builder: (context, state) => const ProfileEstablismentPage(),
            routes: [
              GoRoute(
                path: "settings",
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: "servicos",
                builder: (context, state) {
                  final sl = ServiceLocator.instance;
                  return ServicesPage(
                    notifier: ServicosNotifier(
                      sl.servicoRepository,
                      sl.sessionService.estabelecimentoId!,
                      sl.sessionService,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: "add",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      return ServiceFormPage(
                        repository: sl.servicoRepository,
                        estabelecimentoId: sl.sessionService.estabelecimentoId!,
                      );
                    },
                  ),
                  GoRoute(
                    path: ":id/edit",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      final extra = state.extra as ServicoModel;
                      return ServiceEditPage(
                        servico: extra,
                        repository: sl.servicoRepository,
                        estabelecimentoId: sl.sessionService.estabelecimentoId!,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: "acessorios",
                builder: (context, state) {
                  final sl = ServiceLocator.instance;
                  return AccessoriesPage(
                    notifier: AcessoriosNotifier(
                      sl.acessorioRepository,
                      sl.sessionService.estabelecimentoId!,
                      sl.sessionService,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: "add",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      return AccessoryFormPage(
                        repository: sl.acessorioRepository,
                        estabelecimentoId: sl.sessionService.estabelecimentoId!,
                      );
                    },
                  ),
                  GoRoute(
                    path: ":id/edit",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      final extra = state.extra as AcessorioModel;
                      return AccessoryEditPage(
                        acessorio: extra,
                        repository: sl.acessorioRepository,
                        estabelecimentoId: sl.sessionService.estabelecimentoId!,
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: "employees",
                builder: (context, state) {
                  final sl = ServiceLocator.instance;
                  return EmployeesPage(
                    notifier: EmployeesNotifier(
                      sl.employeeRepository,
                      sl.sessionService,
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: "add",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      return EmployeeFormPage(
                        repository: sl.employeeRepository,
                        sessionService: sl.sessionService,
                      );
                    },
                  ),
                  GoRoute(
                    path: ":id/edit",
                    builder: (context, state) {
                      final sl = ServiceLocator.instance;
                      final extra = state.extra as EmployeeModel;
                      return EmployeeEditPage(
                        employee: extra,
                        repository: sl.employeeRepository,
                        sessionService: sl.sessionService,
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
  );
}
