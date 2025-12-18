import 'package:flutter/foundation.dart';
import '../../../../app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../states/employee_form_state.dart';

final _log = logger(EmployeeFormNotifier);

class EmployeeFormNotifier extends ChangeNotifier {
  final EmployeeRepository _repository;
  final SessionService _sessionService;

  EmployeeFormNotifier(this._repository, this._sessionService);

  EmployeeFormState _state = EmployeeFormInitial();
  EmployeeFormState get state => _state;

  RolesState _rolesState = RolesInitial();
  RolesState get rolesState => _rolesState;

  void _setState(EmployeeFormState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setRolesState(RolesState newState) {
    _rolesState = newState;
    notifyListeners();
  }

  /// Carrega os papéis disponíveis
  Future<void> loadAvailableRoles() async {
    _log.d('Carregando papéis disponíveis...');
    _setRolesState(RolesLoading());

    try {
      final estabelecimentoId = _sessionService.estabelecimentoId;
      if (estabelecimentoId == null) {
        _log.e('Estabelecimento ID não encontrado');
        _setRolesState(RolesError('Estabelecimento não identificado'));
        return;
      }

      final roles = await _repository.getAvailableRoles(estabelecimentoId);
      _log.d('${roles.length} papéis carregados');
      _setRolesState(RolesLoaded(roles));
    } catch (e) {
      _log.e('Erro ao carregar papéis', error: e);
      _setRolesState(RolesError('Erro ao carregar papéis disponíveis'));
    }
  }

  /// Cria um novo funcionário
  Future<void> createEmployee(CreateEmployeeDto dto) async {
    _log.d('Criando funcionário: ${dto.nome}');
    _setState(EmployeeFormLoading());

    try {
      final estabelecimentoId = _sessionService.estabelecimentoId;
      if (estabelecimentoId == null) {
        _log.e('Estabelecimento ID não encontrado');
        _setState(EmployeeFormError('Estabelecimento não identificado'));
        return;
      }

      final employee = await _repository.createEmployee(estabelecimentoId, dto);
      _log.d('Funcionário criado com sucesso: ID ${employee.id}');
      _setState(EmployeeFormSuccess(employee));
    } catch (e) {
      _log.e('Erro ao criar funcionário', error: e);
      _setState(EmployeeFormError('Erro ao criar funcionário'));
    }
  }

  /// Atualiza um funcionário existente
  Future<void> updateEmployee(int employeeId, UpdateEmployeeDto dto) async {
    _log.d('Atualizando funcionário ID: $employeeId');
    _setState(EmployeeFormLoading());

    try {
      final estabelecimentoId = _sessionService.estabelecimentoId;
      if (estabelecimentoId == null) {
        _log.e('Estabelecimento ID não encontrado');
        _setState(EmployeeFormError('Estabelecimento não identificado'));
        return;
      }

      final employee = await _repository.updateEmployee(
        estabelecimentoId,
        employeeId,
        dto,
      );
      _log.d('Funcionário atualizado com sucesso');
      _setState(EmployeeFormSuccess(employee));
    } catch (e) {
      _log.e('Erro ao atualizar funcionário', error: e);
      _setState(EmployeeFormError('Erro ao atualizar funcionário'));
    }
  }

  /// Carrega os dados de um funcionário para edição
  Future<EmployeeModel?> loadEmployee(int employeeId) async {
    _log.d('Carregando funcionário ID: $employeeId');

    try {
      final estabelecimentoId = _sessionService.estabelecimentoId;
      if (estabelecimentoId == null) {
        _log.e('Estabelecimento ID não encontrado');
        return null;
      }

      final employee = await _repository.getEmployeeById(
        estabelecimentoId,
        employeeId,
      );
      _log.d('Funcionário carregado: ${employee.nome}');
      return employee;
    } catch (e) {
      _log.e('Erro ao carregar funcionário', error: e);
      return null;
    }
  }

  void resetState() {
    _setState(EmployeeFormInitial());
  }
}
