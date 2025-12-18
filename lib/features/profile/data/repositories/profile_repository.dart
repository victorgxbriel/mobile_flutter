import 'dart:io';
import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/services/session_service.dart';
import 'package:path_provider/path_provider.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

final _log = logger(ProfileRepository);

class ProfileRepository {
  final ProfileService _profileService;
  final SessionService _sessionService;

  ProfileRepository(this._profileService, this._sessionService);

  /// Busca os dados do cliente pelo ID
  Future<ClienteModel> getCliente(int clienteId) async {
    _log.i('Buscando perfil do cliente: $clienteId');
    try {
      final cliente = await _profileService.getCliente(clienteId);
      _log.d('Perfil carregado: ${cliente.nome}');
      return cliente;
    } catch (e) {
      _log.e('Erro ao buscar perfil', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('Cliente não encontrado.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao buscar dados do perfil.');
    }
  }

  /// Atualiza os dados do cliente
  Future<ClienteModel> updateCliente(int clienteId, {
    String? nome,
    String? cpf,
    String? email,
    String? fotoUrl,
  }) async {
    _log.i('Atualizando perfil do cliente: $clienteId');
    try {
      final dto = UpdateClienteDto(
        nome: nome,
        cpf: cpf?.replaceAll(RegExp(r'\D'), ''),
        email: email,
        fotoUrl: fotoUrl,
      );
      final cliente = await _profileService.updateCliente(clienteId, dto);
      _log.i('Perfil atualizado');
      return cliente;
    } catch (e) {
      _log.e('Erro ao atualizar perfil', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Dados inválidos.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao atualizar perfil.');
    }
  }

  /// Realiza o logout (limpa os tokens)
  Future<void> logout() async {
    _log.i('Realizando logout...');
    await _sessionService.logout();
    _log.i('Logout realizado');
  }
  
  /// Faz upload da foto de perfil para o servidor
  Future<String> uploadProfileImage(File imageFile) async {
    _log.i('Fazendo upload da foto de perfil...');
    try {
      // Se você tiver um endpoint específico para upload de imagem, use-o aqui
      // Por enquanto, vamos apenas retornar um caminho local
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      _log.d('Imagem salva em: ${savedImage.path}');
      return savedImage.path;
    } catch (e) {
      _log.e('Erro ao fazer upload da imagem', error: e);
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<EstabelecimentoModel> getEstabelecimento(int estabelecimentoId) async {
    _log.i('Buscando perfil do estabelecimento: $estabelecimentoId');
    try {
      final estabelecimento = await _profileService.getEstabelecimento(estabelecimentoId);
      _log.d('Perfil carregado: ${estabelecimento.nomeFantasia}');
      return estabelecimento;
    } catch (e) {
      _log.e('Erro ao buscar perfil', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('estabelecimento não encontrado.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao buscar dados do perfil.');
    }
  }

  Future<EstabelecimentoModel> updateEstabelecimento(int estabelecimentoId, {
    String? nomeFantasia,
    String? cnpj,
  }) async {
    _log.i('Atualizando perfil do estabelecimento: $estabelecimentoId');
    try {
      final dto = UpdateEstabelecimentoDto(
        nomeFantasia: nomeFantasia,
        cnpj: cnpj?.replaceAll(RegExp(r'\D'), ''),
      );
      final estabelecimento = await _profileService.updateEstabelecimento(estabelecimentoId, dto);
      _log.i('Perfil atualizado');
      return estabelecimento;
    } catch (e) {
      _log.e('Erro ao atualizar perfil', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Dados inválidos.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('Sessão expirada. Faça login novamente.');
        }
      }
      throw Exception('Erro ao atualizar perfil.');
    }
  }

  /// Verifica se o usuário está logado
  bool isLoggedIn() {
    final isLogged = _sessionService.isAuthenticated;
    _log.t('Usuário logado: $isLogged');
    return isLogged;
  }
}
