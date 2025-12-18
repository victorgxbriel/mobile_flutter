import '../../data/models/acessorio_model.dart';

sealed class AcessorioFormState {}

class AcessorioFormInitial extends AcessorioFormState {}

class AcessorioFormLoading extends AcessorioFormState {}

class AcessorioFormSuccess extends AcessorioFormState {
  final AcessorioModel acessorio;

  AcessorioFormSuccess(this.acessorio);
}

class AcessorioFormError extends AcessorioFormState {
  final String error;

  AcessorioFormError(this.error);
}
