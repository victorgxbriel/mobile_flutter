import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../data/models/agendamento_model.dart';
import '../../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

final _log = logger(AgendamentosNotifier);

class AgendamentosNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  AgendamentosNotifier(this._repository);

  AgendamentosState _state = const AgendamentosInitial();
  AgendamentosState get state => _state;

  List<AgendamentoModel> _agendamentos = [];
  List<AgendamentoModel> get agendamentos => _agendamentos;

  /// Data selecionada para filtrar os agendamentos
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  /// Normaliza a data removendo horas/minutos/segundos
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Agendamentos filtrados pela data selecionada
  List<AgendamentoModel> get agendamentosFiltrados {
    final dataNormalizada = _normalizeDate(_selectedDate);
    return _agendamentos.where((a) {
      // Buscar a data do slot/programação
      final slotData = a.slot?.programacao?.dataAsDateTime;
      if (slotData == null) return false;

      final slotDataNormalizada = _normalizeDate(slotData);
      return slotDataNormalizada == dataNormalizada;
    }).toList();
  }

  /// Muda para o dia anterior
  void previousDay() {
    _log.d('Navegando para dia anterior');
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  /// Muda para o próximo dia
  void nextDay() {
    _log.d('Navegando para próximo dia');
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  /// Volta para a data de hoje
  void goToToday() {
    _log.d('Voltando para hoje');
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  /// Seleciona uma data específica
  void setDate(DateTime date) {
    _log.d('Data selecionada: ${date.toString().split(' ')[0]}');
    _selectedDate = date;
    notifyListeners();
  }

  // Agendamentos agrupados por situação
  List<AgendamentoModel> get agendamentosAgendados => _agendamentos
      .where((a) => a.situacao == AgendamentoSituacao.agendado)
      .toList();

  List<AgendamentoModel> get agendamentosAtrasados => _agendamentos
      .where((a) => a.situacao == AgendamentoSituacao.atrasado)
      .toList();

  List<AgendamentoModel> get agendamentosIniciado => _agendamentos
      .where((a) => a.situacao == AgendamentoSituacao.iniciado)
      .toList();

  List<AgendamentoModel> get agendamentosCancelados => _agendamentos
      .where((a) => a.situacao == AgendamentoSituacao.cancelado)
      .toList();

  List<AgendamentoModel> get agendamentosAtivos => _agendamentos
      .where((a) => a.situacao != AgendamentoSituacao.cancelado)
      .toList();

  Future<void> loadAgendamentos() async {
    _log.i('Carregando agendamentos');
    _state = const AgendamentosLoading();
    notifyListeners();

    try {
      _agendamentos = await _repository.getAgendamentosByEstabelecimento();
      // Ordenar por data de criação, mais recentes primeiro
      _agendamentos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _log.d('${_agendamentos.length} agendamentos carregados');
      _log.t(
        'Ativos: ${agendamentosAtivos.length}, Cancelados: ${agendamentosCancelados.length}',
      );
      _log.t(
        'Filtrados para ${_selectedDate.toString().split(' ')[0]}: ${agendamentosFiltrados.length}',
      );
      _state = AgendamentosLoaded(agendamentosFiltrados);
    } catch (e) {
      _log.e('Erro ao carregar agendamentos', error: e);
      _state = AgendamentosError(e);
    }

    notifyListeners();
  }

  void reset() {
    _log.t('Reset do estado de agendamentos');
    _state = const AgendamentosInitial();
    _agendamentos = [];
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
