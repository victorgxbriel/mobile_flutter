import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../network/dio_client.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Singletons
  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  late final DioClient _dioClient;
  late final AuthService _authService;
  late final AuthRepository _authRepository;

  void init() {
    _dio = Dio();
    _storage = const FlutterSecureStorage();
    _dioClient = DioClient(_dio, _storage);
    _authService = AuthServiceImpl(_dioClient);
    _authRepository = AuthRepository(_authService, _storage);
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  FlutterSecureStorage get storage => _storage;
}
