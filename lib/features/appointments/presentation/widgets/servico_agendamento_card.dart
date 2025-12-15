
import 'package:flutter/material.dart';
import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';

class ServicoAgendamentoCard extends StatelessWidget {
  final AgendamentoModel agendamento;
  final ColorScheme colorScheme;

  const ServicoAgendamentoCard({
    required this.agendamento,
    required this.colorScheme
  });
  
  @override
  Widget build(BuildContext context) {
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
                Text( 'Serviços',
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
                  child: Text( '${servicos.length}',
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
                  child: Text( 'Nenhum serviço encontrado',
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
}