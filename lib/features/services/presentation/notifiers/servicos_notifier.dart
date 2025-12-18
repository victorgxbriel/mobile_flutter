import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/services/session_service.dart';
import '../../data/repositories/servico_repository.dart';
import '../states/servico_state.dart';

final _log = logger(ServicosNotifier);

class ServicosNotifier extends ValueNotifier<ServicosState> {
  final ServicoRepository _repository;
  final int estabelecimentoId;
  final SessionService _sessionService;

  ServicosState get state => value;
  bool get isFuncionario => _sessionService.isFuncionario;

  ServicosNotifier(this._repository, this.estabelecimentoId, this._sessionService)
      : super(const ServicosInitial());

  /// Carrega a lista de serviços do estabelecimento
  Future<void> loadServicos() async {
    _log.t('Carregando serviços do estabelecimento $estabelecimentoId');
    value = const ServicosLoading();

    try {
      final servicos =
          await _repository.getServicosByEstabelecimento(estabelecimentoId);
      _log.t('${servicos.length} serviços carregados');
      value = ServicosLoaded(servicos);
    } catch (e) {
      _log.e('Erro ao carregar serviços', error: e);
      value = ServicosError(e);
    }
  }

  /// Remove um serviço e recarrega a lista
  Future<void> deleteServico(int servicoId) async {
    _log.t('Removendo serviço $servicoId');
    try {
      await _repository.deleteServico(servicoId);
      _log.t('Serviço removido com sucesso');
      await loadServicos(); // Recarrega a lista
    } catch (e) {
      _log.e('Erro ao remover serviço', error: e);
      value = ServicosError(e);
    }
  }
}
