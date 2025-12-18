// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmployeeModel _$EmployeeModelFromJson(Map<String, dynamic> json) =>
    EmployeeModel(
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      roles: json['roles'] == null
          ? null
          : RoleModel.fromJson(json['roles'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EmployeeModelToJson(EmployeeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'roles': instance.roles,
    };

CreateEmployeeDto _$CreateEmployeeDtoFromJson(Map<String, dynamic> json) =>
    CreateEmployeeDto(
      nome: json['nome'] as String,
      email: json['email'] as String,
      passwordHash: json['passwordHash'] as String?,
      googleId: json['googleId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool?,
      rolesId: (json['rolesId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$CreateEmployeeDtoToJson(CreateEmployeeDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'email': instance.email,
      'passwordHash': instance.passwordHash,
      'googleId': instance.googleId,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'rolesId': instance.rolesId,
    };

UpdateEmployeeDto _$UpdateEmployeeDtoFromJson(Map<String, dynamic> json) =>
    UpdateEmployeeDto(
      nome: json['nome'] as String?,
      email: json['email'] as String?,
      passwordHash: json['passwordHash'] as String?,
      googleId: json['googleId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      isActive: json['isActive'] as bool?,
      rolesId: (json['rolesId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$UpdateEmployeeDtoToJson(UpdateEmployeeDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'email': instance.email,
      'passwordHash': instance.passwordHash,
      'googleId': instance.googleId,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'rolesId': instance.rolesId,
    };

RoleModel _$RoleModelFromJson(Map<String, dynamic> json) => RoleModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  nome: json['nome'] as String,
  descricao: json['descricao'] as String?,
);

Map<String, dynamic> _$RoleModelToJson(RoleModel instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'active': instance.active,
  'nome': instance.nome,
  'descricao': instance.descricao,
};

UserRoleModel _$UserRoleModelFromJson(Map<String, dynamic> json) =>
    UserRoleModel(
      userId: (json['userId'] as num).toInt(),
      roleId: (json['roleId'] as num).toInt(),
    );

Map<String, dynamic> _$UserRoleModelToJson(UserRoleModel instance) =>
    <String, dynamic>{'userId': instance.userId, 'roleId': instance.roleId};
