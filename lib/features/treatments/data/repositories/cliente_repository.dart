import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../models/cliente_model.dart';
import '../services/cliente_service.dart';

final _log = logger(ClienteRepository);

class ClienteRepository {
  final ClienteService _service;
  final SessionService _sessionService;

  ClienteRepository(this._service, this._sessionService);

  int? get _estabelecimentoId => _sessionService.estabelecimentoId;

  /// Lista todos os clientes do estabelecimento atual
  Future<List<ClienteModel>> getClientes() async {
    final estabelecimentoId = _estabelecimentoId;
    if (estabelecimentoId == null) {
      _log.w('estabelecimentoId não disponível - perfil não carregado');
      throw Exception('Perfil não carregado. Aguarde ou faça login novamente.');
    }
    _log.i('Carregando clientes do estabelecimento: $estabelecimentoId');
    try {
      final clientes = await _service.getClientesByEstabelecimento(
        estabelecimentoId,
      );
      _log.d('${clientes.length} clientes encontrados');
      return clientes;
    } catch (e, stackTrace) {
      _log.e('Erro ao carregar clientes', error: e, stackTrace: stackTrace);
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao carregar clientes.');
    }
  }

  /// Busca um cliente por ID
  Future<ClienteModel> getClienteById(int id) async {
    _log.d('Buscando cliente: $id');
    try {
      final cliente = await _service.getClienteById(id);
      _log.t('Cliente $id carregado');
      return cliente;
    } catch (e) {
      _log.e('Erro ao carregar cliente $id', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Cliente não encontrado.');
        }
      }
      throw Exception('Erro ao carregar cliente.');
    }
  }

  /// Busca os carros de um cliente
  Future<List<ClienteCarroModel>> getCarrosByCliente(int clienteId) async {
    _log.d('Buscando carros do cliente: $clienteId');
    try {
      final carros = await _service.getCarrosByCliente(clienteId);
      _log.t('${carros.length} carros encontrados para cliente $clienteId');
      return carros;
    } catch (e) {
      _log.e('Erro ao carregar carros do cliente $clienteId', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Cliente não encontrado.');
        }
      }
      throw Exception('Erro ao carregar carros do cliente.');
    }
  }
}
