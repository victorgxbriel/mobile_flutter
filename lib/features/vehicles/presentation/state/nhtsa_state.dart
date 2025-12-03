import '../../data/models/nhtsa_models.dart';

// Estados para lista de marcas
sealed class MakesState {
  const MakesState();
}

final class MakesInitial extends MakesState {
  const MakesInitial();
}

final class MakesLoading extends MakesState {
  const MakesLoading();
}

final class MakesLoaded extends MakesState {
  final List<MakeModel> makes;

  const MakesLoaded(this.makes);
}

final class MakesError extends MakesState {
  final String message;

  const MakesError(this.message);
}

// Estados para lista de modelos
sealed class ModelsState {
  const ModelsState();
}

final class ModelsInitial extends ModelsState {
  const ModelsInitial();
}

final class ModelsLoading extends ModelsState {
  const ModelsLoading();
}

final class ModelsLoaded extends ModelsState {
  final List<VehicleModelNhtsa> models;

  const ModelsLoaded(this.models);
}

final class ModelsError extends ModelsState {
  final String message;

  const ModelsError(this.message);
}
