// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_atendimento_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateAtendimentoDto _$CreateAtendimentoDtoFromJson(
  Map<String, dynamic> json,
) => CreateAtendimentoDto(
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  clienteId: (json['clienteId'] as num).toInt(),
  carroId: (json['carroId'] as num).toInt(),
  situacaoId: (json['situacaoId'] as num?)?.toInt(),
  servicos: (json['servicos'] as List<dynamic>)
      .map(
        (e) => CreateServicoAtendimentoItem.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  acessorios: (json['acessorios'] as List<dynamic>?)
      ?.map(
        (e) =>
            CreateAcessorioAtendimentoItem.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
);

Map<String, dynamic> _$CreateAtendimentoDtoToJson(
  CreateAtendimentoDto instance,
) => <String, dynamic>{
  'estabelecimentoId': instance.estabelecimentoId,
  'clienteId': instance.clienteId,
  'carroId': instance.carroId,
  'situacaoId': ?instance.situacaoId,
  'servicos': instance.servicos,
  'acessorios': ?instance.acessorios,
};

CreateServicoAtendimentoItem _$CreateServicoAtendimentoItemFromJson(
  Map<String, dynamic> json,
) => CreateServicoAtendimentoItem(
  servicoId: (json['servicoId'] as num).toInt(),
  valorUnitario: json['valorUnitario'] as String,
  quantidade: (json['quantidade'] as num?)?.toInt() ?? 1,
  desconto: json['desconto'] as String?,
);

Map<String, dynamic> _$CreateServicoAtendimentoItemToJson(
  CreateServicoAtendimentoItem instance,
) => <String, dynamic>{
  'servicoId': instance.servicoId,
  'valorUnitario': instance.valorUnitario,
  'quantidade': instance.quantidade,
  'desconto': ?instance.desconto,
};

CreateAcessorioAtendimentoItem _$CreateAcessorioAtendimentoItemFromJson(
  Map<String, dynamic> json,
) => CreateAcessorioAtendimentoItem(
  acessorioId: (json['acessorioId'] as num).toInt(),
  valorUnitario: json['valorUnitario'] as String,
  quantidade: (json['quantidade'] as num?)?.toInt() ?? 1,
  desconto: json['desconto'] as String?,
);

Map<String, dynamic> _$CreateAcessorioAtendimentoItemToJson(
  CreateAcessorioAtendimentoItem instance,
) => <String, dynamic>{
  'acessorioId': instance.acessorioId,
  'valorUnitario': instance.valorUnitario,
  'quantidade': instance.quantidade,
  'desconto': ?instance.desconto,
};
