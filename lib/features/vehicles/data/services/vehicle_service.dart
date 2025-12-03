import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';

final _log = logger(VehicleServiceImpl);

abstract class VehicleService {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> getVehicle(int id);
  Future<VehicleModel> createVehicle(CreateVehicleDto dto);
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto);
  Future<void> deleteVehicle(int id);
}

class VehicleServiceImpl implements VehicleService {
  final DioClient _dioClient;

  VehicleServiceImpl(this._dioClient);

  @override
  Future<List<VehicleModel>> getVehicles() async {
    _log.t('GET /carros');
    final response = await _dioClient.instance.get('/carros');
    final List<dynamic> data = response.data;
    _log.t('${data.length} veículos recebidos');
    return data.map((json) => VehicleModel.fromJson(json)).toList();
  }

  @override
  Future<VehicleModel> getVehicle(int id) async {
    _log.t('GET /carros/$id');
    final response = await _dioClient.instance.get('/carros/$id');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> createVehicle(CreateVehicleDto dto) async {
    _log.t('POST /carros');
    final response = await _dioClient.instance.post( '/carros',
      data: dto.toJson(),
    );
    _log.t('Veículo criado: ID ${response.data['id']}');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto) async {
    _log.t('PATCH /carros/$id');
    final response = await _dioClient.instance.patch( '/carros/$id',
      data: dto.toJson(),
    );
    _log.t('Veículo atualizado');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<void> deleteVehicle(int id) async {
    _log.t('DELETE /carros/$id');
    await _dioClient.instance.delete('/carros/$id');
    _log.t('Veículo removido');
  }
}
