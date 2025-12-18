import '../../data/models/employee_model.dart';

/// Estados do formulário de funcionário
sealed class EmployeeFormState {}

class EmployeeFormInitial extends EmployeeFormState {}

class EmployeeFormLoading extends EmployeeFormState {}

class EmployeeFormSuccess extends EmployeeFormState {
  final EmployeeModel employee;

  EmployeeFormSuccess(this.employee);
}

class EmployeeFormError extends EmployeeFormState {
  final String message;

  EmployeeFormError(this.message);
}

/// Estados para carregar papéis disponíveis
sealed class RolesState {}

class RolesInitial extends RolesState {}

class RolesLoading extends RolesState {}

class RolesLoaded extends RolesState {
  final List<RoleModel> roles;

  RolesLoaded(this.roles);
}

class RolesError extends RolesState {
  final String message;

  RolesError(this.message);
}
