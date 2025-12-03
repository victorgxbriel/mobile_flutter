import 'package:flutter/foundation.dart';
import '../../data/models/slot_model.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

class CreateAgendamentoNotifier extends ChangeNotifier {
  final AgendamentoRepository _repository;

  CreateAgendamentoNotifier(this._repository);

  CreateAgendamentoState _createState = const CreateAgendamentoInitial();
  CreateAgendamentoState get createState => _createState;

  SlotsState _slotsState = const SlotsInitial();
  SlotsState get slotsState => _slotsState;

  ProgramacoesState _programacoesState = const ProgramacoesInitial();
  ProgramacoesState get programacoesState => _programacoesState;

  // Dados selecionados
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  SlotTempoModel? _selectedSlot;
  SlotTempoModel? get selectedSlot => _selectedSlot;

  int? _selectedCarroId;
  int? get selectedCarroId => _selectedCarroId;

  List<int> _selectedServicosIds = [];
  List<int> get selectedServicosIds => List.unmodifiable(_selectedServicosIds);

  int? _estabelecimentoId;
  int? get estabelecimentoId => _estabelecimentoId;

  void setEstabelecimentoId(int id) {
    _estabelecimentoId = id;
    notifyListeners();
  }

  /// Carrega as programações diárias (datas disponíveis) do estabelecimento
  Future<void> loadProgramacoes(int estabelecimentoId) async {
    _programacoesState = const ProgramacoesLoading();
    notifyListeners();

    try {
      final programacoes = await _repository.getProgramacoesByEstabelecimento(estabelecimentoId);
      _programacoesState = ProgramacoesLoaded(programacoes);
    } catch (e) {
      _programacoesState = ProgramacoesError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Verifica se uma data está disponível para agendamento
  bool isDateAvailable(DateTime date) {
    if (_programacoesState is! ProgramacoesLoaded) return false;
    
    final datasDisponiveis = (_programacoesState as ProgramacoesLoaded).datasDisponiveis;
    final dateNormalized = DateTime(date.year, date.month, date.day);
    return datasDisponiveis.contains(dateNormalized);
  }

  /// Retorna as datas disponíveis
  Set<DateTime> get datasDisponiveis {
    if (_programacoesState is ProgramacoesLoaded) {
      return (_programacoesState as ProgramacoesLoaded).datasDisponiveis;
    }
    return {};
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    _selectedSlot = null; // Limpar slot quando a data muda
    notifyListeners();
  }

  void setSelectedSlot(SlotTempoModel slot) {
    _selectedSlot = slot;
    notifyListeners();
  }

  void setSelectedCarro(int carroId) {
    _selectedCarroId = carroId;
    notifyListeners();
  }

  void addServico(int servicoId) {
    if (!_selectedServicosIds.contains(servicoId)) {
      _selectedServicosIds.add(servicoId);
      notifyListeners();
    }
  }

  void removeServico(int servicoId) {
    _selectedServicosIds.remove(servicoId);
    notifyListeners();
  }

  void setServicos(List<int> servicosIds) {
    _selectedServicosIds = List.from(servicosIds);
    notifyListeners();
  }

  void toggleServico(int servicoId) {
    if (_selectedServicosIds.contains(servicoId)) {
      removeServico(servicoId);
    } else {
      addServico(servicoId);
    }
  }

  bool isServicoSelected(int servicoId) {
    return _selectedServicosIds.contains(servicoId);
  }

  Future<void> loadSlots(int estabelecimentoId, DateTime data) async {
    _slotsState = const SlotsLoading();
    notifyListeners();

    try {
      final programacao = await _repository.getProgramacaoByData(estabelecimentoId, data);
      _slotsState = SlotsLoaded(programacao);
    } catch (e) {
      _slotsState = SlotsError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  bool get canCreateAgendamento {
    return _selectedSlot != null &&
        _selectedCarroId != null &&
        _selectedServicosIds.isNotEmpty;
  }

  Future<void> createAgendamento() async {
    if (!canCreateAgendamento) {
      _createState = const CreateAgendamentoError(
        'Preencha todos os campos obrigatórios.',
      );
      notifyListeners();
      return;
    }

    _createState = const CreateAgendamentoLoading();
    notifyListeners();

    try {
      final agendamento = await _repository.createAgendamento(
        carroId: _selectedCarroId!,
        slotId: _selectedSlot!.id,
        servicosIds: _selectedServicosIds,
      );
      _createState = CreateAgendamentoSuccess(agendamento);
    } catch (e) {
      _createState = CreateAgendamentoError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void reset() {
    _createState = const CreateAgendamentoInitial();
    _slotsState = const SlotsInitial();
    _programacoesState = const ProgramacoesInitial();
    _selectedDate = null;
    _selectedSlot = null;
    _selectedCarroId = null;
    _selectedServicosIds = [];
    _estabelecimentoId = null;
    notifyListeners();
  }

  void resetCreateState() {
    _createState = const CreateAgendamentoInitial();
    notifyListeners();
  }
}
