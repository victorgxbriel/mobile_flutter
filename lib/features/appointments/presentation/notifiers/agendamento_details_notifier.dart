import 'package:flutter/foundation.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

class AgendamentoDetailsNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  AgendamentoDetailsNotifier(this._repository);

  AgendamentoDetailsState _state = const AgendamentoDetailsInitial();
  AgendamentoDetailsState get state => _state;

  CancelAgendamentoState _cancelState = const CancelAgendamentoInitial();
  CancelAgendamentoState get cancelState => _cancelState;

  Future<void> loadAgendamento(int id) async {
    _state = const AgendamentoDetailsLoading();
    notifyListeners();

    try {
      final agendamento = await _repository.getAgendamentoByIdFull(id);
      _state = AgendamentoDetailsLoaded(agendamento);
    } catch (e) {
      _state = AgendamentoDetailsError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> cancelarAgendamento(int id) async {
    _cancelState = const CancelAgendamentoLoading();
    notifyListeners();

    try {
      await _repository.cancelarAgendamento(id);
      _cancelState = const CancelAgendamentoSuccess();
      // Recarregar o agendamento para atualizar o status
      await loadAgendamento(id);
    } catch (e) {
      _cancelState = CancelAgendamentoError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void resetCancelState() {
    _cancelState = const CancelAgendamentoInitial();
    notifyListeners();
  }
}
