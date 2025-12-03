import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/features/estabelecimento/presentation/states/estabelecimento_details_state.dart';

import '../../data/models/estabelecimento_model.dart';
import '../../data/models/servico_model.dart';
import '../../data/repositories/estabelecimento_details_repository.dart';

final _log = logger(EstabelecimentoDetailsNotifier);

class EstabelecimentoDetailsNotifier extends ChangeNotifier {
  final EstabelecimentoDetailsRepository _repository;

  EstabelecimentoDetailsNotifier(this._repository);

  EstabelecimentoDetailsState _state = EstabelecimentoDetailsInitial();
  EstabelecimentoDetailsState get state => _state;

  EstabelecimentoModel? _estabelecimento;
  EstabelecimentoModel? get estabelecimento => _estabelecimento;

  List<ServicoModel> _servicos = [];
  List<ServicoModel> get servicos => _servicos;

  /// Carrega os detalhes do estabelecimento e seus serviços
  Future<void> loadDetails(int estabelecimentoId) async {
    _log.i('Carregando detalhes do estabelecimento: $estabelecimentoId');
    _state = EstabelecimentoDetailsLoading();
    notifyListeners();

    try {
      // Carrega estabelecimento e serviços em paralelo
      final results = await Future.wait([
        _repository.getEstabelecimento(estabelecimentoId),
        _repository.getServicosDoEstabelecimento(estabelecimentoId),
      ]);

      _estabelecimento = results[0] as EstabelecimentoModel;
      _servicos = results[1] as List<ServicoModel>;

      _log.d('Estabelecimento carregado: ${_estabelecimento!.nomeFantasia}');
      _log.t('${_servicos.length} serviços disponíveis');

      _state = EstabelecimentoDetailsLoaded(
        estabelecimento: _estabelecimento!,
        servicos: _servicos,
      );
    } catch (e) {
      _log.e('Erro ao carregar detalhes do estabelecimento', error: e);
      _state = EstabelecimentoDetailsError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }

    notifyListeners();
  }

  /// Atualiza os dados
  Future<void> refresh(int estabelecimentoId) async {
    _log.d('Atualizando detalhes do estabelecimento');
    await loadDetails(estabelecimentoId);
  }

  /// Reseta o estado
  void reset() {
    _log.t('Reset do estado de detalhes do estabelecimento');
    _state = EstabelecimentoDetailsInitial();
    _estabelecimento = null;
    _servicos = [];
    notifyListeners();
  }
}
