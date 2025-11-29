import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_models.dart';

abstract class AuthService {
  Future<LoginResponse> login(LoginDto dto);
  Future<UserModel> getCurrentUser();
  Future<RegisterResponse> register(RegisterDto dto);
  Future<void> registerClient(RegisterDto userDto, CreateClienteDto clientDto);
  Future<void> registerEstablishment(SetupEstabelecimentoDto setupDto);
}

class AuthServiceImpl implements AuthService {
  final DioClient _client;

  AuthServiceImpl(this._client);

  @override
  Future<LoginResponse> login(LoginDto dto) async {
    try {
      final response = await _client.instance.post(
        '/auth/login',
        data: dto.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Aqui você pode tratar erros específicos do NestJS (400, 401)
      throw e; 
    }
  }

  @override
  Future<RegisterResponse> register(RegisterDto dto) async {
    try {
      final response = await _client.instance.post(
        '/auth/register',
        data: dto.toJson(),
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e;
    }
  }

  @override
  Future<void> registerClient(RegisterDto userDto, CreateClienteDto clientDto) async {
    // 1. Cria usuário no /auth/register
    await register(userDto);
    
    // 2. Faz login para obter o token
    final loginResponse = await login(LoginDto(
      email: userDto.email,
      password: userDto.password,
    ));
    
    // 3. Salva o token temporariamente para a próxima requisição
    await _client.storage.write(key: 'jwt_token', value: loginResponse.accessToken);
    
    // 4. Cria o cliente no /clientes (já autenticado)
    // o auth já cria o cliente
    //await _client.instance.post('/clientes', data: clientDto.toJson());
  }

  @override
  Future<void> registerEstablishment(SetupEstabelecimentoDto setupDto) async {
    // Usa o endpoint /estabelecimentos/setup que cria usuário + estabelecimento
    await _client.instance.post('/estabelecimentos/setup', data: setupDto.toJson());
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _client.instance.get('/auth/me');
    return UserModel.fromJson(response.data);
  }
}