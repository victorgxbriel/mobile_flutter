import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';
import 'package:mobile_flutter/features/appointments/presentation/establishment/notifiers/agendamentos_notifier.dart';
import 'package:mobile_flutter/features/appointments/presentation/establishment/states/agendamento_state.dart';
import 'package:mobile_flutter/features/appointments/presentation/utils/status_utils.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/data_widget.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile_flutter/widgets/error_view.dart';

class AgendamentosPage extends StatefulWidget {
  const AgendamentosPage({super.key});

  @override
  State<AgendamentosPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AgendamentosPage> {
  @override
  void initState() {
    super.initState();
    // Agendar o carregamento para após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgendamentos();
    });
  }

  void _loadAgendamentos() {
    context.read<AgendamentosNotifier>().loadAgendamentos();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<AgendamentosNotifier>(
      builder: (context, notifier, child) {
        return Scaffold(
          appBar: DataWidget(
            previousDay: () {
              notifier.previousDay();
            },
            nextDay: () {
              notifier.nextDay();
            },
            date: notifier.selectedDate,
            onTodayPressed: () {
              notifier.goToToday();
            },
            onCalendarPressed: () =>
                _showDatePickerBottomSheet(context, notifier),
          ),
          body: _buildBody(notifier, colorScheme),
        );
      },
    );
  }

  void _showDatePickerBottomSheet(
    BuildContext context,
    AgendamentosNotifier notifier,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text('Selecionar Data', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              CalendarDatePicker(
                initialDate: notifier.selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
                onDateChanged: (date) {
                  notifier.setDate(date);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AgendamentosNotifier notifier, ColorScheme colorScheme) {
    final state = notifier.state;

    // AnimatedSwitcher para animar a transição quando a data muda
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        // Slide horizontal + fade
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero)
              .animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _buildBodyContent(state, notifier, colorScheme),
    );
  }

  Widget _buildBodyContent(
    AgendamentosState state,
    AgendamentosNotifier notifier,
    ColorScheme colorScheme,
  ) {
    // Key única baseada na data para forçar a animação
    final key = ValueKey(notifier.selectedDate.toString().split(' ')[0]);

    return switch (state) {
      AgendamentosInitial() || AgendamentosLoading() => _buildSkeletonList(),
      AgendamentosError(error: final err) => ErrorView(
        key: key,
        error: err,
        onRetry: _loadAgendamentos,
      ),
      AgendamentosLoaded() =>
        notifier.agendamentosFiltrados.isEmpty
            ? _buildEmptyState(colorScheme, notifier.selectedDate, key)
            : _buildAgendamentosList(
                notifier.agendamentosFiltrados,
                colorScheme,
                key,
              ),
    };
  }

  Widget _buildEmptyState(
    ColorScheme colorScheme,
    DateTime selectedDate,
    Key key,
  ) {
    final dateFormatted = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum agendamento',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há agendamentos para $dateFormatted.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendamentosList(
    List<AgendamentoModel> agendamentos,
    ColorScheme colorScheme,
    Key key,
  ) {
    return RefreshIndicator(
      key: key,
      onRefresh: () async => _loadAgendamentos(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: agendamentos.length,
        itemBuilder: (context, index) {
          final agendamento = agendamentos[index];
          return _buildAgendamentoCard(agendamento, colorScheme);
        },
      ),
    );
  }

  Widget _buildAgendamentoCard(
    AgendamentoModel agendamento,
    ColorScheme colorScheme,
  ) {
    final statusColor = getStatusColor(agendamento.situacaoId, colorScheme);
    final statusIcon = getStatusIcon(agendamento.situacaoId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          // Navega para detalhes e aguarda resultado (true = check-in/cancelamento realizado)
          final result = await context.push<bool>(
            '/establishment/agendamentos/${agendamento.id}',
          );
          if (result == true && mounted) {
            _loadAgendamentos();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(statusIcon, color: statusColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Agendamento #${agendamento.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            agendamento.situacaoLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    'Criado em ${DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(agendamento.createdAt)}',
                    style: TextStyle(color: colorScheme.outline, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    agendamento.carro != null
                        ? '${agendamento.carro!.nomeCompleto} - ${agendamento.carro!.placa ?? 'Sem placa'}'
                        : 'Veículo ID: ${agendamento.carroId}',
                    style: TextStyle(color: colorScheme.outline, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    agendamento.slot != null
                        ? 'Horário: ${agendamento.slot!.horarioFormatado}'
                        : 'Slot #${agendamento.slotId}',
                    style: TextStyle(color: colorScheme.outline, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Skeleton loading usando mock data - layout sempre sincronizado
  Widget _buildSkeletonList() {
    final colorScheme = Theme.of(context).colorScheme;
    final mockList = List.generate(4, (_) => AgendamentoModel.skeleton());

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockList.length,
        itemBuilder: (context, index) =>
            _buildAgendamentoCard(mockList[index], colorScheme),
      ),
    );
  }
}
