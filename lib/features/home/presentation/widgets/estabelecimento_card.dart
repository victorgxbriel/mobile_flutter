import 'package:flutter/material.dart';

import '../../data/models/estabelecimento_models.dart';

class EstabelecimentoCard extends StatelessWidget {
  final EstabelecimentoModel estabelecimento;
  final VoidCallback? onTap;

  const EstabelecimentoCard({
    super.key,
    required this.estabelecimento,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Área da foto (placeholder por enquanto)
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Icon(
                  Icons.local_car_wash,
                  size: 64,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),
            // Informações do estabelecimento
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    estabelecimento.nomeFantasia,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          estabelecimento.cnpjFormatado,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Status ativo/inativo
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: estabelecimento.active
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      estabelecimento.active ? 'Aberto' : 'Fechado',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: estabelecimento.active
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
