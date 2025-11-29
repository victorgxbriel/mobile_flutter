import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/auth_service.dart';
import '../../features/profile/data/repositories/profile_repository.dart';
import '../../features/profile/data/services/profile_service.dart';
import '../network/dio_client.dart';
import '../storage/storage_service.dart';

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
  late final ProfileService _profileService;
  late final ProfileRepository _profileRepository;
  late final SharedPreferences _sharedPreferences;
  late final StorageService _storageService;

  Future<void> init() async {
    _dio = Dio();
    _storage = const FlutterSecureStorage();
    _sharedPreferences = await SharedPreferences.getInstance();
    _dioClient = DioClient(_dio, _storage);
    _authService = AuthServiceImpl(_dioClient);
    _authRepository = AuthRepository(_authService, _storage);
    _profileService = ProfileServiceImpl(_dioClient);
    _profileRepository = ProfileRepository(_profileService, _storage);
    _storageService = StorageServiceImpl(_sharedPreferences);
  }

  // Getters
  AuthRepository get authRepository => _authRepository;
  ProfileRepository get profileRepository => _profileRepository;
  FlutterSecureStorage get storage => _storage;
  StorageService get storageService => _storageService;
}
