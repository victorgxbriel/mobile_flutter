import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/models/auth_models.dart';
import '../utils/jwt_utils.dart';

/// Serviço responsável por gerenciar os tokens de autenticação
class TokenService {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final String _baseUrl;

  // Keys de storage
  static const String accessTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';

  // Flag para evitar múltiplas chamadas de refresh simultâneas
  bool _isRefreshing = false;

  TokenService(this._storage, this._dio, this._baseUrl);

  /// Salva os tokens no storage
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: refreshTokenKey, value: refreshToken);
    }
  }

  /// Obtém o access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: accessTokenKey);
  }

  /// Obtém o refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: refreshTokenKey);
  }

  /// Limpa todos os tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  /// Verifica se o access token está expirado
  Future<bool> isAccessTokenExpired() async {
    final token = await getAccessToken();
    if (token == null) return true;
    return JwtUtils.isExpired(token);
  }

  /// Verifica se o refresh token está expirado
  Future<bool> isRefreshTokenExpired() async {
    final token = await getRefreshToken();
    if (token == null) return true;
    return JwtUtils.isExpired(token);
  }

  /// Tenta renovar o access token usando o refresh token
  /// Retorna true se conseguiu renovar, false caso contrário
  Future<bool> tryRefreshToken() async {
    // Evita múltiplas chamadas simultâneas
    if (_isRefreshing) {
      // Aguarda um pouco e verifica se o token foi atualizado
      await Future.delayed(const Duration(milliseconds: 500));
      final token = await getAccessToken();
      return token != null && !JwtUtils.isExpired(token);
    }

    _isRefreshing = true;

    try {
      final refreshToken = await getRefreshToken();
      
      if (refreshToken == null || JwtUtils.isExpired(refreshToken)) {
        await clearTokens();
        return false;
      }

      // Faz a chamada de refresh diretamente com Dio (sem passar pelo interceptor)
      final response = await _dio.post(
        '$_baseUrl/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final refreshResponse = RefreshTokenResponse.fromJson(response.data);
      
      // Salva os novos tokens
      await saveTokens(
        accessToken: refreshResponse.accessToken,
        refreshToken: refreshResponse.refreshToken,
      );

      return true;
    } on DioException catch (_) {
      // Refresh falhou - limpa tokens
      await clearTokens();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
