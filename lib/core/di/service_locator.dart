import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/estabelecimento/data/repositories/estabelecimento_details_repository.dart';
import '../../features/estabelecimento/data/services/estabelecimento_details_service.dart';
import '../../features/home/data/repositories/estabelecimento_repository.dart';
import '../../features/home/data/services/estabelecimento_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/data/services/profile_service.dart';
import '../network/dio_client.dart';
import '../services/session_service.dart';
import '../storage/storage_service.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // Singletons
  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  late final DioClient _dioClient;
  late final AuthService _authService;
  late final AuthRepository _authRepository;
  late final ProfileService _profileService;
  late final ProfileRepository _profileRepository;
  late final EstabelecimentoService _estabelecimentoService;
  late final EstabelecimentoRepository _estabelecimentoRepository;
  late final EstabelecimentoDetailsService _estabelecimentoDetailsService;
  late final EstabelecimentoDetailsRepository _estabelecimentoDetailsRepository;
  late final SharedPreferences _sharedPreferences;
  late final StorageService _storageService;
  late final SessionService _sessionService;

  Future<void> init() async {
    if (_initialized) return;
    
    _dio = Dio();
    _storage = const FlutterSecureStorage();
    _sharedPreferences = await SharedPreferences.getInstance();
    _sessionService = SessionService(_storage);
    
    // Inicializa DioClient com callback de sessão expirada
    _dioClient = DioClient(
      _dio, 
      _storage,
      onTokenExpired: () => _sessionService.handleSessionExpired(),
    );
    
    _authService = AuthServiceImpl(_dioClient);
    _authRepository = AuthRepository(_authService, _storage);
    _profileService = ProfileServiceImpl(_dioClient);
    _profileRepository = ProfileRepository(_profileService, _storage);
    _estabelecimentoService = EstabelecimentoServiceImpl(_dioClient);
    _estabelecimentoRepository = EstabelecimentoRepository(_estabelecimentoService);
    _estabelecimentoDetailsService = EstabelecimentoDetailsServiceImpl(_dioClient);
    _estabelecimentoDetailsRepository = EstabelecimentoDetailsRepository(_estabelecimentoDetailsService);
    _storageService = StorageServiceImpl(_sharedPreferences);
    
    // Inicializa a sessão (verifica token existente)
    await _sessionService.init();
    
    _initialized = true;
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  ProfileRepository get profileRepository => _profileRepository;
  EstabelecimentoRepository get estabelecimentoRepository => _estabelecimentoRepository;
  EstabelecimentoDetailsRepository get estabelecimentoDetailsRepository => _estabelecimentoDetailsRepository;
  FlutterSecureStorage get storage => _storage;
  StorageService get storageService => _storageService;
  SessionService get sessionService => _sessionService;
}
