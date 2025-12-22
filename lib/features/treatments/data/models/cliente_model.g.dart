// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClienteModel _$ClienteModelFromJson(Map<String, dynamic> json) => ClienteModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  clienteId: (json['clienteId'] as num).toInt(),
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  cliente: json['cliente'] == null
      ? null
      : ClienteDetalheModel.fromJson(json['cliente'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClienteModelToJson(ClienteModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'clienteId': instance.clienteId,
      'estabelecimentoId': instance.estabelecimentoId,
      'cliente': instance.cliente,
    };

ClienteDetalheModel _$ClienteDetalheModelFromJson(Map<String, dynamic> json) =>
    ClienteDetalheModel(
      id: (json['id'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool?,
      nome: json['nome'] as String?,
      cpf: json['cpf'] as String?,
      email: json['email'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ClienteDetalheModelToJson(
  ClienteDetalheModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'active': instance.active,
  'nome': instance.nome,
  'cpf': instance.cpf,
  'email': instance.email,
  'userId': instance.userId,
};

ClienteCarroModel _$ClienteCarroModelFromJson(Map<String, dynamic> json) =>
    ClienteCarroModel(
      id: (json['id'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool?,
      clienteId: (json['clienteId'] as num?)?.toInt(),
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      placa: json['placa'] as String?,
      cor: json['cor'] as String,
      ano: _parseAno(json['ano']),
    );

Map<String, dynamic> _$ClienteCarroModelToJson(ClienteCarroModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'clienteId': instance.clienteId,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'placa': instance.placa,
      'cor': instance.cor,
      'ano': instance.ano,
    };
