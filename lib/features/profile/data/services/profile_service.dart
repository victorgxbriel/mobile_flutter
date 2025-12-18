import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_models.dart';

final _log = logger(ProfileServiceImpl);

abstract class ProfileService {
  Future<ClienteModel> getCliente(int clienteId);
  Future<ClienteModel> updateCliente(int clienteId, UpdateClienteDto dto);
  Future<EstabelecimentoModel> getEstabelecimento(int estabelecimentoId);
  Future<EstabelecimentoModel> updateEstabelecimento( int estabelecimentoId, UpdateEstabelecimentoDto dto);
}

class ProfileServiceImpl implements ProfileService {
  final DioClient _client;

  ProfileServiceImpl(this._client);

  @override
  Future<ClienteModel> getCliente(int clienteId) async {
    _log.t('GET /clientes/$clienteId');
    try {
      final response = await _client.instance.get('/clientes/$clienteId');
      return ClienteModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ClienteModel> updateCliente(int clienteId, UpdateClienteDto dto) async {
    _log.t('PATCH /clientes/$clienteId');
    try {
      final response = await _client.instance.patch( '/clientes/$clienteId',
        data: dto.toJson(),
      );
      _log.t('Cliente atualizado');
      return ClienteModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }
  
  @override
  Future<EstabelecimentoModel> getEstabelecimento(int estabelecimentoId) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId');
    try {
      final response = await _client.instance.get('/estabelecimentos/$estabelecimentoId');
      return EstabelecimentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }
  
  @override
  Future<EstabelecimentoModel> updateEstabelecimento(int estabelecimentoId, UpdateEstabelecimentoDto dto) async {
    _log.t('PATCH /estabelecimentos/$estabelecimentoId');
    try {
      final response = await _client.instance.patch( '/estabelecimentos/$estabelecimentoId',
        data: dto.toJson(),
      );
      _log.t('Cliente atualizado');
      return EstabelecimentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
