import 'package:flutter/material.dart';

Color getStatusColor(int situacaoId, ColorScheme colorScheme) {
  switch (situacaoId) {
    case 1: // Agendado
      return Colors.blue;
    case 2: // Confirmado
      return Colors.orange;
    case 3: // Em Andamento
      return Colors.green;
    case 4: // Cancelado
      return Colors.red;
    default:
      return colorScheme.outline;
  }
}

IconData getStatusIcon(int situacaoId) {
  switch (situacaoId) {
    case 1: // Agendado
      return Icons.schedule;
    case 2: // Confirmado
      return Icons.check_circle;
    case 3: // Concluído
      return Icons.verified;
    case 4: // Cancelado
      return Icons.cancel;
    default:
      return Icons.help;
  }
}