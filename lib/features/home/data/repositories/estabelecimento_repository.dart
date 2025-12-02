import 'package:dio/dio.dart';

import '../services/estabelecimento_service.dart';
import '../models/estabelecimento_models.dart';

class EstabelecimentoRepository {
  final EstabelecimentoService _service;

  EstabelecimentoRepository(this._service);

  /// Busca todos os estabelecimentos
  Future<List<EstabelecimentoModel>> getEstabelecimentos() async {
    try {
      return await _service.getEstabelecimentos();
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao buscar estabelecimentos.');
    }
  }

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
}
