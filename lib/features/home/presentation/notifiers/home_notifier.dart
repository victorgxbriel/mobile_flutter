import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';

import '../../data/repositories/estabelecimento_repository.dart';
import '../../data/models/estabelecimento_models.dart';
import '../states/home_state.dart';

final _log = logger(HomeNotifier);

class HomeNotifier extends ChangeNotifier {
  final EstabelecimentoRepository _repository;

  HomeNotifier(this._repository);

  HomeState _state = HomeInitial();
  HomeState get state => _state;

  List<EstabelecimentoModel> _estabelecimentos = [];
  List<EstabelecimentoModel> get estabelecimentos => _estabelecimentos;

  /// Carrega todos os estabelecimentos
  Future<void> loadEstabelecimentos() async {
    _log.i('Carregando estabelecimentos...');
    _state = HomeLoading();
    notifyListeners();

    try {
      final result = await _repository.getEstabelecimentos();
      _estabelecimentos = result;
      _log.d('${result.length} estabelecimentos carregados');
      _state = HomeLoaded(result);
    } catch (e) {
      _log.e('Erro ao carregar estabelecimentos', error: e);
      _state = HomeError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Atualiza a lista (pull to refresh)
  Future<void> refresh() async {
    _log.d('Atualizando lista de estabelecimentos');
    await loadEstabelecimentos();
  }

  /// Reseta o estado para inicial
  void reset() {
    _log.t('Reset do estado home');
    _state = HomeInitial();
    _estabelecimentos = [];
    notifyListeners();
  }
}
