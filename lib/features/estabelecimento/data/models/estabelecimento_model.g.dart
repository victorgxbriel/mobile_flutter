// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estabelecimento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EstabelecimentoModel _$EstabelecimentoModelFromJson(
  Map<String, dynamic> json,
) => EstabelecimentoModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  cnpj: json['cnpj'] as String,
  nomeFantasia: json['nomeFantasia'] as String,
);

Map<String, dynamic> _$EstabelecimentoModelToJson(
  EstabelecimentoModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'active': instance.active,
  'cnpj': instance.cnpj,
  'nomeFantasia': instance.nomeFantasia,
};
