import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';

import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../state/vehicles_state.dart';

final _log = logger(VehiclesNotifier);

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
    _log.i('Carregando veículos');
    _state = const VehiclesLoading();
    notifyListeners();

    try {
      _vehicles = await _repository.getVehicles();
      _log.d('${_vehicles.length} veículos carregados');
      _state = VehiclesLoaded(_vehicles);
    } catch (e) {
      _log.e('Erro ao carregar veículos', error: e);
      _state = VehiclesError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> createVehicle(CreateVehicleDto dto) async {
    _log.i('Criando veículo: ${dto.marca} ${dto.modelo}');
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      final vehicle = await _repository.createVehicle(dto);
      _vehicles.add(vehicle);
      _log.i('Veículo criado com sucesso: ID ${vehicle.id}');
      _state = VehiclesLoaded(_vehicles);
      _operationState = VehicleOperationSuccess(
        vehicle: vehicle,
        message: 'Veículo adicionado com sucesso!',
      );
    } catch (e) {
      _log.e('Erro ao criar veículo', error: e);
      _operationState = VehicleOperationError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> updateVehicle(int vehicleId, UpdateVehicleDto dto) async {
    _log.i('Atualizando veículo: $vehicleId');
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      final updatedVehicle = await _repository.updateVehicle(vehicleId, dto);
      final index = _vehicles.indexWhere((v) => v.id == vehicleId);
      if (index != -1) {
        _vehicles[index] = updatedVehicle;
        _state = VehiclesLoaded(_vehicles);
      }
      _log.i('Veículo atualizado com sucesso');
      _operationState = VehicleOperationSuccess(
        vehicle: updatedVehicle,
        message: 'Veículo atualizado com sucesso!',
      );
    } catch (e) {
      _log.e('Erro ao atualizar veículo', error: e);
      _operationState = VehicleOperationError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  Future<void> deleteVehicle(int vehicleId) async {
    _log.i('Removendo veículo: $vehicleId');
    _operationState = const VehicleOperationLoading();
    notifyListeners();

    try {
      await _repository.deleteVehicle(vehicleId);
      _vehicles.removeWhere((v) => v.id == vehicleId);
      _log.i('Veículo removido com sucesso');
      _state = VehiclesLoaded(_vehicles);
      _operationState = const VehicleOperationSuccess(
        message: 'Veículo removido com sucesso!',
      );
    } catch (e) {
      _log.e('Erro ao remover veículo', error: e);
      _operationState = VehicleOperationError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  void resetOperationState() {
    _log.t('Reset do estado de operação');
    _operationState = const VehicleOperationInitial();
    notifyListeners();
  }
}
