import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

          return switch (notifier.state) {
            AgendamentoDetailsInitial() || AgendamentoDetailsLoading() => 
              const Center(child: CircularProgressIndicator()),
            AgendamentoDetailsError(message: final msg) => _buildErrorState(msg, colorScheme),
            AgendamentoDetailsLoaded(agendamento: final agendamento) => 
              _buildContent(agendamento, notifier, colorScheme),
          };
        },
      ),
    );
  }

  Widget _buildErrorState(String message, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadAgendamento,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
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
            _buildStatusCard(agendamento, colorScheme),
            const SizedBox(height: 16),

            // Card de Data e Horário
            _buildDateTimeCard(agendamento, colorScheme),
            const SizedBox(height: 16),

            // Card do Estabelecimento
            if (agendamento.slot?.programacao?.estabelecimento != null)
              _buildEstabelecimentoCard(agendamento, colorScheme),
            if (agendamento.slot?.programacao?.estabelecimento != null)
              const SizedBox(height: 16),

            // Card do Veículo
            if (agendamento.carro != null)
              _buildVeiculoCard(agendamento.carro!, colorScheme),
            if (agendamento.carro != null)
              const SizedBox(height: 16),

            // Card de Serviços
            _buildServicosCard(agendamento, colorScheme),
            const SizedBox(height: 16),

            // Card de Valor Total
            _buildTotalCard(agendamento, colorScheme),
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

  Widget _buildStatusCard(AgendamentoModel agendamento, ColorScheme colorScheme) {
    final statusColor = _getStatusColor(agendamento.situacaoId, colorScheme);
    final statusIcon = _getStatusIcon(agendamento.situacaoId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                statusIcon,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agendamento.situacaoLabel,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${agendamento.id}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeCard(AgendamentoModel agendamento, ColorScheme colorScheme) {
    final data = agendamento.slot?.programacao?.dataAsDateTime;
    final horario = agendamento.slot?.horarioFormatado;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Data e Horário',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.calendar_today,
                    label: 'Data',
                    value: data != null
                        ? DateFormat('dd/MM/yyyy').format(data)
                        : 'Não informada',
                    colorScheme: colorScheme,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    icon: Icons.access_time,
                    label: 'Horário',
                    value: horario ?? 'Não informado',
                    colorScheme: colorScheme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstabelecimentoCard(AgendamentoModel agendamento, ColorScheme colorScheme) {
    final estabelecimento = agendamento.slot?.programacao?.estabelecimento;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Estabelecimento',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_car_wash,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estabelecimento?.nomeFantasia ?? 'Estabelecimento',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (estabelecimento?.cnpj != null)
                        Text(
                          'CNPJ: ${estabelecimento!.cnpj}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeiculoCard(AgendamentoCarro carro, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Veículo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carro.nomeCompleto,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          if (carro.placa != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                carro.placa!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            carro.cor,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                          if (carro.ano != null) ...[
                            Text(
                              ' • ${carro.ano}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicosCard(AgendamentoModel agendamento, ColorScheme colorScheme) {
    final servicos = agendamento.servicos ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Serviços',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${servicos.length}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (servicos.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Nenhum serviço encontrado',
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ),
              )
            else
              ...servicos.map((servicoRelation) {
                final servico = servicoRelation.servico;
                if (servico == null) return const SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: colorScheme.onTertiaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servico.titulo,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            if (servico.descricao != null)
                              Text(
                                servico.descricao!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.outline,
                                ),
                              ),
                            if (servico.tempoEstimado != null && servico.tempoFormatado.isNotEmpty)
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 12,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    servico.tempoFormatado,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      Text(
                        servico.precoFormatado,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard(AgendamentoModel agendamento, ColorScheme colorScheme) {
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valor Total',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  agendamento.valorTotalFormatado,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.receipt_long,
                color: colorScheme.onPrimary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.outline),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.outline,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(int situacaoId, ColorScheme colorScheme) {
    switch (situacaoId) {
      case 1: // Agendado
        return Colors.blue;
      case 2: // Confirmado
        return Colors.green;
      case 3: // Em Andamento
        return Colors.orange;
      case 4: // Concluído
        return colorScheme.primary;
      case 5: // Cancelado
        return Colors.red;
      default:
        return colorScheme.outline;
    }
  }

  IconData _getStatusIcon(int situacaoId) {
    switch (situacaoId) {
      case 1: // Agendado
        return Icons.schedule;
      case 2: // Confirmado
        return Icons.check_circle;
      case 3: // Em Andamento
        return Icons.play_circle;
      case 4: // Concluído
        return Icons.verified;
      case 5: // Cancelado
        return Icons.cancel;
      default:
        return Icons.help;
    }
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
        content: const Text(
          'Tem certeza que deseja cancelar este agendamento? '
          'Esta ação não pode ser desfeita.',
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
}
