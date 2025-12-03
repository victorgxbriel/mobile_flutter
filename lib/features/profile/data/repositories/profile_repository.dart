import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:path_provider/path_provider.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

final _log = logger(ProfileRepository);

class ProfileRepository {
  final ProfileService _profileService;
  final FlutterSecureStorage _storage;

  ProfileRepository(this._profileService, this._storage);

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

  /// Realiza o logout (limpa o token)
  Future<void> logout() async {
    _log.i('Realizando logout...');
    await _storage.delete(key: 'jwt_token');
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

  /// Verifica se o usuário está logado
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    final isLogged = token != null && token.isNotEmpty;
    _log.t('Usuário logado: $isLogged');
    return isLogged;
  }
}
