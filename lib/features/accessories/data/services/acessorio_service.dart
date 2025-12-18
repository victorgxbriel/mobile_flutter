import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/acessorio_model.dart';

final _log = logger(AcessorioServiceImpl);

abstract class AcessorioService {
  /// Lista todos os acessórios do estabelecimento
  Future<List<AcessorioModel>> getAcessoriosByEstabelecimento(
    int estabelecimentoId,
  );

  /// Busca um acessório específico do estabelecimento
  Future<AcessorioModel> getAcessorioById(
    int estabelecimentoId,
    int acessorioId,
  );

  /// Cria um novo acessório
  Future<AcessorioModel> createAcessorio(CreateAcessorioDto dto);

  /// Atualiza um acessório existente
  Future<AcessorioModel> updateAcessorio(
    int acessorioId,
    UpdateAcessorioDto dto,
  );

  /// Remove um acessório
  Future<void> deleteAcessorio(int acessorioId);
}

class AcessorioServiceImpl implements AcessorioService {
  final DioClient _client;

  AcessorioServiceImpl(this._client);

  @override
  Future<List<AcessorioModel>> getAcessoriosByEstabelecimento(
    int estabelecimentoId,
  ) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/acessorios');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/acessorios',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => AcessorioModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AcessorioModel> getAcessorioById(
    int estabelecimentoId,
    int acessorioId,
  ) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/acessorios/$acessorioId');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/acessorios/$acessorioId',
      );
      return AcessorioModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AcessorioModel> createAcessorio(CreateAcessorioDto dto) async {
    _log.t('POST /acessorios');
    try {
      final response = await _client.instance.post(
        '/acessorios',
        data: dto.toJson(),
      );
      _log.t('Acessório criado: ID ${response.data['id']}');
      return AcessorioModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AcessorioModel> updateAcessorio(
    int acessorioId,
    UpdateAcessorioDto dto,
  ) async {
    _log.t('PATCH /acessorios/$acessorioId');
    try {
      final response = await _client.instance.patch(
        '/acessorios/$acessorioId',
        data: dto.toJson(),
      );
      _log.t('Acessório atualizado');
      return AcessorioModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAcessorio(int acessorioId) async {
    _log.t('DELETE /acessorios/$acessorioId');
    try {
      await _client.instance.delete('/acessorios/$acessorioId');
      _log.t('Acessório removido');
    } on DioException catch (_) {
      rethrow;
    }
  }
}
