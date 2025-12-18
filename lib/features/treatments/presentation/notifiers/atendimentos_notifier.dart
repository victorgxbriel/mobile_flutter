import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../data/models/atendimento_model.dart';
import '../../data/repositories/atendimento_repository.dart';
import '../states/atendimentos_state.dart';

final _log = logger(AtendimentosNotifier);

class AtendimentosNotifier extends ChangeNotifier {
  final AtendimentoRepository _repository;

  AtendimentosNotifier(this._repository);

  AtendimentosState _state = const AtendimentosInitial();
  AtendimentosState get state => _state;

  List<AtendimentoModel> _atendimentos = [];
  List<AtendimentoModel> get atendimentos => _atendimentos;

  /// Data selecionada para filtrar os atendimentos
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  /// Normaliza a data removendo horas/minutos/segundos
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Atendimentos filtrados pela data selecionada
  List<AtendimentoModel> get atendimentosFiltrados {
    final dataNormalizada = _normalizeDate(_selectedDate);
    return _atendimentos.where((a) {
      // Usar a data do atendimento (horaInicio ou createdAt)
      final atendimentoData = a.dataAtendimento;
      final atendimentoDataNormalizada = _normalizeDate(atendimentoData);
      return atendimentoDataNormalizada == dataNormalizada;
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

  // Atendimentos agrupados por situação
  List<AtendimentoModel> get atendimentosAguardando => _atendimentos
      .where((a) => a.situacaoEnum == AtendimentoSituacao.aguardando)
      .toList();

  List<AtendimentoModel> get atendimentosEmAndamento => _atendimentos
      .where((a) => a.situacaoEnum == AtendimentoSituacao.emAndamento)
      .toList();

  List<AtendimentoModel> get atendimentosConcluidos => _atendimentos
      .where((a) => a.situacaoEnum == AtendimentoSituacao.concluido)
      .toList();

  List<AtendimentoModel> get atendimentosCancelados => _atendimentos
      .where((a) => a.situacaoEnum == AtendimentoSituacao.cancelado)
      .toList();

  List<AtendimentoModel> get atendimentosAtivos => _atendimentos
      .where((a) => a.situacaoEnum != AtendimentoSituacao.cancelado)
      .toList();

  Future<void> loadAtendimentos() async {
    _log.i('Carregando atendimentos');
    _state = const AtendimentosLoading();
    notifyListeners();

    try {
      _atendimentos = await _repository.getAtendimentos();
      // Ordenar por data de criação, mais recentes primeiro
      _atendimentos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _log.d('${_atendimentos.length} atendimentos carregados');
      _log.t(
        'Ativos: ${atendimentosAtivos.length}, Cancelados: ${atendimentosCancelados.length}',
      );
      _log.t(
        'Filtrados para ${_selectedDate.toString().split(' ')[0]}: ${atendimentosFiltrados.length}',
      );
      _state = AtendimentosLoaded(atendimentosFiltrados);
    } catch (e) {
      _log.e('Erro ao carregar atendimentos', error: e);
      _state = AtendimentosError(e);
    }

    notifyListeners();
  }

  void reset() {
    _log.t('Reset do estado de atendimentos');
    _state = const AtendimentosInitial();
    _atendimentos = [];
    _selectedDate = DateTime.now();
    notifyListeners();
  }
}
