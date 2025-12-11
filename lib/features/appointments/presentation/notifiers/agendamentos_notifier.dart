import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../data/models/agendamento_model.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

final _log = logger(AgendamentosNotifier);

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

  List<AgendamentoModel> get agendamentosAtrasados =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.atrasado).toList();

  List<AgendamentoModel> get agendamentosIniciado =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.iniciado).toList();

  List<AgendamentoModel> get agendamentosCancelados =>
      _agendamentos.where((a) => a.situacao == AgendamentoSituacao.cancelado).toList();

  List<AgendamentoModel> get agendamentosAtivos => _agendamentos
      .where((a) =>
          a.situacao != AgendamentoSituacao.cancelado)
      .toList();

  Future<void> loadAgendamentos() async {
    _log.i('Carregando agendamentos');
    _state = const AgendamentosLoading();
    notifyListeners();

    try {
      _agendamentos = await _repository.getAgendamentos();
      // Ordenar por data de criação, mais recentes primeiro
      _agendamentos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _log.d('${_agendamentos.length} agendamentos carregados');
      _log.t('Ativos: ${agendamentosAtivos.length}, Cancelados: ${agendamentosCancelados.length}');
      _state = AgendamentosLoaded(_agendamentos);
    } catch (e) {
      _log.e('Erro ao carregar agendamentos', error: e);
      _state = AgendamentosError(e);
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
      // Recarregar a lista após cancelamento
      await loadAgendamentos();
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

  void reset() {
    _log.t('Reset do estado de agendamentos');
    _state = const AgendamentosInitial();
    _cancelState = const CancelAgendamentoInitial();
    _agendamentos = [];
    notifyListeners();
  }
}
