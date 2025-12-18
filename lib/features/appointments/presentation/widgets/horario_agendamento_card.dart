import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';

class HorarioAgendamentoCard extends StatelessWidget {
  final AgendamentoModel agendamento;
  final ColorScheme colorScheme;

  const HorarioAgendamentoCard({
    super.key,
    required this.agendamento,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
