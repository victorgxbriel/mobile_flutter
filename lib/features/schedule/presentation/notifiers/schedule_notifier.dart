import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/features/schedule/data/models/programacao_diaria_model.dart';
import 'package:mobile_flutter/features/schedule/data/repositories/programacao_diaria_repository.dart';
import 'package:mobile_flutter/features/schedule/presentation/states/schedule_state.dart';

final _log = logger(ScheduleNotifier);

class ScheduleNotifier extends ChangeNotifier {
  final ProgramacaoDiariaRepository _repository;
  final int _estabelecimentoId;

  ScheduleNotifier(this._repository, this._estabelecimentoId);

  ScheduleState _state = ScheduleInitial();
  ScheduleState get state => _state;

  /// Mapa de programações por data para exibir no calendário
  Map<DateTime, List<ProgramacaoDiaria>> _programacoesPorData = {};
  Map<DateTime, List<ProgramacaoDiaria>> get programacoesPorData =>
      _programacoesPorData;

  /// Data selecionada no calendário
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  /// Lista de programações da data selecionada
  List<ProgramacaoDiaria> _selectedProgramacoes = [];
  List<ProgramacaoDiaria> get selectedProgramacoes => _selectedProgramacoes;

  /// Programação expandida atualmente (para controle do accordion)
  ProgramacaoDiaria? _expandedProgramacao;
  ProgramacaoDiaria? get expandedProgramacao => _expandedProgramacao;

  /// Mapa de slots por programação ID
  Map<int, List<SlotTempo>> _slotsPorProgramacao = {};
  Map<int, List<SlotTempo>> get slotsPorProgramacao => _slotsPorProgramacao;

  /// Carregar programações do estabelecimento
  Future<void> loadProgramacoes() async {
    _log.i('Carregando programações do estabelecimento $_estabelecimentoId');
    _state = ScheduleLoading();
    notifyListeners();

    try {
      final programacoes = await _repository.findByEstabelecimento(
        _estabelecimentoId,
      );

      _log.d('${programacoes.length} programações carregadas');

      // Organizar programações por data
      _programacoesPorData = {};
      for (final prog in programacoes) {
        final dateKey = _normalizeDate(prog.data);
        if (_programacoesPorData.containsKey(dateKey)) {
          _programacoesPorData[dateKey]!.add(prog);
        } else {
          _programacoesPorData[dateKey] = [prog];
        }
      }

      _state = ScheduleLoaded(
        programacoesPorData: _programacoesPorData,
        selectedDate: _selectedDate,
        selectedProgramacao: _expandedProgramacao,
      );
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao carregar programações', error: e);
      _state = ScheduleError('Erro ao carregar programações: $e');
      notifyListeners();
    }
  }

  /// Selecionar uma data no calendário
  Future<void> selectDate(DateTime date) async {
    _log.d('Data selecionada: ${DateFormat('yyyy-MM-dd').format(date)}');
    _selectedDate = _normalizeDate(date);

    // Buscar todas as programações para esta data
    final dataStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    try {
      final programacoes = await _repository.findAllByEstabelecimentoAndData(
        _estabelecimentoId,
        dataStr,
      );

      _selectedProgramacoes = programacoes;
      _log.d('${programacoes.length} programações encontradas para a data');

      // Carregar slots de todas as programações
      _slotsPorProgramacao = {};
      for (final prog in programacoes) {
        await _loadSlotsForProgramacao(prog.id);
      }

      // Expandir a primeira programação por padrão se houver
      _expandedProgramacao = programacoes.isNotEmpty
          ? programacoes.first
          : null;

      _state = ScheduleLoaded(
        programacoesPorData: _programacoesPorData,
        selectedDate: _selectedDate,
        selectedProgramacao: _expandedProgramacao,
      );
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao buscar programações da data', error: e);
      _selectedProgramacoes = [];
      _slotsPorProgramacao = {};
      notifyListeners();
    }
  }

  /// Expandir/colapsar uma programação específica
  void toggleExpanded(ProgramacaoDiaria programacao) {
    if (_expandedProgramacao?.id == programacao.id) {
      _expandedProgramacao = null;
    } else {
      _expandedProgramacao = programacao;
    }
    notifyListeners();
  }

  /// Verificar se uma programação está expandida
  bool isExpanded(ProgramacaoDiaria programacao) {
    return _expandedProgramacao?.id == programacao.id;
  }

  /// Obter slots de uma programação específica
  List<SlotTempo> getSlotsForProgramacao(int programacaoId) {
    return _slotsPorProgramacao[programacaoId] ?? [];
  }

