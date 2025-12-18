import 'package:json_annotation/json_annotation.dart';

part 'employee_model.g.dart';

/// Model para funcionário/usuário do estabelecimento
@JsonSerializable()
class EmployeeModel {
  final int id;
  final String nome;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final RoleModel? roles;

  EmployeeModel({
    required this.id,
    required this.nome,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.roles,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);
}

/// DTO para criar novo funcionário
@JsonSerializable()
class CreateEmployeeDto {
  final String nome;
  final String email;
  final String? passwordHash;
  final String? googleId;
  final String? avatarUrl;
  final bool? isActive;
  final List<int>? rolesId;

  CreateEmployeeDto({
    required this.nome,
    required this.email,
    this.passwordHash,
    this.googleId,
    this.avatarUrl,
    this.isActive,
    this.rolesId,
  });

  factory CreateEmployeeDto.fromJson(Map<String, dynamic> json) =>
      _$CreateEmployeeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateEmployeeDtoToJson(this);
}

/// DTO para atualizar funcionário
@JsonSerializable()
class UpdateEmployeeDto {
  final String? nome;
  final String? email;
  final String? passwordHash;
  final String? googleId;
  final String? avatarUrl;
  final bool? isActive;
  final List<int>? rolesId;

  UpdateEmployeeDto({
    this.nome,
    this.email,
    this.passwordHash,
    this.googleId,
    this.avatarUrl,
    this.isActive,
    this.rolesId,
  });

  factory UpdateEmployeeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateEmployeeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateEmployeeDtoToJson(this);
}

/// Model para papel/role do usuário
@JsonSerializable()
class RoleModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final String nome;
  final String? descricao;

  RoleModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.nome,
    this.descricao,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}

/// Model para relacionamento usuário-papel
@JsonSerializable()
class UserRoleModel {
  final int userId;
  final int roleId;

  UserRoleModel({required this.userId, required this.roleId});

  factory UserRoleModel.fromJson(Map<String, dynamic> json) =>
      _$UserRoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserRoleModelToJson(this);
}
