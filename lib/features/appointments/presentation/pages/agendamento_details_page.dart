import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/estabelecimento_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/horario_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/servico_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/status_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/total_agendamento_card.dart';
import 'package:mobile_flutter/features/appointments/presentation/widgets/veiculo_agendamento_card.dart';
import 'package:mobile_flutter/widgets/error_view.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/models/agendamento_model.dart';
import '../notifiers/agendamento_details_notifier.dart';
import '../states/agendamento_state.dart';

class AgendamentoDetailsPage extends StatefulWidget {
  final int agendamentoId;

  const AgendamentoDetailsPage({
    super.key,
    required this.agendamentoId,
  });

  @override
  State<AgendamentoDetailsPage> createState() => _AgendamentoDetailsPageState();
}

class _AgendamentoDetailsPageState extends State<AgendamentoDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAgendamento();
    });
  }

  void _loadAgendamento() {
    context.read<AgendamentoDetailsNotifier>().loadAgendamento(widget.agendamentoId);
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
      body: Consumer<AgendamentoDetailsNotifier>(
        builder: (context, notifier, child) {
          // Listener para cancelamento
          if (notifier.cancelState is CancelAgendamentoSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showSuccessMessage('Agendamento cancelado com sucesso');
              notifier.resetCancelState();
              // Voltar para a lista e sinalizar que houve cancelamento
              if (mounted) {
                context.pop(true);
              }
            });
          } else if (notifier.cancelState is CancelAgendamentoError) {
            final error = notifier.cancelState as CancelAgendamentoError;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorMessage(error.message);
              notifier.resetCancelState();
            });
          }

          final isLoading = notifier.state is AgendamentoDetailsInitial ||
              notifier.state is AgendamentoDetailsLoading;
          
          if (notifier.state is AgendamentoDetailsError) {
            final error = notifier.state as AgendamentoDetailsError;
            return ErrorView(
              error: error, 
              onRetry: _loadAgendamento
            );
            //return _buildErrorState(error.message, colorScheme);
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
    AgendamentoDetailsNotifier notifier,
    ColorScheme colorScheme,
  ) {
    final isCanceling = notifier.cancelState is CancelAgendamentoLoading;
    final canCancel = agendamento.situacaoId == 1 || agendamento.situacaoId == 2;

    return RefreshIndicator(
      onRefresh: () async => _loadAgendamento(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Status
            StatusAgendamentoCard(agendamento: agendamento,colorScheme: colorScheme,),
            const SizedBox(height: 16),

            // Card de Data e Horário
            HorarioAgendamentoCard(agendamento: agendamento, colorScheme: colorScheme,),
            const SizedBox(height: 16),

            // Card do Estabelecimento
            if (agendamento.slot?.programacao?.estabelecimento != null)
              EstabelecimentoAgendamentoCard(agendamento: agendamento, colorScheme: colorScheme,),
            if (agendamento.slot?.programacao?.estabelecimento != null)
              const SizedBox(height: 16),

            // Card do Veículo
            if (agendamento.carro != null)
              VeiculoAgendamentoCard(carro: agendamento.carro!,colorScheme: colorScheme,),
            if (agendamento.carro != null)
              const SizedBox(height: 16),

            // Card de Serviços
            ServicoAgendamentoCard(agendamento: agendamento, colorScheme: colorScheme,),
            const SizedBox(height: 16),

            // Card de Valor Total
            TotalAgendamentoCard(agendamento: agendamento, colorScheme: colorScheme,),
            const SizedBox(height: 24),

            // Botão de Cancelar
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isCanceling ? null : () => _showCancelDialog(agendamento.id, notifier),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.error,
                    side: BorderSide(color: colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: isCanceling
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.error,
                          ),
                        )
                      : const Icon(Icons.cancel_outlined),
                  label: Text(isCanceling ? 'Cancelando...' : 'Cancelar Agendamento'),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(int id, AgendamentoDetailsNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Cancelar Agendamento'),
        content: const Text( 'Tem certeza que deseja cancelar este agendamento? ' 'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              notifier.cancelarAgendamento(id);
            },
            child: const Text('Cancelar Agendamento'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Mock data para o skeleton loader
  AgendamentoModel get _mockAgendamento => AgendamentoModel.skeleton();
}
