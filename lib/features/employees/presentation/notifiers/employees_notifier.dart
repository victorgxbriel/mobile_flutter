import 'package:flutter/foundation.dart';
import '../../../../app/utils/app_logger.dart';
import '../../../../core/services/session_service.dart';
import '../../data/repositories/employee_repository.dart';
import '../states/employee_state.dart';

final _log = logger(EmployeesNotifier);

class EmployeesNotifier extends ChangeNotifier {
  final EmployeeRepository _repository;
  final SessionService _sessionService;

  EmployeesNotifier(this._repository, this._sessionService);

  EmployeesState _state = EmployeesInitial();
  EmployeesState get state => _state;

  void _setState(EmployeesState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> loadEmployees() async {
    _log.d('Carregando funcionários...');
    _setState(EmployeesLoading());

    try {
      final estabelecimentoId = _sessionService.estabelecimentoId;
      if (estabelecimentoId == null) {
        _log.e('Estabelecimento ID não encontrado');
        _setState(EmployeesError('Estabelecimento não identificado'));
        return;
      }

      final employees =
          await _repository.getEmployeesByEstabelecimento(estabelecimentoId);
      _log.d('${employees.length} funcionários carregados');
      _setState(EmployeesLoaded(employees));
    } catch (e) {
      _log.e('Erro ao carregar funcionários', error: e);
      _setState(EmployeesError('Erro ao carregar funcionários'));
    }
  }

  Future<void> deleteEmployee(int employeeId) async {
    _log.d('Removendo funcionário ID: $employeeId');
    
    try {
      // TODO: Implementar endpoint de DELETE quando disponível na API
      _log.w('Endpoint de DELETE não implementado ainda');
      
      // Por enquanto, apenas recarrega a lista
      await loadEmployees();
    } catch (e) {
      _log.e('Erro ao remover funcionário', error: e);
      _setState(EmployeesError('Erro ao remover funcionário'));
    }
  }
}
