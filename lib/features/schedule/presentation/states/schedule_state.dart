import 'package:mobile_flutter/features/schedule/data/models/programacao_diaria_model.dart';

/// Estados do calendário de programação
sealed class ScheduleState {}

/// Estado inicial
class ScheduleInitial extends ScheduleState {}

/// Carregando programações
class ScheduleLoading extends ScheduleState {}

/// Programações carregadas com sucesso
class ScheduleLoaded extends ScheduleState {
  final Map<DateTime, List<ProgramacaoDiaria>> programacoesPorData;
  final DateTime? selectedDate;
  final ProgramacaoDiaria? selectedProgramacao;

  ScheduleLoaded({
    required this.programacoesPorData,
    this.selectedDate,
    this.selectedProgramacao,
  });
}

/// Erro ao carregar programações
class ScheduleError extends ScheduleState {
  final String message;

  ScheduleError(this.message);
}

/// Criando nova programação
class ScheduleCreating extends ScheduleState {}

/// Programação criada com sucesso
class ScheduleCreated extends ScheduleState {
  final ProgramacaoDiaria programacao;

  ScheduleCreated(this.programacao);
}
