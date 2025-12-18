// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'servico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServicoModel _$ServicoModelFromJson(Map<String, dynamic> json) => ServicoModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  titulo: json['titulo'] as String,
  descricao: json['descricao'] as String?,
  preco: json['preco'] as String,
  tempoEstimado: json['tempoEstimado'] as String,
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  tipoServicoId: (json['tipoServicoId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ServicoModelToJson(ServicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'active': instance.active,
      'titulo': instance.titulo,
      'descricao': instance.descricao,
      'preco': instance.preco,
      'tempoEstimado': instance.tempoEstimado,
      'estabelecimentoId': instance.estabelecimentoId,
      'tipoServicoId': instance.tipoServicoId,
    };

CreateServicoDto _$CreateServicoDtoFromJson(Map<String, dynamic> json) =>
    CreateServicoDto(
      titulo: json['titulo'] as String,
      descricao: json['descricao'] as String?,
      preco: json['preco'] as String,
      tempoEstimado: json['tempoEstimado'] as String,
      estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
      tipoServicoId: (json['tipoServicoId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateServicoDtoToJson(CreateServicoDto instance) =>
    <String, dynamic>{
      'titulo': instance.titulo,
      'descricao': ?instance.descricao,
      'preco': instance.preco,
      'tempoEstimado': instance.tempoEstimado,
      'estabelecimentoId': instance.estabelecimentoId,
      'tipoServicoId': ?instance.tipoServicoId,
    };

UpdateServicoDto _$UpdateServicoDtoFromJson(Map<String, dynamic> json) =>
    UpdateServicoDto(
      titulo: json['titulo'] as String?,
      descricao: json['descricao'] as String?,
      preco: json['preco'] as String?,
      tempoEstimado: json['tempoEstimado'] as String?,
      tipoServicoId: (json['tipoServicoId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateServicoDtoToJson(UpdateServicoDto instance) =>
    <String, dynamic>{
      'titulo': ?instance.titulo,
      'descricao': ?instance.descricao,
      'preco': ?instance.preco,
      'tempoEstimado': ?instance.tempoEstimado,
      'tipoServicoId': ?instance.tipoServicoId,
    };
