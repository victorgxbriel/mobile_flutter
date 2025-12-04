import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/features/auth/data/services/auth_service.dart';

import '../../../../core/services/token_service.dart';
import '../models/auth_models.dart';

final _log = logger(AuthRepository);

class AuthRepository {
  final AuthService _dataSource;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dataSource, this._storage);

  Future<String> login(String email, String password) async {
    _log.i('Tentando login para: $email');
    try {
      // 1. Faz o Login na API
      final loginDto = LoginDto(email: email, password: password);
      final response = await _dataSource.login(loginDto);
      _log.d('Login API response recebido');

      // 2. Salva os Tokens no Celular (Segurança)
      await _storage.write(key: TokenService.accessTokenKey, value: response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(key: TokenService.refreshTokenKey, value: response.refreshToken);
      }
      _log.i('Login realizado com sucesso');

      // 3. Retorna o token para o SessionService gerenciar
      return response.accessToken;
    } catch (e) {
      _log.e('Erro no login', error: e);
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
    _log.i('Iniciando logout...');
    try {
      // Tenta fazer logout na API (invalida refresh token no servidor)
      await _dataSource.logout();
      _log.d('Logout na API realizado');
    } catch (e) {
      _log.w('Erro ao fazer logout na API (ignorando)', error: e);
      // Ignora erros - o importante é limpar localmente
    } finally {
      // Sempre limpa os tokens locais
      await _storage.delete(key: TokenService.accessTokenKey);
      await _storage.delete(key: TokenService.refreshTokenKey);
      _log.i('Tokens locais removidos');
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
    _log.i('Registrando novo usuário: $email');
    try {
      final dto = RegisterDto(
        nome: nome,
        email: email,
        password: password,
        cpf: cpf.replaceAll(RegExp(r'\D'), ''), // Remove pontos/traços do CPF por segurança
      );
      
      await _dataSource.register(dto);
      _log.i('Usuário registrado com sucesso');
      // Não precisamos retornar nada se der certo, apenas se der erro (catch)
    } catch (e) {
      _log.e('Erro ao registrar usuário', error: e);
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
    _log.i('Registrando novo cliente: $email');
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
      _log.i('Cliente registrado com sucesso');
    } catch (e) {
      _log.e('Erro ao registrar cliente', error: e);
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
    _log.i('Registrando novo estabelecimento: $nomeFantasia');
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
      _log.i('Estabelecimento registrado com sucesso');
    } catch (e) {
      _log.e('Erro ao registrar estabelecimento', error: e);
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Dados inválidos. Verifique CNPJ ou Email.');
      }
      throw Exception('Erro ao registrar estabelecimento.');
    }
  }
  
  /// Busca o perfil completo do usuário (incluindo clienteId/estabelecimentoId)
  Future<ProfileModel?> getProfile() async {
    _log.d('Buscando perfil do usuário...');
    try {
      final token = await _storage.read(key: TokenService.accessTokenKey);
      if (token == null) {
        _log.w('Nenhum token encontrado');
        return null;
      }
      
      final profile = await _dataSource.getProfile();
      _log.d('Perfil obtido: ${profile.email} (clienteId: ${profile.clienteId}, estabelecimentoId: ${profile.estabelecimentoId})');
      return profile;
    } catch (e) {
      _log.e('Erro ao obter perfil', error: e);
      return null;
    }
  }

  Future<void> forgotPassword(String email) async {
    _log.i('Solicitando recuperação de senha para: $email');
    try {
      final dto = ForgotPasswordDto(email: email);
      await _dataSource.forgotPassword(dto);
      _log.i('Email de recuperação enviado');
    } catch (e) {
      _log.e('Erro ao solicitar recuperação', error: e);
      if (e is DioException) {
        // API retorna 200 mesmo se email não existir (por segurança)
        // Então só tratamos erros de rede
        if (e.type == DioExceptionType.connectionError) {
          throw Exception('Erro de conexão. Verifique sua internet.');
        }
      }
      throw Exception('Erro ao solicitar recuperação de senha.');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _log.i('Redefinindo senha para: $email');
    try {
      final dto = ResetPasswordDto(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      await _dataSource.resetPassword(dto);
      _log.i('Senha redefinida com sucesso');
    } catch (e) {
      _log.e('Erro ao redefinir senha', error: e);
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Código inválido ou expirado.');
        }
      }
      throw Exception('Erro ao redefinir senha.');
    }
  }

}