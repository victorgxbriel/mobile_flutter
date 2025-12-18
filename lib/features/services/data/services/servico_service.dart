import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/servico_model.dart';

final _log = logger(ServicoServiceImpl);

abstract class ServicoService {
  /// Lista todos os serviços do estabelecimento
  Future<List<ServicoModel>> getServicosByEstabelecimento(
      int estabelecimentoId);

  /// Busca um serviço específico do estabelecimento
  Future<ServicoModel> getServicoById(int estabelecimentoId, int servicoId);

  /// Cria um novo serviço
  Future<ServicoModel> createServico(CreateServicoDto dto);

  /// Atualiza um serviço existente
  Future<ServicoModel> updateServico(int servicoId, UpdateServicoDto dto);

  /// Remove um serviço
  Future<void> deleteServico(int servicoId);
}

class ServicoServiceImpl implements ServicoService {
  final DioClient _client;

  ServicoServiceImpl(this._client);

  @override
  Future<List<ServicoModel>> getServicosByEstabelecimento(
      int estabelecimentoId) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/servicos');
    try {
      final response = await _client.instance
          .get('/estabelecimentos/$estabelecimentoId/servicos');
      final List<dynamic> data = response.data;
      return data.map((json) => ServicoModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ServicoModel> getServicoById(
      int estabelecimentoId, int servicoId) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/servicos/$servicoId');
    try {
      final response = await _client.instance
          .get('/estabelecimentos/$estabelecimentoId/servicos/$servicoId');
      return ServicoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ServicoModel> createServico(CreateServicoDto dto) async {
    _log.t('POST /servicos');
    try {
      final response = await _client.instance.post(
        '/servicos',
        data: dto.toJson(),
      );
      _log.t('Serviço criado com sucesso');
      return ServicoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ServicoModel> updateServico(
      int servicoId, UpdateServicoDto dto) async {
    _log.t('PATCH /servicos/$servicoId');
    try {
      final response = await _client.instance.patch(
        '/servicos/$servicoId',
        data: dto.toJson(),
      );
      _log.t('Serviço atualizado com sucesso');
      return ServicoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> deleteServico(int servicoId) async {
    _log.t('DELETE /servicos/$servicoId');
    try {
      await _client.instance.delete('/servicos/$servicoId');
      _log.t('Serviço removido com sucesso');
    } on DioException catch (_) {
      rethrow;
    }
  }
}
