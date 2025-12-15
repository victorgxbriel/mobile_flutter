
import 'package:flutter/material.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';

class EstabelecimentoAgendamentoCard extends StatelessWidget {
  final AgendamentoModel agendamento;
  final ColorScheme colorScheme;

  const EstabelecimentoAgendamentoCard({
    required this.agendamento,
    required this.colorScheme
  });
  
  @override
  Widget build(BuildContext context) {
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
                Text( 'Estabelecimento',
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
                        Text( 'CNPJ: ${estabelecimento!.cnpj}',
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
}