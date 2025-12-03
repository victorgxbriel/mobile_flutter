import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/utils/app_logger.dart';
import '../../features/auth/data/models/auth_models.dart';
import '../utils/jwt_utils.dart';

final _log = logger(TokenService);

/// Serviço responsável por gerenciar os tokens de autenticação
class TokenService {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final String _baseUrl;

  static const String accessTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';

  // Flag para evitar múltiplas chamadas de refresh simultâneas
  bool _isRefreshing = false;

  TokenService(this._storage, this._dio, this._baseUrl);

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _log.d('Salvando tokens...');
    await _storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: refreshTokenKey, value: refreshToken);
    }
    _log.t('Tokens salvos com sucesso');
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  Future<void> clearTokens() async {
    _log.d('Limpando tokens...');
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
    _log.i('Tokens removidos');
  }

  Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null) return true;
    return JwtUtils.isExpired(token);
  }

  Future<bool> isRefreshTokenExpired() async {
    final token = await getRefreshToken();
    if (token == null) return true;
    return JwtUtils.isExpired(token);
  }

  /// Retorna true se conseguiu renovar, false caso contrário
  Future<bool> tryRefreshToken() async {
    if (_isRefreshing) {
      _log.d('Refresh já em andamento, aguardando...');
      await Future.delayed(const Duration(milliseconds: 500));
      final token = await getAccessToken();
      return token != null && !JwtUtils.isExpired(token);
    }

    _isRefreshing = true;
    _log.i('Iniciando refresh de token...');

    try {
      final refreshToken = await getRefreshToken();
      
      if (refreshToken == null || JwtUtils.isExpired(refreshToken)) {
        _log.w('Refresh token inválido ou expirado');
        await clearTokens();
        return false;
      }

      _log.d('Chamando endpoint de refresh...');
      // Faz a chamada de refresh diretamente com Dio (sem passar pelo interceptor)
      final response = await _dio.post( '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      
      await saveTokens(
        accessToken: refreshResponse.accessToken,
        refreshToken: refreshResponse.refreshToken,
      );

      _log.i('Token renovado com sucesso');
      return true;
    } on DioException catch (e) {
      _log.e('Erro ao renovar token: ${e.response?.statusCode}', error: e);
      await clearTokens();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
