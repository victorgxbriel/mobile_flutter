import 'package:flutter/foundation.dart';
import '../../data/models/agendamento_model.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

class AgendamentosNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  AgendamentosNotifier(this._repository);

  AgendamentosState _state = const AgendamentosInitial();
  AgendamentosState get state => _state;

  CancelAgendamentoState _cancelState = const CancelAgendamentoInitial();
  CancelAgendamentoState get cancelState => _cancelState;

  List<AgendamentoModel> _agendamentos = [];
  List<AgendamentoModel> get agendamentos => _agendamentos;

  // Agendamentos agrupados por situação
  List<AgendamentoModel> get agendamentosAgendados =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.agendado).toList();

  List<AgendamentoModel> get agendamentosConfirmados =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.confirmado).toList();

  List<AgendamentoModel> get agendamentosEmAndamento =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.emAndamento).toList();

  List<AgendamentoModel> get agendamentosConcluidos =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.concluido).toList();

  List<AgendamentoModel> get agendamentosCancelados =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.cancelado).toList();

  List<AgendamentoModel> get agendamentosAtivos => _agendamentos
      .where((a) =>
          a.situacao != AgendamentoSituacao.concluido &&
          a.situacao != AgendamentoSituacao.cancelado)
      .toList();

  Future<void> loadAgendamentos(int clienteId) async {
    _state = const AgendamentosLoading();
    notifyListeners();

    try {
      _agendamentos = await _repository.getAgendamentosByClienteId(clienteId);
      // Ordenar por data de criação, mais recentes primeiro
      _agendamentos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _state = AgendamentosLoaded(_agendamentos);
    } catch (e) {
      _state = AgendamentosError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> cancelarAgendamento(int id, int clienteId) async {
    _cancelState = const CancelAgendamentoLoading();
    notifyListeners();

    try {
      await _repository.cancelarAgendamento(id);
      _cancelState = const CancelAgendamentoSuccess();
      // Recarregar a lista após cancelamento
      await loadAgendamentos(clienteId);
    } catch (e) {
      _cancelState = CancelAgendamentoError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void resetCancelState() {
    _cancelState = const CancelAgendamentoInitial();
    notifyListeners();
  }

  void reset() {
    _state = const AgendamentosInitial();
    _cancelState = const CancelAgendamentoInitial();
    _agendamentos = [];
    notifyListeners();
  }
}
