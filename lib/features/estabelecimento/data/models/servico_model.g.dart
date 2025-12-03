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
  tipoServicoId: (json['tipoServicoId'] as num?)?.toInt(),
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  tipoServico: json['tipoServico'] == null
      ? null
      : TipoServicoModel.fromJson(json['tipoServico'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ServicoModelToJson(ServicoModel instance) =>
    <String, dynamic>{ 'id': instance.id, 'createdAt': instance.createdAt.toIso8601String(), 'updatedAt': instance.updatedAt.toIso8601String(), 'active': instance.active, 'titulo': instance.titulo, 'descricao': instance.descricao, 'preco': instance.preco, 'tempoEstimado': instance.tempoEstimado, 'tipoServicoId': instance.tipoServicoId, 'estabelecimentoId': instance.estabelecimentoId, 'tipoServico': instance.tipoServico,
    };
