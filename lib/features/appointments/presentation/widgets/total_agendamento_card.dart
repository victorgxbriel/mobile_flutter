
import 'package:flutter/material.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';

class TotalAgendamentoCard extends StatelessWidget {
  final AgendamentoModel agendamento;
  final ColorScheme colorScheme;

  const TotalAgendamentoCard({
    required this.agendamento,
    required this.colorScheme
  });
  
  @override
  Widget build(BuildContext context) {
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
                Text( 'Valor Total',
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
}