import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/errors/exceptions.dart';

import '../services/estabelecimento_service.dart';
import '../models/estabelecimento_models.dart';

final _log = logger(EstabelecimentoRepository);

class EstabelecimentoRepository {
  final EstabelecimentoService _service;

  EstabelecimentoRepository(this._service);

  /// Busca todos os estabelecimentos
  Future<List<EstabelecimentoModel>> getEstabelecimentos() async {
    _log.i('Buscando todos os estabelecimentos...');
    try {
      final estabelecimentos = await _service.getEstabelecimentos();
      _log.d('${estabelecimentos.length} estabelecimentos encontrados');
      return estabelecimentos;
    } on DioException catch (e) {
      _log.e('Erro ao buscar estabelecimentos', error: e);
      // Propaga erro de conexão para ser tratado na UI
      if (e.error is NoInternetException) {
        rethrow;
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao buscar estabelecimentos.');
    }
  }

  /// Busca um estabelecimento por ID
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    _log.d('Buscando estabelecimento: $id');
    try {
      final estabelecimento = await _service.getEstabelecimento(id);
      _log.t('Estabelecimento encontrado: ${estabelecimento.nomeFantasia}');
      return estabelecimento;
    } on DioException catch (e) {
      _log.e('Erro ao buscar estabelecimento $id', error: e);
      // Propaga erro de conexão para ser tratado na UI
      if (e.error is NoInternetException) {
        rethrow;
      }
      if (e.response?.statusCode == 404) {
        throw Exception('Estabelecimento não encontrado.');
      }
      if (e.response?.statusCode == 401) {
        throw Exception('Sessão expirada. Faça login novamente.');
      }
      throw Exception('Erro ao buscar estabelecimento.');
    }
  }
}
