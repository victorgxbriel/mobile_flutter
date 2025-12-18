import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

final _log = logger(AgendamentoDetailsNotifier);

class AgendamentoDetailsNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  AgendamentoDetailsNotifier(this._repository);

  AgendamentoDetailsState _state = const AgendamentoDetailsInitial();
  AgendamentoDetailsState get state => _state;

  CancelAgendamentoState _cancelState = const CancelAgendamentoInitial();
  CancelAgendamentoState get cancelState => _cancelState;

  Future<void> loadAgendamento(int id) async {
    _log.i('Carregando detalhes do agendamento: $id');
    _state = const AgendamentoDetailsLoading();
    notifyListeners();

    try {
      final agendamento = await _repository.getAgendamentoByIdFull(id);
      _log.d('Detalhes carregados - Situação: ${agendamento.situacao}');
      _state = AgendamentoDetailsLoaded(agendamento);
    } catch (e) {
      _log.e('Erro ao carregar detalhes', error: e);
      _state = AgendamentoDetailsError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> cancelarAgendamento(int id) async {
    _log.i('Cancelando agendamento: $id');
    _cancelState = const CancelAgendamentoLoading();
    notifyListeners();

    try {
      await _repository.cancelarAgendamento(id);
      _log.i('Agendamento cancelado com sucesso');
      _cancelState = const CancelAgendamentoSuccess();
      // Recarregar o agendamento para atualizar o status
      await loadAgendamento(id);
    } catch (e) {
      _log.e('Erro ao cancelar agendamento', error: e);
      _cancelState = CancelAgendamentoError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void resetCancelState() {
    _cancelState = const CancelAgendamentoInitial();
    notifyListeners();
  }
}
