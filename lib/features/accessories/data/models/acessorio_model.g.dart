// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'acessorio_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AcessorioModel _$AcessorioModelFromJson(Map<String, dynamic> json) =>
    AcessorioModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      preco: json['preco'] as String,
      estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
    );

Map<String, dynamic> _$AcessorioModelToJson(AcessorioModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'active': instance.active,
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'preco': instance.preco,
      'estabelecimentoId': instance.estabelecimentoId,
    };

CreateAcessorioDto _$CreateAcessorioDtoFromJson(Map<String, dynamic> json) =>
    CreateAcessorioDto(
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      preco: json['preco'] as String,
      estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
    );

Map<String, dynamic> _$CreateAcessorioDtoToJson(CreateAcessorioDto instance) =>
    <String, dynamic>{
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'preco': instance.preco,
      'estabelecimentoId': instance.estabelecimentoId,
    };

UpdateAcessorioDto _$UpdateAcessorioDtoFromJson(Map<String, dynamic> json) =>
    UpdateAcessorioDto(
      titulo: json['titulo'] as String?,
      descricao: json['descricao'] as String?,
      preco: json['preco'] as String?,
    );

Map<String, dynamic> _$UpdateAcessorioDtoToJson(UpdateAcessorioDto instance) =>
    <String, dynamic>{
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'preco': instance.preco,
    };