  /// Carregar slots de uma programação específica
  Future<void> _loadSlotsForProgramacao(int programacaoId) async {
    try {
      final slots = await _repository.findSlots(programacaoId);
      _slotsPorProgramacao[programacaoId] = slots;
      _log.d(
        '${slots.length} slots carregados para programação $programacaoId',
      );
    } catch (e) {
      _log.e('Erro ao carregar slots da programação $programacaoId', error: e);
      _slotsPorProgramacao[programacaoId] = [];
    }
  }

  /// Criar nova programação diária
  Future<bool> createProgramacao({
    required DateTime data,
    required String horaInicio,
    required String horaTermino,
    required String intervaloHorario,
    int agendamentosPorHorario = 1,
  }) async {
    _log.i('Criando programação para ${DateFormat('yyyy-MM-dd').format(data)}');
    _state = ScheduleCreating();
    notifyListeners();

    try {
      final dto = CreateProgramacaoDiariaDto(
        data: DateFormat('yyyy-MM-dd').format(data),
        horaInicio: horaInicio,
        horaTermino: horaTermino,
        intervaloHorario: intervaloHorario,
        agendamentosPorHorario: agendamentosPorHorario,
        estabelecimentoId: _estabelecimentoId,
      );

      final programacao = await _repository.create(_estabelecimentoId, dto);
      _log.i('Programação criada com sucesso: ${programacao.id}');

      // Atualizar mapa de programações
      final dateKey = _normalizeDate(data);
      if (_programacoesPorData.containsKey(dateKey)) {
        _programacoesPorData[dateKey]!.add(programacao);
      } else {
        _programacoesPorData[dateKey] = [programacao];
      }

      // Adicionar à lista de programações selecionadas
      _selectedProgramacoes.add(programacao);
      _expandedProgramacao = programacao;
      _selectedDate = dateKey;

      // Carregar slots da nova programação
      await _loadSlotsForProgramacao(programacao.id);

      _state = ScheduleLoaded(
        programacoesPorData: _programacoesPorData,
        selectedDate: _selectedDate,
        selectedProgramacao: _expandedProgramacao,
      );
      notifyListeners();

      return true;
    } catch (e) {
      _log.e('Erro ao criar programação', error: e);
      _state = ScheduleError('Erro ao criar programação: $e');
      notifyListeners();
      return false;
    }
  }

  /// Remover programação
  Future<bool> removeProgramacao(int id) async {
    _log.i('Removendo programação $id');

    try {
      await _repository.remove(id);
      _log.i('Programação removida com sucesso');

      // Remover do mapa
      _programacoesPorData.forEach((date, programacoes) {
        programacoes.removeWhere((p) => p.id == id);
      });

      // Remover da lista de programações selecionadas
      _selectedProgramacoes.removeWhere((p) => p.id == id);
      _slotsPorProgramacao.remove(id);

      // Limpar seleção se for a programação removida
      if (_expandedProgramacao?.id == id) {
        _expandedProgramacao = _selectedProgramacoes.isNotEmpty
            ? _selectedProgramacoes.first
            : null;
      }

      _state = ScheduleLoaded(
        programacoesPorData: _programacoesPorData,
        selectedDate: _selectedDate,
        selectedProgramacao: _expandedProgramacao,
      );
      notifyListeners();

      return true;
    } catch (e) {
      _log.e('Erro ao remover programação', error: e);
      return false;
    }
  }

  /// Alternar disponibilidade de um slot
  Future<bool> toggleSlot(int programacaoId, int slotId) async {
    _log.i(
      'Alternando disponibilidade do slot $slotId na programação $programacaoId',
    );

    try {
      await _repository.toggleSlot(programacaoId, slotId);
      _log.i('Slot alterado com sucesso');

      // Recarregar slots da programação
      await _loadSlotsForProgramacao(programacaoId);
      notifyListeners();

      return true;
    } catch (e) {
      _log.e('Erro ao alternar slot', error: e);
      return false;
    }
  }

  /// Normalizar data (remover hora/minuto/segundo)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Obter programações de uma data específica (para TableCalendar)
  List<ProgramacaoDiaria> getEventsForDay(DateTime day) {
    final normalizedDay = _normalizeDate(day);
    return _programacoesPorData[normalizedDay] ?? [];
  }

  /// Refresh das programações
  Future<void> refresh() async {
    _log.d('Atualizando programações');
    await loadProgramacoes();
  }

  /// Reset do estado
  void reset() {
    _log.t('Reset do estado de schedule');
    _state = ScheduleInitial();
    _programacoesPorData = {};
    _selectedDate = null;
    _selectedProgramacoes = [];
    _expandedProgramacao = null;
    _slotsPorProgramacao = {};
    notifyListeners();
  }
}
