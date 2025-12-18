import 'package:mobile_flutter/core/network/dio_client.dart';

abstract class ProgramacaoDiariaService {
  Future<Map<String, dynamic>> findByEstabelecimento(int estabelecimentoId);
  Future<dynamic> findByEstabelecimentoAndData(
    int estabelecimentoId,
    String data,
  );
  Future<Map<String, dynamic>> findOne(int id);
  Future<Map<String, dynamic>> create(
    int estabelecimentoId,
    Map<String, dynamic> data,
  );
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data);
  Future<void> remove(int id);
  Future<Map<String, dynamic>> findSlots(int programacaoId);
  Future<void> toggleSlot(int programacaoId, int slotId);
}

class ProgramacaoDiariaServiceImpl implements ProgramacaoDiariaService {
  final DioClient _apiClient;

  ProgramacaoDiariaServiceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> findByEstabelecimento(
    int estabelecimentoId,
  ) async {
    final response = await _apiClient.instance.get(
      '/estabelecimentos/$estabelecimentoId/programacoes-diarias',
    );
    return {'data': response.data};
  }

  @override
  Future<dynamic> findByEstabelecimentoAndData(
    int estabelecimentoId,
    String data,
  ) async {
    final response = await _apiClient.instance.get(
      '/estabelecimentos/$estabelecimentoId/programacoes-diarias/data/$data',
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> findOne(int id) async {
    final response = await _apiClient.instance.get('/programacoes-diarias/$id');
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> create(
    int estabelecimentoId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.instance.post(
      '/estabelecimentos/$estabelecimentoId/programacoes-diarias',
      data: data,
    );
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.instance.patch(
      '/programacoes-diarias/$id',
      data: data,
    );
    return response.data;
  }

  @override
  Future<void> remove(int id) async {
    await _apiClient.instance.delete('/programacoes-diarias/$id');
  }

  @override
  Future<Map<String, dynamic>> findSlots(int programacaoId) async {
    final response = await _apiClient.instance.get(
      '/programacoes-diarias/$programacaoId/slots',
    );
    return {'data': response.data};
  }

  @override
  Future<void> toggleSlot(int programacaoId, int slotId) async {
    await _apiClient.instance.patch(
      '/programacoes-diarias/$programacaoId/slots/$slotId',
    );
  }
}
