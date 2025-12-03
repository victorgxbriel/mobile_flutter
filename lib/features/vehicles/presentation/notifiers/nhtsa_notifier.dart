import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';

import '../../data/models/nhtsa_models.dart';
import '../../data/services/nhtsa_service.dart';
import '../state/nhtsa_state.dart';

final _log = logger(NhtsaNotifier);

class NhtsaNotifier extends ChangeNotifier {
  final NhtsaService _service;

  NhtsaNotifier(this._service);

  // Estado das marcas
  MakesState _makesState = const MakesInitial();
  MakesState get makesState => _makesState;

  // Estado dos modelos
  ModelsState _modelsState = const ModelsInitial();
  ModelsState get modelsState => _modelsState;

  // Cache de marcas carregadas
  List<MakeModel> _allMakes = [];
  List<MakeModel> get allMakes => _allMakes;

  // Marca selecionada
  MakeModel? _selectedMake;
  MakeModel? get selectedMake => _selectedMake;

  // Modelos disponíveis para a marca selecionada
  List<VehicleModelNhtsa> _availableModels = [];
  List<VehicleModelNhtsa> get availableModels => _availableModels;

  /// Carrega todas as marcas (faz cache)
  Future<void> loadMakes() async {
    // Se já tem cache, não precisa carregar novamente
    if (_allMakes.isNotEmpty) {
      _log.t('Usando cache de marcas (${_allMakes.length} marcas)');
      _makesState = MakesLoaded(_allMakes);
      notifyListeners();
      return;
    }

    _log.i('Carregando marcas da NHTSA...');
    _makesState = const MakesLoading();
    notifyListeners();

    try {
      final response = await _service.getAllMakes();
      _allMakes = response.results;
      _log.d('${_allMakes.length} marcas carregadas');
      _makesState = MakesLoaded(_allMakes);
    } catch (e) {
      _log.e('Erro ao carregar marcas', error: e);
      _makesState = MakesError(e.toString());
    }

    notifyListeners();
  }

  /// Filtra marcas pelo nome (busca local no cache)
  List<MakeModel> filterMakes(String query) {
    if (query.length < 2) return [];
    final lowerQuery = query.toLowerCase();
    return _allMakes
        .where((make) => make.makeName.toLowerCase().contains(lowerQuery))
        .take(20) // Limita para performance
        .toList();
  }

  /// Seleciona uma marca e carrega seus modelos
  Future<void> selectMake(MakeModel make) async {
    _log.i('Selecionando marca: ${make.makeName}');
    _selectedMake = make;
    _availableModels = [];
    _modelsState = const ModelsLoading();
    notifyListeners();

    try {
      final response = await _service.getModelsByMakeId(make.makeId);
      _availableModels = response.results;
      _log.d('${_availableModels.length} modelos encontrados para ${make.makeName}');
      _modelsState = ModelsLoaded(_availableModels);
    } catch (e) {
      _log.e('Erro ao carregar modelos', error: e);
      _modelsState = ModelsError(e.toString());
    }

    notifyListeners();
  }

  /// Limpa a seleção de marca e modelos
  void clearSelection() {
    _log.t('Limpando seleção de marca/modelo');
    _selectedMake = null;
    _availableModels = [];
    _modelsState = const ModelsInitial();
    notifyListeners();
  }

  /// Filtra modelos pelo nome (busca local)
  List<VehicleModelNhtsa> filterModels(String query) {
    if (query.isEmpty) return _availableModels;
    final lowerQuery = query.toLowerCase();
    return _availableModels
        .where((model) => model.modelName.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Reseta todos os estados
  void reset() {
    _log.t('Reset do estado NHTSA (mantendo cache)');
    _selectedMake = null;
    _availableModels = [];
    _modelsState = const ModelsInitial();
    // Mantém o cache de marcas
    notifyListeners();
  }
}
