import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

class ProfileRepository {
  final ProfileService _profileService;
  final FlutterSecureStorage _storage;

  ProfileRepository(this._profileService, this._storage);

  /// Busca os dados do cliente pelo ID
  Future<ClienteModel> getCliente(int clienteId) async {
    try {
      return await _profileService.getCliente(clienteId);
    } catch (e) {
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
    try {
      final dto = UpdateClienteDto(
        nome: nome,
        cpf: cpf?.replaceAll(RegExp(r'\D'), ''),
        email: email,
        fotoUrl: fotoUrl,
      );
      return await _profileService.updateCliente(clienteId, dto);
    } catch (e) {
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
    await _storage.delete(key: 'jwt_token');
  }
  
  /// Faz upload da foto de perfil para o servidor
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Se você tiver um endpoint específico para upload de imagem, use-o aqui
      // Por enquanto, vamos apenas retornar um caminho local
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final appDir = await getApplicationDocumentsDirectory();
      final savedImage = await imageFile.copy('${appDir.path}/$fileName');
      return savedImage.path;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  /// Verifica se o usuário está logado
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
