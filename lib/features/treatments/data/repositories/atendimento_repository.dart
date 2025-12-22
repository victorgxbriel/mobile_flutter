import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../models/atendimento_model.dart';
import '../models/create_atendimento_dto.dart';
import '../services/atendimento_service.dart';

final _log = logger(AtendimentoRepository);

class AtendimentoRepository {
  final AtendimentoService _service;
  final SessionService _sessionService;

  AtendimentoRepository(this._service, this._sessionService);

  int? get _estabelecimentoId => _sessionService.estabelecimentoId;

  Future<List<AtendimentoModel>> getAtendimentos() async {
    final estabelecimentoId = _estabelecimentoId;
    if (estabelecimentoId == null) {
      _log.w('estabelecimentoId não disponível - perfil não carregado');
      throw Exception('Perfil não carregado. Aguarde ou faça login novamente.');
    }
    _log.i('Carregando atendimentos do estabelecimento: $estabelecimentoId');
    try {
      final atendimentos = await _service.getAtendimentosByEstabelecimentoId(
        estabelecimentoId,
      );
      _log.d('${atendimentos.length} atendimentos encontrados');
      return atendimentos;
    } catch (e, stackTrace) {
      _log.e('Erro ao carregar atendimentos', error: e, stackTrace: stackTrace);
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao carregar atendimentos.');
    }
  }

  Future<AtendimentoModel> getAtendimentoById(int id) async {
    _log.d('Buscando atendimento: $id');
    try {
      final atendimento = await _service.getAtendimentoById(id);
      _log.t('Atendimento $id carregado');
      return atendimento;
    } catch (e) {
      _log.e('Erro ao carregar atendimento $id', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Atendimento não encontrado.');
        }
      }
      throw Exception('Erro ao carregar atendimento.');
    }
  }

  /// Cria um novo atendimento
  Future<AtendimentoModel> createAtendimento({
    required int clienteId,
    required int carroId,
    required List<CreateServicoAtendimentoItem> servicos,
    List<CreateAcessorioAtendimentoItem>? acessorios,
  }) async {
    final estabelecimentoId = _estabelecimentoId;
    if (estabelecimentoId == null) {
      _log.w('estabelecimentoId não disponível - perfil não carregado');
      throw Exception('Perfil não carregado. Aguarde ou faça login novamente.');
    }

    _log.i('Criando atendimento para cliente $clienteId, carro $carroId');
    try {
      final dto = CreateAtendimentoDto(
        estabelecimentoId: estabelecimentoId,
        clienteId: clienteId,
        carroId: carroId,
        servicos: servicos,
        acessorios: acessorios,
        situacaoId: 1, // Em Espera
      );

      final atendimento = await _service.createAtendimento(dto);
      _log.d('Atendimento criado: ID ${atendimento.id}');
      return atendimento;
    } catch (e, stackTrace) {
      _log.e('Erro ao criar atendimento', error: e, stackTrace: stackTrace);
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
        if (e.response?.statusCode == 400) {
          throw Exception(
            'Dados inválidos. Verifique os campos e tente novamente.',
          );
        }
      }
      throw Exception('Erro ao criar atendimento.');
    }
  }
}
