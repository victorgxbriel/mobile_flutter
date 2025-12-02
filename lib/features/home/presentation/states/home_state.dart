
import 'package:mobile_flutter/features/home/data/models/estabelecimento_models.dart';

sealed class HomeState {}

/// Estado inicial
class HomeInitial implements HomeState {}

/// Carregando estabelecimentos
class HomeLoading implements HomeState {}

/// Estabelecimentos carregados com sucesso
class HomeLoaded implements HomeState {
  final List<EstabelecimentoModel> estabelecimentos;

  HomeLoaded(this.estabelecimentos);
}

/// Erro ao carregar estabelecimentos
class HomeError implements HomeState {
  final String message;

  HomeError(this.message);
}
