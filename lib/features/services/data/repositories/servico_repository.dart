import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../models/servico_model.dart';
import '../services/servico_service.dart';

final _log = logger(ServicoRepository);

class ServicoRepository {
  final ServicoService _service;

  ServicoRepository(this._service);

  Future<List<ServicoModel>> getServicosByEstabelecimento(
      int estabelecimentoId) async {
    try {
      return await _service.getServicosByEstabelecimento(estabelecimentoId);
    } catch (e) {
      _log.e('Erro ao buscar serviços do estabelecimento', error: e);
      rethrow;
    }
  }

  Future<ServicoModel> getServicoById(
      int estabelecimentoId, int servicoId) async {
    try {
      return await _service.getServicoById(estabelecimentoId, servicoId);
    } catch (e) {
      _log.e('Erro ao buscar serviço', error: e);
      rethrow;
    }
  }

  Future<ServicoModel> createServico(CreateServicoDto dto) async {
    try {
      return await _service.createServico(dto);
    } catch (e) {
      _log.e('Erro ao criar serviço', error: e);
      rethrow;
    }
  }

  Future<ServicoModel> updateServico(
      int servicoId, UpdateServicoDto dto) async {
    try {
      return await _service.updateServico(servicoId, dto);
    } catch (e) {
      _log.e('Erro ao atualizar serviço', error: e);
      rethrow;
    }
  }

  Future<void> deleteServico(int servicoId) async {
    try {
      await _service.deleteServico(servicoId);
    } catch (e) {
      _log.e('Erro ao remover serviço', error: e);
      rethrow;
    }
  }
}
