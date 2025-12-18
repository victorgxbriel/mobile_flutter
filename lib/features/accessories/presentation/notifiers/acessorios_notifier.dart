import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/services/session_service.dart';
import '../../data/repositories/acessorio_repository.dart';
import '../states/acessorio_state.dart';

final _log = logger(AcessoriosNotifier);

class AcessoriosNotifier extends ValueNotifier<AcessoriosState> {
  final AcessorioRepository _repository;
  final int estabelecimentoId;
  final SessionService _sessionService;


  bool get isFuncionario => _sessionService.isFuncionario;

  AcessoriosNotifier(this._repository, this.estabelecimentoId, this._sessionService)
      : super(AcessoriosInitial());

  /// Carrega a lista de acessórios do estabelecimento
  Future<void> loadAcessorios() async {
    _log.t('Carregando acessórios do estabelecimento $estabelecimentoId');
    value = AcessoriosLoading();

    try {
      final acessorios =
          await _repository.getAcessoriosByEstabelecimento(estabelecimentoId);
      _log.t('${acessorios.length} acessórios carregados');
      value = AcessoriosLoaded(acessorios);
    } catch (e) {
      _log.e('Erro ao carregar acessórios', error: e);
      value = AcessoriosError(e.toString());
    }
  }

  /// Remove um acessório e recarrega a lista
  Future<void> deleteAcessorio(int acessorioId) async {
    _log.t('Removendo acessório $acessorioId');
    try {
      await _repository.deleteAcessorio(acessorioId);
      _log.t('Acessório removido com sucesso');
      await loadAcessorios(); // Recarrega a lista
    } catch (e) {
      _log.e('Erro ao remover acessório', error: e);
      value = AcessoriosError(e.toString());
    }
  }
}
