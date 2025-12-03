import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

abstract class VehicleRepository {
  Future<List<VehicleModel>> getVehicles();
  Future<VehicleModel> getVehicle(int id);
  Future<VehicleModel> createVehicle(CreateVehicleDto dto);
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto);
  Future<void> deleteVehicle(int id);
}

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleService _service;

  VehicleRepositoryImpl(this._service);

  @override
  Future<List<VehicleModel>> getVehicles() async {
    return await _service.getVehicles();
  }

  @override
  Future<VehicleModel> getVehicle(int id) async {
    return await _service.getVehicle(id);
  }

  @override
  Future<VehicleModel> createVehicle(CreateVehicleDto dto) async {
    return await _service.createVehicle(dto);
  }

  @override
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto) async {
    return await _service.updateVehicle(id, dto);
  }

  @override
  Future<void> deleteVehicle(int id) async {
    await _service.deleteVehicle(id);
  }
}
