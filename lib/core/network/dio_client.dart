import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'interceptors/auth_interceptor.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._dio, this._storage) {
    // ⚠️ IMPORTANTE: Configure o baseUrl de acordo com seu ambiente:
    // - Emulador Android: 'http://10.0.2.2:3000'
    // - iOS Simulator: 'http://localhost:3000' ou 'http://127.0.0.1:3000'
    // - Dispositivo físico: 'http://SEU_IP_LOCAL:3000' (ex: http://192.168.0.10:3000)
    // - Produção: 'https://sua-api.com'
    _dio.options.baseUrl = 'https://abluocar.up.railway.app/'; // Padrão para Android Emulator 
    
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Adicionar interceptors
    _dio.interceptors.add(AuthInterceptor(_storage));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Dio get instance => _dio;
  FlutterSecureStorage get storage => _storage;
}