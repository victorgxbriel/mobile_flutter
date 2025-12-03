import 'package:dio/dio.dart';
import '../models/agendamento_model.dart';
import '../models/slot_model.dart';
import '../services/agendamento_service.dart';

class AgendamentoRepository {
  final AgendamentoService _service;

  AgendamentoRepository(this._service);

  Future<List<AgendamentoModel>> getAgendamentosByClienteId(int clienteId) async {
    try {
      return await _service.getAgendamentosByClienteId(clienteId);
    } catch (e, stackTrace) {
      print('Erro ao carregar agendamentos: $e');
      print('StackTrace: $stackTrace');
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao carregar agendamentos.');
    }
  }

  Future<AgendamentoModel> getAgendamentoById(int id) async {
    try {
      return await _service.getAgendamentoById(id);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Agendamento não encontrado.');
        }
      }
      throw Exception('Erro ao carregar agendamento.');
    }
  }

  Future<AgendamentoModel> getAgendamentoByIdFull(int id) async {
    try {
      return await _service.getAgendamentoByIdFull(id);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Agendamento não encontrado.');
        }
      }
      throw Exception('Erro ao carregar detalhes do agendamento.');
    }
  }

  Future<AgendamentoModel> createAgendamento({
    required int carroId,
    required int slotId,
    required List<int> servicosIds,
  }) async {
    try {
      final dto = CreateAgendamentoDto(
        carroId: carroId,
        situacaoId: 1, // 1 = Agendado
        slotId: slotId,
        servicosIds: servicosIds,
      );
      return await _service.createAgendamento(dto);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          final message = e.response?.data['message'];
          if (message != null) {
            throw Exception(message);
          }
          throw Exception('Dados inválidos. Verifique os campos.');
        }
      }
      throw Exception('Erro ao criar agendamento.');
    }
  }

  Future<void> cancelarAgendamento(int id) async {
    try {
      await _service.cancelarAgendamento(id);
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Não é possível cancelar este agendamento.');
        }
      }
      throw Exception('Erro ao cancelar agendamento.');
    }
  }

  Future<List<ProgramacaoDiariaModel>> getProgramacoesByEstabelecimento(int estabelecimentoId) async {
    try {
      return await _service.getProgramacoesByEstabelecimento(estabelecimentoId);
    } catch (e) {
      throw Exception('Erro ao carregar datas disponíveis.');
    }
  }

  Future<ProgramacaoDiariaModel?> getProgramacaoByData(int estabelecimentoId, DateTime data) async {
    try {
      final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      return await _service.getProgramacaoByData(estabelecimentoId, dataFormatada);
    } catch (e) {
      throw Exception('Erro ao carregar horários disponíveis.');
    }
  }
}
