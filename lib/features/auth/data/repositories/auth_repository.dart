import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter/features/auth/data/services/auth_service.dart';

import '../../../../core/services/token_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final AuthService _dataSource;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dataSource, this._storage);

  Future<String> login(String email, String password) async {
    try {
      // 1. Faz o Login na API
      final loginDto = LoginDto(email: email, password: password);
      final response = await _dataSource.login(loginDto);

      // 2. Salva os Tokens no Celular (Segurança)
      await _storage.write(key: TokenService.accessTokenKey, value: response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(key: TokenService.refreshTokenKey, value: response.refreshToken);
      }

      // 3. Retorna o token para o SessionService gerenciar
      return response.accessToken;
    } catch (e) {
      // Tratamento de erro simplificado para o exemplo
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('Email ou senha inválidos.');
        }
      }
      throw Exception('Erro ao realizar login: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Tenta fazer logout na API (invalida refresh token no servidor)
      await _dataSource.logout();
    } catch (_) {
      // Ignora erros - o importante é limpar localmente
    } finally {
      // Sempre limpa os tokens locais
      await _storage.delete(key: TokenService.accessTokenKey);
      await _storage.delete(key: TokenService.refreshTokenKey);
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: TokenService.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: TokenService.refreshTokenKey);
  }

  Future<void> register({
    required String nome,
    required String email,
    required String password,
    required String cpf,
  }) async {
    try {
      final dto = RegisterDto(
        nome: nome,
        email: email,
        password: password,
        cpf: cpf.replaceAll(RegExp(r'\D'), ''), // Remove pontos/traços do CPF por segurança
      );
      
      await _dataSource.register(dto);
      // Não precisamos retornar nada se der certo, apenas se der erro (catch)
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Dados inválidos. Verifique CPF ou Email.');
      }
      throw Exception('Erro ao registrar usuário.');
    }
  }

  Future<void> registerClient({
    required String nome,
    required String email,
    required String password,
    required String cpf,
  }) async {
    try {
      // Prepara DTO de usuário
      final userDto = RegisterDto(
        nome: nome,
        email: email,
        password: password,
        cpf: cpf.replaceAll(RegExp(r'\D'), ''),
      );
      
      // Prepara DTO de cliente (para o endpoint /clientes)
      final clientDto = CreateClienteDto(
        nome: nome,
        cpf: cpf.replaceAll(RegExp(r'\D'), ''),
        email: email,
      );
      
      await _dataSource.registerClient(userDto, clientDto);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Dados inválidos. Verifique CPF ou Email.');
      }
      throw Exception('Erro ao registrar cliente.');
    }
  }

  Future<void> registerEstablishment({
    required String nome,
    required String email,
    required String password,
    required String cnpj,
    required String nomeFantasia,
  }) async {
    try {
      // O endpoint /estabelecimentos/setup espera os dados do setup
      final setupDto = SetupEstabelecimentoDto(
        usuario: UsuarioSetupDto(
          nome: nome,
          email: email,
          password: password,
        ),
        estabelecimento: EstabelecimentoSetupDto(
          cnpj: cnpj.replaceAll(RegExp(r'\D'), ''), // Remove formatação
          nomeFantasia: nomeFantasia,
        ),
      );
      
      await _dataSource.registerEstablishment(setupDto);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Dados inválidos. Verifique CNPJ ou Email.');
      }
      throw Exception('Erro ao registrar estabelecimento.');
    }
  }
  
  Future<UserModel?> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return null;
      
      // Se você já tem o ID do usuário no token ou em outro lugar, use-o
      // Caso contrário, você pode precisar decodificar o JWT para obter o ID
      // Vou assumir que o token JWT contém o ID do usuário
      
      final response = await _dataSource.getCurrentUser();
      return response;
    } catch (e) {
      print('Erro ao obter usuário atual: $e');
      return null;
    }
  }

}