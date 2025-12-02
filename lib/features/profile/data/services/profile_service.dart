import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_models.dart';

abstract class ProfileService {
  Future<ClienteModel> getCliente(int clienteId);
  Future<ClienteModel> updateCliente(int clienteId, UpdateClienteDto dto);
}

class ProfileServiceImpl implements ProfileService {
  final DioClient _client;

  ProfileServiceImpl(this._client);

  @override
  Future<ClienteModel> getCliente(int clienteId) async {
    try {
      final response = await _client.instance.get('/clientes/$clienteId');
      return ClienteModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ClienteModel> updateCliente(int clienteId, UpdateClienteDto dto) async {
    try {
      final response = await _client.instance.patch(
        '/clientes/$clienteId',
        data: dto.toJson(),
      );
      return ClienteModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }
}
