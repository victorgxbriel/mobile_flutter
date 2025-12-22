import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/cliente_model.dart';

final _log = logger(ClienteServiceImpl);

abstract class ClienteService {
  /// Lista todos os clientes do estabelecimento
  Future<List<ClienteModel>> getClientesByEstabelecimento(
    int estabelecimentoId,
  );

  /// Busca um cliente específico por ID
  Future<ClienteModel> getClienteById(int clienteId);

  /// Busca os carros de um cliente
  Future<List<ClienteCarroModel>> getCarrosByCliente(int clienteId);
}

class ClienteServiceImpl implements ClienteService {
  final DioClient _client;

  ClienteServiceImpl(this._client);

  @override
  Future<List<ClienteModel>> getClientesByEstabelecimento(
    int estabelecimentoId,
  ) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/clientes');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/clientes',
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      _log.t('${data.length} clientes recebidos');
      return data.map((json) => ClienteModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ClienteModel> getClienteById(int clienteId) async {
    _log.t('GET /clientes/$clienteId');
    try {
      final response = await _client.instance.get('/clientes/$clienteId');
      return ClienteModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ClienteCarroModel>> getCarrosByCliente(int clienteId) async {
    _log.t('GET /clientes/$clienteId/carros');
    try {
      final response = await _client.instance.get(
        '/clientes/$clienteId/carros',
      );
      final List<dynamic> data = response.data is List ? response.data : [];
      _log.t('${data.length} carros recebidos');
      return data.map((json) => ClienteCarroModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }
}
