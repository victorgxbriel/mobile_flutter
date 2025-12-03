import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/agendamento_model.dart';
import '../models/slot_model.dart';

abstract class AgendamentoService {
  Future<List<AgendamentoModel>> getAgendamentosByClienteId(int clienteId);
  Future<AgendamentoModel> getAgendamentoById(int id);
  Future<AgendamentoModel> createAgendamento(CreateAgendamentoDto dto);
  Future<void> cancelarAgendamento(int id);
  Future<List<ProgramacaoDiariaModel>> getProgramacoesByEstabelecimento(int estabelecimentoId);
  Future<ProgramacaoDiariaModel?> getProgramacaoByData(int estabelecimentoId, String data);
}

class AgendamentoServiceImpl implements AgendamentoService {
  final DioClient _client;

  AgendamentoServiceImpl(this._client);

  @override
  Future<List<AgendamentoModel>> getAgendamentosByClienteId(int clienteId) async {
    try {
      final response = await _client.instance.get(
        '/agendamentos/clientes/$clienteId',
      );
      
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AgendamentoModel> getAgendamentoById(int id) async {
    try {
      final response = await _client.instance.get(
        '/agendamentos/$id',
      );
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AgendamentoModel> createAgendamento(CreateAgendamentoDto dto) async {
    try {
      final response = await _client.instance.post(
        '/agendamentos',
        data: dto.toJson(),
      );
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> cancelarAgendamento(int id) async {
    try {
      await _client.instance.post('/agendamentos/$id/cancelamento');
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ProgramacaoDiariaModel>> getProgramacoesByEstabelecimento(int estabelecimentoId) async {
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/programacoes-diarias',
      );
      
      final List<dynamic> data = response.data is List ? response.data : [];
      return data.map((json) => ProgramacaoDiariaModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ProgramacaoDiariaModel?> getProgramacaoByData(int estabelecimentoId, String data) async {
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/programacoes-diarias/data/$data',
      );
      return ProgramacaoDiariaModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // Não há programação para esta data
      }
      rethrow;
    }
  }
}
