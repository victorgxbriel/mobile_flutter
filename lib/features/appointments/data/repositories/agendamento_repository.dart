import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../models/agendamento_model.dart';
import '../models/slot_model.dart';
import '../services/agendamento_service.dart';

final _log = logger(AgendamentoRepository);

class AgendamentoRepository {
  final AgendamentoService _service;
  final SessionService _sessionService;

  AgendamentoRepository(this._service, this._sessionService);

  int? get _clienteId => _sessionService.clienteId;

  Future<List<AgendamentoModel>> getAgendamentos() async {
    final clienteId = _clienteId;
    if (clienteId == null) {
      _log.w('ClienteId não disponível - perfil não carregado');
      throw Exception('Perfil não carregado. Aguarde ou faça login novamente.');
    }
    _log.i('Carregando agendamentos do cliente: $clienteId');
    try {
      final agendamentos = await _service.getAgendamentosByClienteId(clienteId);
      _log.d('${agendamentos.length} agendamentos encontrados');
      return agendamentos;
    } catch (e, stackTrace) {
      _log.e('Erro ao carregar agendamentos', error: e, stackTrace: stackTrace);
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao carregar agendamentos.');
    }
  }

  Future<AgendamentoModel> getAgendamentoById(int id) async {
    _log.d('Buscando agendamento: $id');
    try {
      final agendamento = await _service.getAgendamentoById(id);
      _log.t('Agendamento $id carregado');
      return agendamento;
    } catch (e) {
      _log.e('Erro ao carregar agendamento $id', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Agendamento não encontrado.');
        }
      }
      throw Exception('Erro ao carregar agendamento.');
    }
  }

  Future<AgendamentoModel> getAgendamentoByIdFull(int id) async {
    _log.i('Carregando detalhes completos do agendamento: $id');
    try {
      final agendamento = await _service.getAgendamentoByIdFull(id);
      _log.d('Detalhes do agendamento $id carregados com sucesso');
      return agendamento;
    } catch (e) {
      _log.e('Erro ao carregar detalhes do agendamento $id', error: e);
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
    _log.i('Criando novo agendamento - Carro: $carroId, Slot: $slotId, Serviços: $servicosIds');
    try {
      final dto = CreateAgendamentoDto(
        carroId: carroId,
        situacaoId: 1, // 1 = Agendado
        slotId: slotId,
        servicosIds: servicosIds,
      );
      final agendamento = await _service.createAgendamento(dto);
      _log.i('Agendamento criado com sucesso: ID ${agendamento.id}');
      return agendamento;
    } catch (e) {
      _log.e('Erro ao criar agendamento', error: e);
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
    _log.i('Cancelando agendamento: $id');
    try {
      await _service.cancelarAgendamento(id);
      _log.i('Agendamento $id cancelado com sucesso');
    } catch (e) {
      _log.e('Erro ao cancelar agendamento $id', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Não é possível cancelar este agendamento.');
        }
      }
      throw Exception('Erro ao cancelar agendamento.');
    }
  }

  Future<List<ProgramacaoDiariaModel>> getProgramacoesByEstabelecimento(int estabelecimentoId) async {
    _log.d('Carregando programações do estabelecimento: $estabelecimentoId');
    try {
      final programacoes = await _service.getProgramacoesByEstabelecimento(estabelecimentoId);
      _log.t('${programacoes.length} programações encontradas');
      return programacoes;
    } catch (e) {
      _log.e('Erro ao carregar programações', error: e);
      throw Exception('Erro ao carregar datas disponíveis.');
    }
  }

  Future<ProgramacaoDiariaModel?> getProgramacaoByData(int estabelecimentoId, DateTime data) async {
    _log.d('Carregando horários para $estabelecimentoId em ${data.toString().split(' ')[0]}');
    try {
      final dataFormatada = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
      final programacao = await _service.getProgramacaoByData(estabelecimentoId, dataFormatada);
      if (programacao != null) {
        _log.t('Programação encontrada para $dataFormatada');
      } else {
        _log.t('Nenhuma programação para $dataFormatada');
      }
      return programacao;
    } catch (e) {
      _log.e('Erro ao carregar horários', error: e);
      throw Exception('Erro ao carregar horários disponíveis.');
    }
  }
}
