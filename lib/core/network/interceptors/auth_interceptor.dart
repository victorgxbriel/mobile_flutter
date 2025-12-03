import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/token_service.dart';
import '../../utils/jwt_utils.dart';

/// Callback chamado quando o token expira ou é inválido
typedef OnTokenExpired = void Function();

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final TokenService tokenService;
  final OnTokenExpired? onTokenExpired;

  AuthInterceptor(
    this.storage,
    this.tokenService, {
    this.onTokenExpired,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Não adiciona token em rotas públicas
    if (_isPublicRoute(options.path)) {
      handler.next(options);
      return;
    }

    // Carregar JWT do storage
    String? token = await storage.read(key: TokenService.accessTokenKey);

    if (token != null && token.isNotEmpty) {
      // Verificar se o token está expirado ANTES de fazer a requisição
      if (JwtUtils.isExpired(token)) {
        final refreshed = await tokenService.tryRefreshToken();
        
        if (refreshed) {
          token = await storage.read(key: TokenService.accessTokenKey);
        } else {
          onTokenExpired?.call();
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              error: 'Sessão expirada. Faça login novamente.',
            ),
          );
          return;
        }
      }

      if (token != null) {
        options.headers["Authorization"] = "Bearer $token";
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (_isAuthRoute(err.requestOptions.path)) {
        handler.next(err);
        return;
      }

      final refreshed = await tokenService.tryRefreshToken();

      if (refreshed) {
        try {
          final newToken = await storage.read(key: TokenService.accessTokenKey);
          
          final opts = err.requestOptions;
          opts.headers["Authorization"] = "Bearer $newToken";

          // Cria um novo Dio sem interceptors para evitar loop
          final dio = Dio(BaseOptions(
            baseUrl: opts.baseUrl,
            connectTimeout: opts.connectTimeout,
            receiveTimeout: opts.receiveTimeout,
          ));

          final response = await dio.fetch(opts);
          handler.resolve(response);
          return;
        } catch (e) {
          // Se a requisição falhar novamente, continua com o erro original
        }
      }

      // Refresh falhou - limpa token e notifica
      await tokenService.clearTokens();
      onTokenExpired?.call();
    }

    handler.next(err);
  }

  /// Verifica se é uma rota pública (não precisa de token)
  bool _isPublicRoute(String path) {
    final publicRoutes = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/google',
      '/auth/google/redirect',
      '/health',
      '/',
    ];
    return publicRoutes.any((route) => path.endsWith(route));
  }

  /// Verifica se é uma rota de autenticação
  bool _isAuthRoute(String path) {
    return path.contains('/auth/');
  }
}
