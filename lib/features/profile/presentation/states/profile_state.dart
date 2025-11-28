import 'package:mobile_flutter/features/profile/data/models/profile_models.dart';

sealed class ProfileState {}

/// Estado inicial
class ProfileInitial implements ProfileState {}

/// Carregando dados do perfil
class ProfileLoading implements ProfileState {}

/// Perfil carregado com sucesso
class ProfileLoaded implements ProfileState {
  final ClienteModel cliente;

  ProfileLoaded(this.cliente);
}

/// Erro ao carregar/atualizar perfil
class ProfileError implements ProfileState {
  final String message;

  ProfileError(this.message);
}

/// Logout realizado com sucesso
class ProfileLoggedOut implements ProfileState {}
