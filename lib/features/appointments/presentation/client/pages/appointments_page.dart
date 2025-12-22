import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile_flutter/widgets/error_view.dart';

import '../../../data/models/agendamento_model.dart';
import '../notifiers/agendamentos_notifier.dart';
import '../states/agendamento_state.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
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

  Color _getStatusColor(AgendamentoSituacao situacao) {
    switch (situacao) {
      case AgendamentoSituacao.agendado:
        return Colors.blue;
      case AgendamentoSituacao.atrasado:
        return Colors.orange;
      case AgendamentoSituacao.iniciado:
        return Colors.green;
      case AgendamentoSituacao.cancelado:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(AgendamentoSituacao situacao) {
    switch (situacao) {
      case AgendamentoSituacao.agendado:
        return Icons.schedule;
      case AgendamentoSituacao.atrasado:
        return Icons.check_circle_outline;
      case AgendamentoSituacao.iniciado:
        return Icons.done_all;
      case AgendamentoSituacao.cancelado:
        return Icons.cancel_outlined;
    }
  }

  void _showCancelDialog(AgendamentoModel agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Agendamento'),
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Não'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAgendamento(agendamento.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim, cancelar'),
          ),
        ],
      ),
    );
  }

  void _cancelAgendamento(int id) {
    context.read<AgendamentosNotifier>().cancelarAgendamento(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAgendamentos,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<AgendamentosNotifier>(
        builder: (context, notifier, child) {
          final state = notifier.state;

          // Listener para cancelamento
          if (notifier.cancelState is CancelAgendamentoSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Agendamento cancelado com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
              notifier.resetCancelState();
            });
          } else if (notifier.cancelState is CancelAgendamentoError) {
            final error = notifier.cancelState as CancelAgendamentoError;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error.message),
                  backgroundColor: Colors.red,
                ),
              );
              notifier.resetCancelState();
            });
          }

          return switch (state) {
            AgendamentosInitial() ||
            AgendamentosLoading() => _buildSkeletonList(),
            AgendamentosError(error: final err) => ErrorView(
              error: err,
              onRetry: _loadAgendamentos,
            ),
            AgendamentosLoaded(agendamentos: final agendamentos) =>
              agendamentos.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : _buildAgendamentosList(agendamentos, colorScheme),
          };
        },
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
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
              'Você ainda não possui nenhum agendamento.\nQue tal agendar uma lavagem?',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.search),
              label: const Text('Buscar Estabelecimentos'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendamentosList(
    List<AgendamentoModel> agendamentos,
    ColorScheme colorScheme,
  ) {
    return RefreshIndicator(
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
    final statusColor = _getStatusColor(agendamento.situacao);
    final statusIcon = _getStatusIcon(agendamento.situacao);
    final canCancel =
        agendamento.situacao == AgendamentoSituacao.agendado ||
        agendamento.situacao == AgendamentoSituacao.atrasado;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          // Navega para detalhes e aguarda resultado (true = cancelamento realizado)
          final result = await context.push<bool>(
            '/agendamento/${agendamento.id}',
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
                  if (canCancel)
                    IconButton(
                      icon: Icon(
                        Icons.cancel_outlined,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _showCancelDialog(agendamento),
                      tooltip: 'Cancelar',
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: colorScheme.outline),
                  const SizedBox(width: 8),
                  Text(
                    'Criado em ${DateFormat('dd/MM/yyyy HH:mm').format(agendamento.createdAt)}',
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
