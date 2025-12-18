import 'package:equatable/equatable.dart';
import '../../data/models/servico_model.dart';

/// Estado base para gerenciar a lista de serviços
sealed class ServicosState extends Equatable {
  const ServicosState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ServicosInitial extends ServicosState {
  const ServicosInitial();
}

/// Estado de carregamento
class ServicosLoading extends ServicosState {
  const ServicosLoading();
}

/// Estado com dados carregados
class ServicosLoaded extends ServicosState {
  final List<ServicoModel> servicos;

  const ServicosLoaded(this.servicos);

  @override
  List<Object?> get props => [servicos];
}

/// Estado de erro
class ServicosError extends ServicosState {
  final Object error;

  const ServicosError(this.error);

  @override
  List<Object?> get props => [error];
}

/// Estado base para gerenciar formulário de serviço
sealed class ServicoFormState extends Equatable {
  const ServicoFormState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial do formulário
class ServicoFormInitial extends ServicoFormState {
  const ServicoFormInitial();
}

/// Estado de carregamento
class ServicoFormLoading extends ServicoFormState {
  const ServicoFormLoading();
}

/// Estado de sucesso ao criar/atualizar
class ServicoFormSuccess extends ServicoFormState {
  final ServicoModel servico;

  const ServicoFormSuccess(this.servico);

  @override
  List<Object?> get props => [servico];
}

/// Estado de erro ao criar/atualizar
class ServicoFormError extends ServicoFormState {
  final Object error;

  const ServicoFormError(this.error);

  @override
  List<Object?> get props => [error];
}
