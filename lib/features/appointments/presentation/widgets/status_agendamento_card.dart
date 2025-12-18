import 'package:flutter/material.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';
import 'package:mobile_flutter/features/appointments/presentation/utils/status_utils.dart';

class StatusAgendamentoCard extends StatelessWidget {
  final AgendamentoModel agendamento;
  final ColorScheme colorScheme;

  const StatusAgendamentoCard({
    super.key,
    required this.agendamento,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = getStatusColor(agendamento.situacaoId, colorScheme);
    final statusIcon = getStatusIcon(agendamento.situacaoId);

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
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
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
}
