import 'package:flutter/foundation.dart';

import '../../data/models/nhtsa_models.dart';
import '../../data/services/nhtsa_service.dart';
import '../state/nhtsa_state.dart';

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
      _makesState = MakesLoaded(_allMakes);
      notifyListeners();
      return;
    }

    _makesState = const MakesLoading();
    notifyListeners();

    try {
      final response = await _service.getAllMakes();
      _allMakes = response.results;
      _makesState = MakesLoaded(_allMakes);
    } catch (e) {
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
    _selectedMake = make;
    _availableModels = [];
    _modelsState = const ModelsLoading();
    notifyListeners();

    try {
      final response = await _service.getModelsByMakeId(make.makeId);
      _availableModels = response.results;
      _modelsState = ModelsLoaded(_availableModels);
    } catch (e) {
      _modelsState = ModelsError(e.toString());
    }

    notifyListeners();
  }

  /// Limpa a seleção de marca e modelos
  void clearSelection() {
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
    _selectedMake = null;
    _availableModels = [];
    _modelsState = const ModelsInitial();
    // Mantém o cache de marcas
    notifyListeners();
  }
}
