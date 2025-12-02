import 'package:flutter/foundation.dart';

import '../../data/repositories/estabelecimento_repository.dart';
import '../../data/models/estabelecimento_models.dart';
import '../states/home_state.dart';

class HomeNotifier extends ChangeNotifier {
  final EstabelecimentoRepository _repository;

  HomeNotifier(this._repository);

  HomeState _state = HomeInitial();
  HomeState get state => _state;

  List<EstabelecimentoModel> _estabelecimentos = [];
  List<EstabelecimentoModel> get estabelecimentos => _estabelecimentos;

  /// Carrega todos os estabelecimentos
  Future<void> loadEstabelecimentos() async {
    _state = HomeLoading();
    notifyListeners();

    try {
      final result = await _repository.getEstabelecimentos();
      _estabelecimentos = result;
      _state = HomeLoaded(result);
    } catch (e) {
      _state = HomeError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Atualiza a lista (pull to refresh)
  Future<void> refresh() async {
    await loadEstabelecimentos();
  }

  /// Reseta o estado para inicial
  void reset() {
    _state = HomeInitial();
    _estabelecimentos = [];
    notifyListeners();
  }
}
