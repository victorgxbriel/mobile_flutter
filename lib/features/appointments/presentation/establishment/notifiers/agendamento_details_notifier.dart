import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

final _log = logger(EstablishmentAgendamentoDetailsNotifier);

class EstablishmentAgendamentoDetailsNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  EstablishmentAgendamentoDetailsNotifier(this._repository);

  AgendamentoDetailsState _state = const AgendamentoDetailsInitial();
  AgendamentoDetailsState get state => _state;

  CheckInAgendamentoState _checkInState = const CheckInAgendamentoInitial();
  CheckInAgendamentoState get checkInState => _checkInState;

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
      _state = AgendamentoDetailsError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  Future<void> checkIn(int id) async {
    _log.i('Realizando check-in do agendamento: $id');
    _checkInState = const CheckInAgendamentoLoading();
    notifyListeners();

    try {
      await _repository.checkInAgendamento(id);
      _log.i('Check-in realizado com sucesso');
      _checkInState = const CheckInAgendamentoSuccess();
      // Recarregar o agendamento para atualizar o status
      await loadAgendamento(id);
    } catch (e) {
      _log.e('Erro ao realizar check-in', error: e);
      _checkInState = CheckInAgendamentoError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  void resetCheckInState() {
    _checkInState = const CheckInAgendamentoInitial();
    notifyListeners();
  }
}
