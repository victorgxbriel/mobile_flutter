import 'package:flutter/foundation.dart';

import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../state/vehicles_state.dart';

class VehiclesNotifier extends ChangeNotifier {
  final VehicleRepository _repository;

  VehiclesNotifier(this._repository);

  VehiclesState _state = const VehiclesInitial();
  VehiclesState get state => _state;

  VehicleOperationState _operationState = const VehicleOperationInitial();
  VehicleOperationState get operationState => _operationState;

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> get vehicles => _vehicles;

  Future<void> loadVehicles() async {
    _state = const VehiclesLoading();
    notifyListeners();

    try {
      _vehicles = await _repository.getVehicles();
      _state = VehiclesLoaded(_vehicles);
    } catch (e) {
      _state = VehiclesError(e.toString());
    }

    notifyListeners();
  }

  Future<void> createVehicle(CreateVehicleDto dto) async {
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      final vehicle = await _repository.createVehicle(dto);
      _vehicles.add(vehicle);
      _state = VehiclesLoaded(_vehicles);
      _operationState = VehicleOperationSuccess(
        vehicle: vehicle,
        message: 'Veículo adicionado com sucesso!',
      );
    } catch (e) {
      _operationState = VehicleOperationError(e.toString());
    }

    notifyListeners();
  }

  Future<void> updateVehicle(int id, UpdateVehicleDto dto) async {
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      final updatedVehicle = await _repository.updateVehicle(id, dto);
      final index = _vehicles.indexWhere((v) => v.id == id);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _state = VehiclesLoaded(_vehicles);
      }
      _operationState = VehicleOperationSuccess(
        vehicle: updatedVehicle,
        message: 'Veículo atualizado com sucesso!',
      );
    } catch (e) {
      _operationState = VehicleOperationError(e.toString());
    }

    notifyListeners();
  }

  Future<void> deleteVehicle(int id) async {
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      await _repository.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      _state = VehiclesLoaded(_vehicles);
      _operationState = const VehicleOperationSuccess(
        message: 'Veículo removido com sucesso!',
      );
    } catch (e) {
      _operationState = VehicleOperationError(e.toString());
    }

    notifyListeners();
  }

  void resetOperationState() {
    _operationState = const VehicleOperationInitial();
    notifyListeners();
  }
}
