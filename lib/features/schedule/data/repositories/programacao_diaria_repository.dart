import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../models/programacao_diaria_model.dart';
import '../services/programacao_diaria_service.dart';

final _log = logger(ProgramacaoDiariaRepository);

class ProgramacaoDiariaRepository {
  final ProgramacaoDiariaService _service;

  ProgramacaoDiariaRepository(this._service);

  /// Buscar todas as programações de um estabelecimento
  Future<List<ProgramacaoDiaria>> findByEstabelecimento(
    int estabelecimentoId,
  ) async {
    try {
      _log.d(
        'Buscando programações diárias do estabelecimento $estabelecimentoId',
      );
      final response = await _service.findByEstabelecimento(estabelecimentoId);

      return (response['data'] as List)
          .map((json) => ProgramacaoDiaria.fromJson(json))
          .toList();
    } catch (e) {
      _log.e('Erro ao buscar programações diárias', error: e);
      rethrow;
    }
  }

  /// Buscar todas as programações de um estabelecimento em uma data específica
  Future<List<ProgramacaoDiaria>> findAllByEstabelecimentoAndData(
    int estabelecimentoId,
    String data, // formato: YYYY-MM-DD
  ) async {
    try {
      _log.d(
        'Buscando programações do estabelecimento $estabelecimentoId na data $data',
      );
      final response = await _service.findByEstabelecimentoAndData(
        estabelecimentoId,
        data,
      );

      // A API retorna um array
      if (response is List) {
        if (response.isEmpty) {
          _log.d('Nenhuma programação encontrada para a data $data');
          return [];
        }
        return response
            .map(
              (json) =>
                  ProgramacaoDiaria.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }

      // Caso a API retorne um objeto único (fallback)
      return [ProgramacaoDiaria.fromJson(response)];
    } catch (e) {
      _log.w('Erro ao buscar programações para a data $data', error: e);
      return [];
    }
  }

  /// Buscar programação por ID
  Future<ProgramacaoDiaria> findOne(int id) async {
    try {
      _log.d('Buscando programação $id');
      final response = await _service.findOne(id);
      return ProgramacaoDiaria.fromJson(response);
    } catch (e) {
      _log.e('Erro ao buscar programação $id', error: e);
      rethrow;
    }
  }

  /// Criar nova programação diária (abre programação e gera slots automáticos)
  Future<ProgramacaoDiaria> create(
    int estabelecimentoId,
    CreateProgramacaoDiariaDto dto,
  ) async {
    try {
      _log.i('Criando programação diária para $estabelecimentoId');
      final response = await _service.create(estabelecimentoId, dto.toJson());

      return ProgramacaoDiaria.fromJson(response);
    } catch (e) {
      _log.e('Erro ao criar programação diária', error: e);
      rethrow;
    }
  }

  /// Atualizar programação diária
  Future<ProgramacaoDiaria> update(
    int id,
    UpdateProgramacaoDiariaDto dto,
  ) async {
    try {
      _log.i('Atualizando programação $id');
      final response = await _service.update(id, dto.toJson());

      return ProgramacaoDiaria.fromJson(response);
    } catch (e) {
      _log.e('Erro ao atualizar programação $id', error: e);
      rethrow;
    }
  }

  /// Remover programação diária
  Future<void> remove(int id) async {
    try {
      _log.i('Removendo programação $id');
      await _service.remove(id);
    } catch (e) {
      _log.e('Erro ao remover programação $id', error: e);
      rethrow;
    }
  }

  /// Buscar slots de uma programação
  Future<List<SlotTempo>> findSlots(int programacaoId) async {
    try {
      _log.d('Buscando slots da programação $programacaoId');
      final response = await _service.findSlots(programacaoId);

      return (response['data'] as List)
          .map((json) => SlotTempo.fromJson(json))
          .toList();
    } catch (e) {
      _log.e('Erro ao buscar slots da programação $programacaoId', error: e);
      rethrow;
    }
  }

  /// Desabilitar/habilitar um slot de tempo
  Future<void> toggleSlot(int programacaoId, int slotId) async {
    try {
      _log.i('Alternando disponibilidade do slot $slotId');
      await _service.toggleSlot(programacaoId, slotId);
    } catch (e) {
      _log.e('Erro ao alterar slot $slotId', error: e);
      rethrow;
    }
  }
}
