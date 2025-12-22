import '../../data/models/atendimento_model.dart';
import '../../data/models/cliente_model.dart';
import 'package:mobile_flutter/features/services/data/models/servico_model.dart';
import 'package:mobile_flutter/features/accessories/data/models/acessorio_model.dart';

sealed class CreateAtendimentoState {
  const CreateAtendimentoState();
}

/// Estado inicial - carregando dados necessários
final class CreateAtendimentoInitial extends CreateAtendimentoState {
  const CreateAtendimentoInitial();
}

/// Carregando dados (clientes, serviços, etc)
final class CreateAtendimentoLoadingData extends CreateAtendimentoState {
  const CreateAtendimentoLoadingData();
}

/// Dados carregados - pronto para seleção
final class CreateAtendimentoReady extends CreateAtendimentoState {
  final List<ClienteModel> clientes;
  final List<ServicoModel> servicos;
  final List<AcessorioModel> acessorios;

  const CreateAtendimentoReady({
    required this.clientes,
    required this.servicos,
    required this.acessorios,
  });
}

/// Submetendo o atendimento
final class CreateAtendimentoSubmitting extends CreateAtendimentoState {
  const CreateAtendimentoSubmitting();
}

/// Atendimento criado com sucesso
final class CreateAtendimentoSuccess extends CreateAtendimentoState {
  final AtendimentoModel atendimento;

  const CreateAtendimentoSuccess(this.atendimento);
}

/// Erro ao carregar dados ou criar atendimento
final class CreateAtendimentoError extends CreateAtendimentoState {
  final Object error;
  final bool canRetry;

  const CreateAtendimentoError(this.error, {this.canRetry = true});
}
