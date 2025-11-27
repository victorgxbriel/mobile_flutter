import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter/features/auth/data/services/auth_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final AuthService _dataSource;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dataSource, this._storage);

  Future<UserModel> login(String email, String password) async {
    try {
      // 1. Faz o Login na API
      final loginDto = LoginDto(email: email, password: password);
      final response = await _dataSource.login(loginDto);

      // 2. Salva o Token no Celular (Segurança)
      await _storage.write(key: 'jwt_token', value: response.accessToken);

      // 3. Busca os dados completos do usuário (já com o token salvo)
      // O DioClient vai injetar o token automaticamente na requisição do /auth/me
      final user = await _dataSource.getCurrentUser();
      
      return user;
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
    await _storage.delete(key: 'jwt_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
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
}