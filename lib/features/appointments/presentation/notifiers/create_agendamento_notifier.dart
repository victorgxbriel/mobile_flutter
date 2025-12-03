import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../data/models/slot_model.dart';
import '../../data/repositories/agendamento_repository.dart';
import '../states/agendamento_state.dart';

final _log = logger(CreateAgendamentoNotifier);

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
    _log.t('Estabelecimento selecionado: $id');
    _estabelecimentoId = id;
    notifyListeners();
  }

  /// Carrega as programações diárias (datas disponíveis) do estabelecimento
  Future<void> loadProgramacoes(int estabelecimentoId) async {
    _log.i('Carregando programações do estabelecimento: $estabelecimentoId');
    _programacoesState = const ProgramacoesLoading();
    notifyListeners();

    try {
      final programacoes = await _repository.getProgramacoesByEstabelecimento(estabelecimentoId);
      _log.d('${programacoes.length} programações encontradas');
      _programacoesState = ProgramacoesLoaded(programacoes);
    } catch (e) {
      _log.e('Erro ao carregar programações', error: e);
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
    _log.d('Data selecionada: ${date.toString().split(' ')[0]}');
    _selectedDate = date;
    _selectedSlot = null; // Limpar slot quando a data muda
    notifyListeners();
  }

  void setSelectedSlot(SlotTempoModel slot) {
    _log.d('Slot selecionado: ${slot}');
    _selectedSlot = slot;
    notifyListeners();
  }

  void setSelectedCarro(int carroId) {
    _log.d('Carro selecionado: $carroId');
    _selectedCarroId = carroId;
    notifyListeners();
  }

  void addServico(int servicoId) {
    if (!_selectedServicosIds.contains(servicoId)) {
      _selectedServicosIds.add(servicoId);
      _log.t('Serviço adicionado: $servicoId (total: ${_selectedServicosIds.length})');
      notifyListeners();
    }
  }

  void removeServico(int servicoId) {
    _selectedServicosIds.remove(servicoId);
    _log.t('Serviço removido: $servicoId (total: ${_selectedServicosIds.length})');
    notifyListeners();
  }

  void setServicos(List<int> servicosIds) {
    _selectedServicosIds = List.from(servicosIds);
    _log.d('Serviços definidos: $_selectedServicosIds');
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
    _log.i('Carregando slots para ${data.toString().split(' ')[0]}');
    _slotsState = const SlotsLoading();
    notifyListeners();

    try {
      final programacao = await _repository.getProgramacaoByData(estabelecimentoId, data);
      if (programacao != null) {
        _log.d('${programacao.slots} slots encontrados');
      } else {
        _log.d('Nenhuma programação para esta data');
      }
      _slotsState = SlotsLoaded(programacao);
    } catch (e) {
      _log.e('Erro ao carregar slots', error: e);
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
      _log.w('Tentativa de criar agendamento com dados incompletos');
      _createState = const CreateAgendamentoError( 'Preencha todos os campos obrigatórios.',
      );
      notifyListeners();
      return;
    }

    _log.i('Criando agendamento - Carro: $_selectedCarroId, Slot: ${_selectedSlot!.id}, Serviços: $_selectedServicosIds');
    _createState = const CreateAgendamentoLoading();
    notifyListeners();

    try {
      final agendamento = await _repository.createAgendamento(
        carroId: _selectedCarroId!,
        slotId: _selectedSlot!.id,
        servicosIds: _selectedServicosIds,
      );
      _log.i('Agendamento criado com sucesso: ID ${agendamento.id}');
      _createState = CreateAgendamentoSuccess(agendamento);
    } catch (e) {
      _log.e('Erro ao criar agendamento', error: e);
      _createState = CreateAgendamentoError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void reset() {
    _log.t('Reset do estado de criação de agendamento');
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
