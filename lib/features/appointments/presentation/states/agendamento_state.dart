import '../../data/models/agendamento_model.dart';
import '../../data/models/slot_model.dart';

// Estado dos agendamentos do cliente
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
  final String message;

  const AgendamentosError(this.message);
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

// Estado da criação de agendamento
sealed class CreateAgendamentoState {
  const CreateAgendamentoState();
}

final class CreateAgendamentoInitial extends CreateAgendamentoState {
  const CreateAgendamentoInitial();
}

final class CreateAgendamentoLoading extends CreateAgendamentoState {
  const CreateAgendamentoLoading();
}

final class CreateAgendamentoSuccess extends CreateAgendamentoState {
  final AgendamentoModel agendamento;

  const CreateAgendamentoSuccess(this.agendamento);
}

final class CreateAgendamentoError extends CreateAgendamentoState {
  final String message;

  const CreateAgendamentoError(this.message);
}

// Estado dos slots disponíveis
sealed class SlotsState {
  const SlotsState();
}

final class SlotsInitial extends SlotsState {
  const SlotsInitial();
}

final class SlotsLoading extends SlotsState {
  const SlotsLoading();
}

final class SlotsLoaded extends SlotsState {
  final ProgramacaoDiariaModel? programacao;
  
  List<SlotTempoModel> get slotsDisponiveis => 
      (programacao?.slots ?? []).where((s) => s.isDisponivel).toList();

  const SlotsLoaded(this.programacao);
}

final class SlotsError extends SlotsState {
  final String message;

  const SlotsError(this.message);
}

// Estado do cancelamento
sealed class CancelAgendamentoState {
  const CancelAgendamentoState();
}

final class CancelAgendamentoInitial extends CancelAgendamentoState {
  const CancelAgendamentoInitial();
}

final class CancelAgendamentoLoading extends CancelAgendamentoState {
  const CancelAgendamentoLoading();
}

final class CancelAgendamentoSuccess extends CancelAgendamentoState {
  const CancelAgendamentoSuccess();
}

final class CancelAgendamentoError extends CancelAgendamentoState {
  final String message;

  const CancelAgendamentoError(this.message);
}

// Estado das programações diárias (datas disponíveis)
sealed class ProgramacoesState {
  const ProgramacoesState();
}

final class ProgramacoesInitial extends ProgramacoesState {
  const ProgramacoesInitial();
}

final class ProgramacoesLoading extends ProgramacoesState {
  const ProgramacoesLoading();
}

final class ProgramacoesLoaded extends ProgramacoesState {
  final List<ProgramacaoDiariaModel> programacoes;
  
  /// Retorna as datas que têm programação (apenas datas futuras ou de hoje)
  Set<DateTime> get datasDisponiveis {
    final hoje = DateTime.now();
    final hojeNormalizado = DateTime(hoje.year, hoje.month, hoje.day);
    
    return programacoes
        .map((p) => p.dataAsDateTime)
        .where((data) => !data.isBefore(hojeNormalizado))
        .map((data) => DateTime(data.year, data.month, data.day))
        .toSet();
  }

  const ProgramacoesLoaded(this.programacoes);
}

final class ProgramacoesError extends ProgramacoesState {
  final String message;

  const ProgramacoesError(this.message);
}
