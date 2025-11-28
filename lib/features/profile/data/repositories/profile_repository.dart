import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  }) async {
    try {
      final dto = UpdateClienteDto(
        nome: nome,
        cpf: cpf?.replaceAll(RegExp(r'\D'), ''),
        email: email,
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

  /// Verifica se o usuário está logado
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null && token.isNotEmpty;
  }
}
