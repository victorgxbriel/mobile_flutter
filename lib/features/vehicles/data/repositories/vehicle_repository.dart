import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';

final _log = logger(VehicleRepositoryImpl);

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
    _log.i('Buscando veículos do cliente...');
    final vehicles = await _service.getVehicles();
    _log.d('${vehicles.length} veículos encontrados');
    return vehicles;
  }

  @override
  Future<VehicleModel> getVehicle(int id) async {
    _log.d('Buscando veículo: $id');
    return await _service.getVehicle(id);
  }

  @override
  Future<VehicleModel> createVehicle(CreateVehicleDto dto) async {
    _log.i('Criando veículo: ${dto.marca} ${dto.modelo}');
    final vehicle = await _service.createVehicle(dto);
    _log.i('Veículo criado com ID: ${vehicle.id}');
    return vehicle;
  }

  @override
  Future<VehicleModel> updateVehicle(int id, UpdateVehicleDto dto) async {
    _log.i('Atualizando veículo: $id');
    final vehicle = await _service.updateVehicle(id, dto);
    _log.i('Veículo atualizado');
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(int id) async {
    _log.i('Removendo veículo: $id');
    await _service.deleteVehicle(id);
    _log.i('Veículo removido');
  }
}
