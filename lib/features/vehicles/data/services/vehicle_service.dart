import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';

final _log = logger(VehicleServiceImpl);

abstract class VehicleService {
  Future<List<VehicleModel>> getVehiclesByCliente(int clienteId);
  Future<VehicleModel> getVehicle(int clienteId, int vehicleId);
  Future<VehicleModel> createVehicle(int clienteId, CreateVehicleDto dto);
  Future<VehicleModel> updateVehicle(int clienteId, int vehicleId, UpdateVehicleDto dto);
  Future<void> deleteVehicle(int clienteId, int vehicleId);
}

class VehicleServiceImpl implements VehicleService {
  final DioClient _dioClient;

  VehicleServiceImpl(this._dioClient);

  @override
  Future<List<VehicleModel>> getVehiclesByCliente(int clienteId) async {
    _log.t('GET /clientes/$clienteId/carros');
    final response = await _dioClient.instance.get('/clientes/$clienteId/carros');
    final List<dynamic> data = response.data;
    _log.t('${data.length} veículos recebidos');
    return data.map((json) => VehicleModel.fromJson(json)).toList();
  }

  @override
  Future<VehicleModel> getVehicle(int clienteId, int vehicleId) async {
    _log.t('GET /clientes/$clienteId/carros/$vehicleId');
    final response = await _dioClient.instance.get('/clientes/$clienteId/carros/$vehicleId');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> createVehicle(int clienteId, CreateVehicleDto dto) async {
    _log.t('POST /clientes/$clienteId/carros');
    final response = await _dioClient.instance.post('/clientes/$clienteId/carros',
      data: dto.toJson(),
    );
    _log.t('Veículo criado: ID ${response.data['id']}');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> updateVehicle(int clienteId, int vehicleId, UpdateVehicleDto dto) async {
    _log.t('PATCH /clientes/$clienteId/carros/$vehicleId');
    final response = await _dioClient.instance.patch('/clientes/$clienteId/carros/$vehicleId',
      data: dto.toJson(),
    );
    _log.t('Veículo atualizado');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<void> deleteVehicle(int clienteId, int vehicleId) async {
    _log.t('DELETE /clientes/$clienteId/carros/$vehicleId');
    await _dioClient.instance.delete('/clientes/$clienteId/carros/$vehicleId');
    _log.t('Veículo removido');
  }
}
