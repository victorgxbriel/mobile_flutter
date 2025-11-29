// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteModel _$ClienteModelFromJson(Map<String, dynamic> json) => ClienteModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  nome: json['nome'] as String,
  cpf: json['cpf'] as String,
  email: json['email'] as String,
  userId: (json['userId'] as num?)?.toInt(),
  fotoUrl: json['fotoUrl'] as String?,
);

Map<String, dynamic> _$ClienteModelToJson(ClienteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'active': instance.active,
      'nome': instance.nome,
      'cpf': instance.cpf,
      'email': instance.email,
      'userId': instance.userId,
      'fotoUrl': instance.fotoUrl,
    };

UpdateClienteDto _$UpdateClienteDtoFromJson(Map<String, dynamic> json) =>
    UpdateClienteDto(
      nome: json['nome'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      fotoUrl: json['fotoUrl'] as String?,
    );

Map<String, dynamic> _$UpdateClienteDtoToJson(UpdateClienteDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'cpf': instance.cpf,
      'email': instance.email,
      'fotoUrl': instance.fotoUrl,
    };
