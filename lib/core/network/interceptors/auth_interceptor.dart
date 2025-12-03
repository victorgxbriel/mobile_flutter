import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../app/utils/app_logger.dart';
import '../../services/token_service.dart';
import '../../utils/jwt_utils.dart';

final _log = logger(AuthInterceptor);

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
    _log.t('Request: ${options.method} ${options.path}');
    
    // Não adiciona token em rotas públicas
    if (_isPublicRoute(options.path)) {
      _log.d('Rota publica, sem token necessario');
      handler.next(options);
      return;
    }

    // Carregar JWT do storage
    String? token = await storage.read(key: TokenService.accessTokenKey);

    if (token != null && token.isNotEmpty) {
      // Verificar se o token está expirado ANTES de fazer a requisição
      if (JwtUtils.isExpired(token)) {
        _log.w('Token expirado, tentando refresh...');
        final refreshed = await tokenService.tryRefreshToken();
        
        if (refreshed) {
          token = await storage.read(key: TokenService.accessTokenKey);
          _log.i('Token renovado com sucesso');
        } else {
          _log.e('Falha ao renovar token - sessão expirada');
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
        _log.t('Token adicionado ao header');
      }
    } else {
      _log.d('Nenhum token disponivel');
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _log.w('Erro na requisição: ${err.response?.statusCode} - ${err.requestOptions.path}');
    
    if (err.response?.statusCode == 401) {
      _log.w('Erro 401 - Nao autorizado');
      
      if (_isAuthRoute(err.requestOptions.path)) {
        _log.d('Rota de auth, propagando erro...');
        handler.next(err);
        return;
      }

      _log.i('Tentando refresh do token...');
      final refreshed = await tokenService.tryRefreshToken();

      if (refreshed) {
        _log.i('Token renovado, retentando requisição...');
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
          _log.i('Requisição retentada com sucesso');
          handler.resolve(response);
          return;
        } catch (e) {
          _log.e('Falha ao retentar requisição', error: e);
          // Se a requisição falhar novamente, continua com o erro original
        }
      }

      // Refresh falhou - limpa token e notifica
      _log.e('Refresh falhou - limpando sessão');
      await tokenService.clearTokens();
      onTokenExpired?.call();
    }

    handler.next(err);
  }

  /// Verifica se é uma rota pública (não precisa de token)
  bool _isPublicRoute(String path) {
    final publicRoutes = [ '/auth/login', '/auth/register', '/auth/refresh', '/auth/forgot-password', '/auth/reset-password', '/auth/google', '/auth/google/redirect', '/health', '/',
    ];
    return publicRoutes.any((route) => path.endsWith(route));
  }

  /// Verifica se é uma rota de autenticação
  bool _isAuthRoute(String path) {
    return path.contains('/auth/');
  }
}
