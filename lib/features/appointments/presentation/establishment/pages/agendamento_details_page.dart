import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/horario_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/servico_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/status_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/total_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/veiculo_agendamento_card.dart';
import 'package:mobile_flutter/widgets/error_view.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/models/agendamento_model.dart';
import '../notifiers/agendamento_details_notifier.dart';
import '../states/agendamento_state.dart';

class EstablishmentAgendamentoDetailsPage extends StatefulWidget {
  final int agendamentoId;

  const EstablishmentAgendamentoDetailsPage({
    super.key,
    required this.agendamentoId,
  });

  @override
  State<EstablishmentAgendamentoDetailsPage> createState() =>
      _EstablishmentAgendamentoDetailsPageState();
}

class _EstablishmentAgendamentoDetailsPageState
    extends State<EstablishmentAgendamentoDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgendamento();
    });
  }

  void _loadAgendamento() {
    context.read<EstablishmentAgendamentoDetailsNotifier>().loadAgendamento(
      widget.agendamentoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
        centerTitle: true,
      ),
      body: Consumer<EstablishmentAgendamentoDetailsNotifier>(
        builder: (context, notifier, child) {
          // Listener para check-in
          if (notifier.checkInState is CheckInAgendamentoSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSuccessMessage(
                'Check-in realizado com sucesso! Atendimento criado.',
              );
              notifier.resetCheckInState();
              // Voltar para a lista e sinalizar que houve check-in
              if (mounted) {
                context.pop(true);
              }
            });
          } else if (notifier.checkInState is CheckInAgendamentoError) {
            final error = notifier.checkInState as CheckInAgendamentoError;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorMessage(error.message);
              notifier.resetCheckInState();
            });
          }

          final isLoading =
              notifier.state is AgendamentoDetailsInitial ||
              notifier.state is AgendamentoDetailsLoading;

          if (notifier.state is AgendamentoDetailsError) {
            final error = notifier.state as AgendamentoDetailsError;
            return ErrorView(error: error.message, onRetry: _loadAgendamento);
          }

          // Usa dados reais se carregado, senão usa mock
          final agendamento = notifier.state is AgendamentoDetailsLoaded
              ? (notifier.state as AgendamentoDetailsLoaded).agendamento
              : _mockAgendamento;

          return Skeletonizer(
            enabled: isLoading,
            child: _buildContent(agendamento, notifier, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    AgendamentoModel agendamento,
    EstablishmentAgendamentoDetailsNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final isCheckingIn = notifier.checkInState is CheckInAgendamentoLoading;
    // Check-in disponível apenas para agendamentos com status "Agendado" (1) ou "Atrasado" (2)
    final canCheckIn =
        agendamento.situacaoId == 1 || agendamento.situacaoId == 2;

    return RefreshIndicator(
      onRefresh: () async => _loadAgendamento(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Status
            StatusAgendamentoCard(
              agendamento: agendamento,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Card de Data e Horário
            HorarioAgendamentoCard(
              agendamento: agendamento,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Card do Veículo
            if (agendamento.carro != null)
              VeiculoAgendamentoCard(
                carro: agendamento.carro!,
                colorScheme: colorScheme,
              ),
            if (agendamento.carro != null) const SizedBox(height: 16),

            // Card de Serviços
            ServicoAgendamentoCard(
              agendamento: agendamento,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 16),

            // Card de Valor Total
            TotalAgendamentoCard(
              agendamento: agendamento,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 24),

            // Botão de Check-in
            if (canCheckIn)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isCheckingIn
                      ? null
                      : () => _showCheckInDialog(agendamento.id, notifier),
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: isCheckingIn
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    isCheckingIn
                        ? 'Realizando check-in...'
                        : 'Realizar Check-in',
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCheckInDialog(
    int id,
    EstablishmentAgendamentoDetailsNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
        title: const Text('Realizar Check-in'),
        content: const Text(
          'Deseja confirmar a chegada do cliente e iniciar o atendimento? '
          'Um novo atendimento será criado automaticamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.checkIn(id);
            },
            child: const Text('Confirmar Check-in'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Mock data para o skeleton loader
  AgendamentoModel get _mockAgendamento => AgendamentoModel.skeleton();
}
