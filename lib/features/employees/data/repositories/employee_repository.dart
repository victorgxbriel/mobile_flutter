import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

final _log = logger(EmployeeRepository);

class EmployeeRepository {
  final EmployeeService _service;

  EmployeeRepository(this._service);

  Future<List<EmployeeModel>> getEmployeesByEstabelecimento(
    int estabelecimentoId,
  ) async {
    try {
      return await _service.getEmployeesByEstabelecimento(estabelecimentoId);
    } catch (e) {
      _log.e('Erro ao buscar funcionários do estabelecimento', error: e);
      rethrow;
    }
  }

  Future<EmployeeModel> getEmployeeById(
    int estabelecimentoId,
    int usuarioId,
  ) async {
    try {
      return await _service.getEmployeeById(estabelecimentoId, usuarioId);
    } catch (e) {
      _log.e('Erro ao buscar funcionário', error: e);
      rethrow;
    }
  }

  Future<EmployeeModel> createEmployee(
    int estabelecimentoId,
    CreateEmployeeDto dto,
  ) async {
    try {
      return await _service.createEmployee(estabelecimentoId, dto);
    } catch (e) {
      _log.e('Erro ao criar funcionário', error: e);
      rethrow;
    }
  }

  Future<EmployeeModel> updateEmployee(
    int estabelecimentoId,
    int usuarioId,
    UpdateEmployeeDto dto,
  ) async {
    try {
      return await _service.updateEmployee(estabelecimentoId, usuarioId, dto);
    } catch (e) {
      _log.e('Erro ao atualizar funcionário', error: e);
      rethrow;
    }
  }

  Future<List<int>> getEmployeeRoles(
    int estabelecimentoId,
    int usuarioId,
  ) async {
    try {
      return await _service.getEmployeeRoles(estabelecimentoId, usuarioId);
    } catch (e) {
      _log.e('Erro ao buscar papéis do funcionário', error: e);
      rethrow;
    }
  }

  Future<List<RoleModel>> getAvailableRoles(int estabelecimentoId) async {
    try {
      return await _service.getAvailableRoles(estabelecimentoId);
    } catch (e) {
      _log.e('Erro ao buscar papéis disponíveis', error: e);
      rethrow;
    }
  }
}
