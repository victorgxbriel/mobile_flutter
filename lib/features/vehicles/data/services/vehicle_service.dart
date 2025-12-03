import '../../../../core/network/dio_client.dart';
import '../models/vehicle_model.dart';

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
    final response = await _dioClient.instance.get('/carros');
    final List<dynamic> data = response.data;
    return data.map((json) => VehicleModel.fromJson(json)).toList();
  }

  @override
  Future<VehicleModel> getVehicle(int id) async {
    final response = await _dioClient.instance.get('/carros/$id');
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> createVehicle(CreateVehicleDto dto) async {
    final response = await _dioClient.instance.post(
      '/carros',
      data: dto.toJson(),
    );
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto) async {
    final response = await _dioClient.instance.patch(
      '/carros/$id',
      data: dto.toJson(),
    );
    return VehicleModel.fromJson(response.data);
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await _dioClient.instance.delete('/carros/$id');
  }
}
