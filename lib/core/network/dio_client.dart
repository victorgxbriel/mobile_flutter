import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/token_service.dart';
import 'interceptors/auth_interceptor.dart';

import '../errors/exceptions.dart';
import 'network_info.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final NetworkInfo _networkInfo;
  late final TokenService _tokenService;

  // Base URL configurável
  static const String baseUrl = 'https://abluocar.up.railway.app';
  // static const String baseUrl = 'http://10.0.2.2:3000'; // Para Android Emulator

  DioClient(this._dio, this._storage, this._networkInfo, {OnTokenExpired? onTokenExpired}) {
    // Configura o baseUrl
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Cria o TokenService com um Dio separado (sem interceptors)
    final refreshDio = Dio();
    _tokenService = TokenService(_storage, refreshDio, baseUrl);

    // Adicionar interceptors
    _dio.interceptors.add(AuthInterceptor(
      _storage,
      _tokenService,
      onTokenExpired: onTokenExpired,
    ));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if(!await _networkInfo.isConnected) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: NoInternetException(),
              type: DioExceptionType.unknown
            )
          );
        }

        return handler.next(options);
      }
    ));
  }

  Dio get instance => _dio;
  FlutterSecureStorage get storage => _storage;
  TokenService get tokenService => _tokenService;
}