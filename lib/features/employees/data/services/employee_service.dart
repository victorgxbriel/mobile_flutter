import 'package:dio/dio.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/employee_model.dart';

final _log = logger(EmployeeServiceImpl);

abstract class EmployeeService {
  /// Lista todos os funcionários do estabelecimento
  Future<List<EmployeeModel>> getEmployeesByEstabelecimento(
    int estabelecimentoId,
  );

  /// Busca um funcionário específico do estabelecimento
  Future<EmployeeModel> getEmployeeById(int estabelecimentoId, int usuarioId);

  /// Cria um novo funcionário
  Future<EmployeeModel> createEmployee(
    int estabelecimentoId,
    CreateEmployeeDto dto,
  );

  /// Atualiza um funcionário existente
  Future<EmployeeModel> updateEmployee(
    int estabelecimentoId,
    int usuarioId,
    UpdateEmployeeDto dto,
  );

  /// Busca os papéis de um funcionário específico
  Future<List<int>> getEmployeeRoles(
    int estabelecimentoId,
    int usuarioId,
  );

  /// Busca todos os papéis disponíveis
  Future<List<RoleModel>> getAvailableRoles(int estabelecimentoId);
}

class EmployeeServiceImpl implements EmployeeService {
  final DioClient _client;

  EmployeeServiceImpl(this._client);

  @override
  Future<List<EmployeeModel>> getEmployeesByEstabelecimento(
    int estabelecimentoId,
  ) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/usuarios');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/usuarios',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => EmployeeModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> getEmployeeById(
    int estabelecimentoId,
    int usuarioId,
  ) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/usuarios/$usuarioId');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/usuarios/$usuarioId',
      );
      return EmployeeModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> createEmployee(
    int estabelecimentoId,
    CreateEmployeeDto dto,
  ) async {
    _log.t('POST /estabelecimentos/$estabelecimentoId/usuarios');
    try {
      final response = await _client.instance.post(
        '/estabelecimentos/$estabelecimentoId/usuarios',
        data: dto.toJson(),
      );
      _log.t('Funcionário criado: ID ${response.data['id']}');
      return EmployeeModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<EmployeeModel> updateEmployee(
    int estabelecimentoId,
    int usuarioId,
    UpdateEmployeeDto dto,
  ) async {
    _log.t('PATCH /estabelecimentos/$estabelecimentoId/usuarios/$usuarioId');
    try {
      final response = await _client.instance.patch(
        '/estabelecimentos/$estabelecimentoId/usuarios/$usuarioId',
        data: dto.toJson(),
      );
      _log.t('Funcionário atualizado');
      return EmployeeModel.fromJson(response.data);
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<int>> getEmployeeRoles(
    int estabelecimentoId,
    int usuarioId,
  ) async {
    _log.t(
      'GET /estabelecimentos/$estabelecimentoId/usuarios/$usuarioId/papeis',
    );
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/usuarios/$usuarioId/papeis',
      );
      final List<dynamic> data = response.data;
      return data.map((json) => json['roleId'] as int).toList();
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<RoleModel>> getAvailableRoles(int estabelecimentoId) async {
    _log.t('GET /estabelecimentos/$estabelecimentoId/usuarios/papeis');
    try {
      final response = await _client.instance.get(
        '/estabelecimentos/$estabelecimentoId/usuarios/papeis',
      );
      final List<dynamic> data = response.data;
      final roles = data.map((json) => RoleModel.fromJson(json)).toList();
      // Filtrar ADMIN e CLIENTE
      return roles
          .where((role) => role.nome != 'ADMIN' && role.nome != 'CLIENTE')
          .toList();
    } on DioException catch (_) {
      rethrow;
    }
  }
}
