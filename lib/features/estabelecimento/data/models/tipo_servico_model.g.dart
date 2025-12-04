// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tipo_servico_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TipoServicoModel _$TipoServicoModelFromJson(Map<String, dynamic> json) =>
    TipoServicoModel(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
    );

Map<String, dynamic> _$TipoServicoModelToJson(TipoServicoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'nome': instance.nome,
      'descricao': instance.descricao,
    };
