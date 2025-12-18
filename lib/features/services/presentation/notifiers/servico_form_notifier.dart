import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../data/models/servico_model.dart';
import '../../data/repositories/servico_repository.dart';
import '../states/servico_state.dart';

final _log = logger(ServicoFormNotifier);

class ServicoFormNotifier extends ValueNotifier<ServicoFormState> {
  final ServicoRepository _repository;
  final int estabelecimentoId;

  ServicoFormNotifier(this._repository, this.estabelecimentoId)
      : super(const ServicoFormInitial());

  /// Cria um novo serviço
  Future<void> createServico(
    String titulo,
    String? descricao,
    String preco,
    String tempoEstimado,
    int? tipoServicoId,
  ) async {
    _log.t('Criando novo serviço: $titulo');
    value = const ServicoFormLoading();

    final dto = CreateServicoDto(
      titulo: titulo,
      descricao: descricao,
      preco: preco,
      tempoEstimado: tempoEstimado,
      estabelecimentoId: estabelecimentoId,
      tipoServicoId: tipoServicoId,
    );

    try {
      final servico = await _repository.createServico(dto);
      _log.t('Serviço criado com sucesso: ${servico.titulo}');
      value = ServicoFormSuccess(servico);
    } catch (e) {
      _log.e('Erro ao criar serviço', error: e);
      value = ServicoFormError(e);
    }
  }

  /// Atualiza um serviço existente
  Future<void> updateServico(int servicoId, UpdateServicoDto dto) async {
    _log.t('Atualizando serviço $servicoId');
    value = const ServicoFormLoading();

    try {
      final servico = await _repository.updateServico(servicoId, dto);
      _log.t('Serviço atualizado com sucesso');
      value = ServicoFormSuccess(servico);
    } catch (e) {
      _log.e('Erro ao atualizar serviço', error: e);
      value = ServicoFormError(e);
    }
  }

  /// Reseta o estado do formulário
  void reset() {
    _log.t('Resetando estado do formulário');
    value = const ServicoFormInitial();
  }
}
