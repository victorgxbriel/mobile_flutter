import '../../data/models/vehicle_model.dart';

// Estados para lista de veículos
sealed class VehiclesState {
  const VehiclesState();
}

final class VehiclesInitial extends VehiclesState {
  const VehiclesInitial();
}

final class VehiclesLoading extends VehiclesState {
  const VehiclesLoading();
}

final class VehiclesLoaded extends VehiclesState {
  final List<VehicleModel> vehicles;

  const VehiclesLoaded(this.vehicles);
}

final class VehiclesError extends VehiclesState {
  final String message;

  const VehiclesError(this.message);
}

// Estados para operações CRUD (criar, editar, deletar)
sealed class VehicleOperationState {
  const VehicleOperationState();
}

final class VehicleOperationInitial extends VehicleOperationState {
  const VehicleOperationInitial();
}

final class VehicleOperationLoading extends VehicleOperationState {
  const VehicleOperationLoading();
}

final class VehicleOperationSuccess extends VehicleOperationState {
  final VehicleModel? vehicle;
  final String message;

  const VehicleOperationSuccess({this.vehicle, required this.message});
}

final class VehicleOperationError extends VehicleOperationState {
  final String message;

  const VehicleOperationError(this.message);
}
