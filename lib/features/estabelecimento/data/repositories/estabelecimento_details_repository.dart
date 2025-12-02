import 'package:dio/dio.dart';

import '../models/estabelecimento_model.dart';
import '../models/servico_model.dart';
import '../services/estabelecimento_details_service.dart';

class EstabelecimentoDetailsRepository {
  final EstabelecimentoDetailsService _service;

  EstabelecimentoDetailsRepository(this._service);

  /// Busca um estabelecimento por ID
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    try {
      return await _service.getEstabelecimento(id);
    } catch (e) {
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
    try {
      return await _service.getServicosDoEstabelecimento(estabelecimentoId);
    } catch (e) {
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
