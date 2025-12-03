import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

final _log = logger(AuthServiceImpl);

abstract class AuthService {
  Future<LoginResponse> login(LoginDto dto);
  Future<UserModel> getCurrentUser();
  Future<RegisterResponse> register(RegisterDto dto);
  Future<void> registerClient(RegisterDto userDto, CreateClienteDto clientDto);
  Future<void> registerEstablishment(SetupEstabelecimentoDto setupDto);
  Future<RefreshTokenResponse> refreshToken(String refreshToken);
  Future<void> logout();
  Future<void> forgotPassword(ForgotPasswordDto dto);
  Future<void> resetPassword(ResetPasswordDto dto);
}

class AuthServiceImpl implements AuthService {
  final DioClient _client;

  AuthServiceImpl(this._client);

  @override
  Future<LoginResponse> login(LoginDto dto) async {
    _log.t('POST /auth/login');
    try {
      final response = await _client.instance.post( '/auth/login',
        data: dto.toJson(),
      );
      _log.t('Login response received');
      return LoginResponse.fromJson(response.data);
    } on DioException catch (_) {
      // Aqui você pode tratar erros específicos do NestJS (400, 401)
      rethrow; 
    }
  }

  @override
  Future<RegisterResponse> register(RegisterDto dto) async {
    _log.t('POST /auth/register');
    try {
      final response = await _client.instance.post( '/auth/register',
        data: dto.toJson(),
      );
      _log.t('Register response received');
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> registerClient(RegisterDto userDto, CreateClienteDto clientDto) async {
    _log.d('Registrando novo cliente...');
    
    // 1. Cria usuário no /auth/register
    await register(userDto);
    _log.t('Usuário criado');
    
    // 2. Faz login para obter o token
    final loginResponse = await login(LoginDto(
      email: userDto.email,
      password: userDto.password,
    ));
    _log.t('Login automático realizado');
    
    // 3. Salva o token temporariamente para a próxima requisição
    await _client.storage.write(key: 'jwt_token', value: loginResponse.accessToken);
    _log.t('Token salvo');
    
    // 4. Cria o cliente no /clientes (já autenticado)
    // o auth já cria o cliente
    //await _client.instance.post('/clientes', data: clientDto.toJson());
  }

  @override
  Future<void> registerEstablishment(SetupEstabelecimentoDto setupDto) async {
    _log.d('Registrando novo estabelecimento...');
    // Usa o endpoint /estabelecimentos/setup que cria usuário + estabelecimento
    await _client.instance.post('/estabelecimentos/setup', data: setupDto.toJson());
    _log.t('Estabelecimento criado');
  }

  @override
  Future<UserModel> getCurrentUser() async {
    _log.t('GET /auth/me');
    final response = await _client.instance.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  @override
  Future<RefreshTokenResponse> refreshToken(String refreshToken) async {
    _log.t('POST /auth/refresh');
    try {
      final response = await _client.instance.post( '/auth/refresh',
        data: RefreshTokenDto(refreshToken: refreshToken).toJson(),
      );
      _log.t('Token refreshed');
      return RefreshTokenResponse.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _log.t('POST /auth/logout');
    try {
      await _client.instance.post('/auth/logout');
    } on DioException catch (_) {
      // Ignora erros de logout, pois o importante é limpar os tokens localmente
    }
  }

  @override
  Future<void> forgotPassword(ForgotPasswordDto dto) async {
    _log.t('POST /auth/forgot-password');
    try {
      await _client.instance.post( '/auth/forgot-password',
        data: dto.toJson(),
        options: Options(
          // Timeout maior para envio de email
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      _log.t('Forgot password email sent');
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {
    _log.t('POST /auth/reset-password');
    try {
      await _client.instance.post( '/auth/reset-password',
        data: dto.toJson(),
        options: Options(
          // Timeout maior para operações de email
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );
      _log.t('Password reset successful');
    } on DioException catch (_) {
      rethrow;
    }
  }
}