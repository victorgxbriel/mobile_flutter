import 'package:mobile_flutter/features/profile/data/models/profile_models.dart';

sealed class ProfileState {}

/// Estado inicial
class ProfileInitial implements ProfileState {}

/// Carregando dados do perfil
class ProfileLoading implements ProfileState {}

/// Perfil carregado com sucesso
class ProfileLoaded implements ProfileState {
  final EstabelecimentoModel estabelecimento;
  
  /// Erro opcional (ex: falha ao carregar da API, mas tem dados em cache/sessão)
  final Object? error;

  ProfileLoaded(this.estabelecimento, {this.error});
  
  /// Indica se há um erro a ser mostrado (banner)
  bool get hasError => error != null;
}

/// Logout realizado com sucesso
class ProfileLoggedOut implements ProfileState {}
