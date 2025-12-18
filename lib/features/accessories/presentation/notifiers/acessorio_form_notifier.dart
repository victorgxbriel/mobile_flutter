import 'package:flutter/material.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../data/models/acessorio_model.dart';
import '../../data/repositories/acessorio_repository.dart';
import '../states/acessorio_form_state.dart';

final _log = logger(AcessorioFormNotifier);

class AcessorioFormNotifier extends ValueNotifier<AcessorioFormState> {
  final AcessorioRepository _repository;
  final int estabelecimentoId;

  AcessorioFormNotifier(this._repository, this.estabelecimentoId)
      : super(AcessorioFormInitial());

  /// Cria um novo acessório
  Future<void> createAcessorio(
    String titulo,
    String? descricao,
    String preco,
  ) async {
    _log.t('Criando novo acessório: $titulo');
    value = AcessorioFormLoading();

    final dto = CreateAcessorioDto(
      titulo: titulo,
      descricao: descricao,
      preco: preco,
      estabelecimentoId: estabelecimentoId,
    );

    try {
      final acessorio = await _repository.createAcessorio(dto);
      _log.t('Acessório criado com sucesso: ${acessorio.titulo}');
      value = AcessorioFormSuccess(acessorio);
    } catch (e) {
      _log.e('Erro ao criar acessório', error: e);
      value = AcessorioFormError(e.toString());
    }
  }

  /// Atualiza um acessório existente
  Future<void> updateAcessorio(int acessorioId, UpdateAcessorioDto dto) async {
    _log.t('Atualizando acessório $acessorioId');
    value = AcessorioFormLoading();

    try {
      final acessorio = await _repository.updateAcessorio(acessorioId, dto);
      _log.t('Acessório atualizado com sucesso');
      value = AcessorioFormSuccess(acessorio);
    } catch (e) {
      _log.e('Erro ao atualizar acessório', error: e);
      value = AcessorioFormError(e.toString());
    }
  }

  /// Reseta o estado do formulário
  void reset() {
    _log.t('Resetando estado do formulário');
    value = AcessorioFormInitial();
  }
}
