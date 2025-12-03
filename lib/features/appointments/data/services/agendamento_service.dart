import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/agendamento_model.dart';
import '../models/slot_model.dart';

final _log = logger(AgendamentoServiceImpl);

abstract class AgendamentoService {
  Future<List<AgendamentoModel>> getAgendamentosByClienteId(int clienteId);
  Future<AgendamentoModel> getAgendamentoById(int id);
  Future<AgendamentoModel> getAgendamentoByIdFull(int id);
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
    _log.t('GET /agendamentos/clientes/$clienteId');
    try {
      final response = await _client.instance.get( '/agendamentos/clientes/$clienteId',
      );
      
      final List<dynamic> data = response.data is List ? response.data : [];
      _log.t('${data.length} agendamentos recebidos');
      return data.map((json) => AgendamentoModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AgendamentoModel> getAgendamentoById(int id) async {
    _log.t('GET /agendamentos/$id');
    try {
      final response = await _client.instance.get( '/agendamentos/$id',
      );
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AgendamentoModel> getAgendamentoByIdFull(int id) async {
    _log.t('GET /agendamentos/$id?include=full');
    try {
      final response = await _client.instance.get( '/agendamentos/$id',
        queryParameters: {'include': 'full'},
      );
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<AgendamentoModel> createAgendamento(CreateAgendamentoDto dto) async {
    _log.t('POST /agendamentos');
    try {
      final response = await _client.instance.post( '/agendamentos',
        data: dto.toJson(),
      );
      _log.t('Agendamento criado: ID ${response.data['id']}');
      return AgendamentoModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> cancelarAgendamento(int id) async {
    _log.t('POST /agendamentos/$id/cancelamento');
    try {
      await _client.instance.post('/agendamentos/$id/cancelamento');
      _log.t('Agendamento cancelado');
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<ProgramacaoDiariaModel>> getProgramacoesByEstabelecimento(int estabelecimentoId) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/programacoes-diarias');
    try {
      final response = await _client.instance.get( '/estabelecimentos/$estabelecimentoId/programacoes-diarias',
      );
      
      final List<dynamic> data = response.data is List ? response.data : [];
      _log.t('${data.length} programações recebidas');
      return data.map((json) => ProgramacaoDiariaModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<ProgramacaoDiariaModel?> getProgramacaoByData(int estabelecimentoId, String data) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/programacoes-diarias/data/$data');
    try {
      final response = await _client.instance.get( '/estabelecimentos/$estabelecimentoId/programacoes-diarias/data/$data',
      );
      return ProgramacaoDiariaModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        _log.t('Nenhuma programação para $data');
        return null; // Não há programação para esta data
      }
      rethrow;
    }
  }
}
