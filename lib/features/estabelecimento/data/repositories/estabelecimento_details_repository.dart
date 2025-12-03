import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';

import '../models/estabelecimento_model.dart';
import '../models/servico_model.dart';
import '../services/estabelecimento_details_service.dart';

final _log = logger(EstabelecimentoDetailsRepository);

class EstabelecimentoDetailsRepository {
  final EstabelecimentoDetailsService _service;

  EstabelecimentoDetailsRepository(this._service);

  /// Busca um estabelecimento por ID
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    _log.d('Buscando estabelecimento: $id');
    try {
      final estabelecimento = await _service.getEstabelecimento(id);
      _log.t('Estabelecimento encontrado: ${estabelecimento.nomeFantasia}');
      return estabelecimento;
    } catch (e) {
      _log.e('Erro ao buscar estabelecimento $id', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Estabelecimento não encontrado.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao buscar estabelecimento.');
    }
  }

  /// Busca os serviços de um estabelecimento (com tipoServico incluído)
  Future<List<ServicoModel>> getServicosDoEstabelecimento(int estabelecimentoId) async {
    _log.d('Buscando serviços do estabelecimento: $estabelecimentoId');
    try {
      final servicos = await _service.getServicosDoEstabelecimento(estabelecimentoId);
      _log.t('${servicos.length} serviços encontrados');
      return servicos;
    } catch (e) {
      _log.e('Erro ao buscar serviços', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Estabelecimento não encontrado.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao buscar serviços.');
    }
  }
}
