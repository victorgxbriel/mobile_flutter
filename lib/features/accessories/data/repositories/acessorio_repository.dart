import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../models/acessorio_model.dart';
import '../services/acessorio_service.dart';

final _log = logger(AcessorioRepository);

class AcessorioRepository {
  final AcessorioService _service;

  AcessorioRepository(this._service);

  Future<List<AcessorioModel>> getAcessoriosByEstabelecimento(
      int estabelecimentoId) async {
    try {
      return await _service.getAcessoriosByEstabelecimento(estabelecimentoId);
    } catch (e) {
      _log.e('Erro ao buscar acessórios do estabelecimento', error: e);
      rethrow;
    }
  }

  Future<AcessorioModel> getAcessorioById(
      int estabelecimentoId, int acessorioId) async {
    try {
      return await _service.getAcessorioById(estabelecimentoId, acessorioId);
    } catch (e) {
      _log.e('Erro ao buscar acessório', error: e);
      rethrow;
    }
  }

  Future<AcessorioModel> createAcessorio(CreateAcessorioDto dto) async {
    try {
      return await _service.createAcessorio(dto);
    } catch (e) {
      _log.e('Erro ao criar acessório', error: e);
      rethrow;
    }
  }

  Future<AcessorioModel> updateAcessorio(
      int acessorioId, UpdateAcessorioDto dto) async {
    try {
      return await _service.updateAcessorio(acessorioId, dto);
    } catch (e) {
      _log.e('Erro ao atualizar acessório', error: e);
      rethrow;
    }
  }

  Future<void> deleteAcessorio(int acessorioId) async {
    try {
      await _service.deleteAcessorio(acessorioId);
    } catch (e) {
      _log.e('Erro ao remover acessório', error: e);
      rethrow;
    }
  }
}
