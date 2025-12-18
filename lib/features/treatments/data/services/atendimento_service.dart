import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/atendimento_model.dart';

final _log = logger(AtendimentoServiceImpl);

abstract class AtendimentoService {
  Future<List<AtendimentoModel>> getAtendimentosByEstabelecimentoId(
    int estabelecimentoId,
  );
  Future<AtendimentoModel> getAtendimentoById(int id);
}

class AtendimentoServiceImpl implements AtendimentoService {
  final DioClient _client;

  AtendimentoServiceImpl(this._client);

  @override
  Future<List<AtendimentoModel>> getAtendimentosByEstabelecimentoId(
    int estabelecimentoId,
  ) async {
    _log.t('GET /atendimentos/estabelecimentos/$estabelecimentoId');
    try {
      final response = await _client.instance.get(
        '/atendimentos/estabelecimentos/$estabelecimentoId',
      );

      final List<dynamic> data = response.data is List ? response.data : [];
      _log.t('${data.length} atendimentos recebidos');
      return data.map((json) => AtendimentoModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AtendimentoModel> getAtendimentoById(int id) async {
    _log.t('GET /atendimentos/$id');
    try {
      final response = await _client.instance.get('/atendimentos/$id');
      return AtendimentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
