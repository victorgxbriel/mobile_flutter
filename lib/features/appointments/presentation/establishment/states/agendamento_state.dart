import 'package:mobile_flutter/features/appointments/data/models/agendamento_model.dart';

sealed class AgendamentosState {
  const AgendamentosState();
}

final class AgendamentosInitial extends AgendamentosState {
  const AgendamentosInitial();
}

final class AgendamentosLoading extends AgendamentosState {
  const AgendamentosLoading();
}

final class AgendamentosLoaded extends AgendamentosState {
  final List<AgendamentoModel> agendamentos;

  const AgendamentosLoaded(this.agendamentos);
}

final class AgendamentosError extends AgendamentosState {
  final Object error;

  const AgendamentosError(this.error);
}

// Estado de detalhes do agendamento
sealed class AgendamentoDetailsState {
  const AgendamentoDetailsState();
}

final class AgendamentoDetailsInitial extends AgendamentoDetailsState {
  const AgendamentoDetailsInitial();
}

final class AgendamentoDetailsLoading extends AgendamentoDetailsState {
  const AgendamentoDetailsLoading();
}

final class AgendamentoDetailsLoaded extends AgendamentoDetailsState {
  final AgendamentoModel agendamento;

  const AgendamentoDetailsLoaded(this.agendamento);
}

final class AgendamentoDetailsError extends AgendamentoDetailsState {
  final String message;

  const AgendamentoDetailsError(this.message);
}

// Estado do check-in
sealed class CheckInAgendamentoState {
  const CheckInAgendamentoState();
}

final class CheckInAgendamentoInitial extends CheckInAgendamentoState {
  const CheckInAgendamentoInitial();
}

final class CheckInAgendamentoLoading extends CheckInAgendamentoState {
  const CheckInAgendamentoLoading();
}

final class CheckInAgendamentoSuccess extends CheckInAgendamentoState {
  const CheckInAgendamentoSuccess();
}

final class CheckInAgendamentoError extends CheckInAgendamentoState {
  final String message;

  const CheckInAgendamentoError(this.message);
}
