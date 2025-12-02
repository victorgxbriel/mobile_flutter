import '../../data/models/estabelecimento_model.dart';
import '../../data/models/servico_model.dart';

sealed class EstabelecimentoDetailsState {}

/// Estado inicial
class EstabelecimentoDetailsInitial implements EstabelecimentoDetailsState {}

/// Carregando dados
class EstabelecimentoDetailsLoading implements EstabelecimentoDetailsState {}

/// Dados carregados com sucesso
class EstabelecimentoDetailsLoaded implements EstabelecimentoDetailsState {
  final EstabelecimentoModel estabelecimento;
  final List<ServicoModel> servicos;

  EstabelecimentoDetailsLoaded({
    required this.estabelecimento,
    required this.servicos,
  });
}

/// Erro ao carregar dados
class EstabelecimentoDetailsError implements EstabelecimentoDetailsState {
  final String message;

  EstabelecimentoDetailsError(this.message);
}
