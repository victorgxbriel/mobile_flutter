import '../../../accessories/data/models/acessorio_model.dart';

sealed class AcessoriosState {}

class AcessoriosInitial extends AcessoriosState {}

class AcessoriosLoading extends AcessoriosState {}

class AcessoriosLoaded extends AcessoriosState {
  final List<AcessorioModel> acessorios;

  AcessoriosLoaded(this.acessorios);
}

class AcessoriosError extends AcessoriosState {
  final String error;

  AcessoriosError(this.error);
}
