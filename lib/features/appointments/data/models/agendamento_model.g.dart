// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agendamento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgendamentoModel _$AgendamentoModelFromJson(Map<String, dynamic> json) =>
    AgendamentoModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
      carroId: (json['carroId'] as num).toInt(),
      situacaoId: (json['situacaoId'] as num).toInt(),
      slotId: (json['slotId'] as num).toInt(),
      carro: json['carro'] == null
          ? null
          : AgendamentoCarro.fromJson(json['carro'] as Map<String, dynamic>),
      slotDirect: json['slot'] == null
          ? null
          : AgendamentoSlot.fromJson(json['slot'] as Map<String, dynamic>),
      slotFromAgendamento: json['agendamento'] == null
          ? null
          : AgendamentoSlot.fromJson(
              json['agendamento'] as Map<String, dynamic>,
            ),
      servicos: (json['servicos'] as List<dynamic>?)
          ?.map(
            (e) =>
                AgendamentoServicoRelation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      situacaoModel: json['situacao'] == null
          ? null
          : AgendamentoSituacaoModel.fromJson(
              json['situacao'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AgendamentoModelToJson(AgendamentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'carroId': instance.carroId,
      'situacaoId': instance.situacaoId,
      'slotId': instance.slotId,
      'carro': instance.carro,
      'slot': instance.slotDirect,
      'agendamento': instance.slotFromAgendamento,
      'servicos': instance.servicos,
      'situacao': instance.situacaoModel,
    };

AgendamentoCarro _$AgendamentoCarroFromJson(Map<String, dynamic> json) =>
    AgendamentoCarro(
      id: (json['id'] as num).toInt(),
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      placa: json['placa'] as String?,
      cor: json['cor'] as String,
      ano: _parseAno(json['ano']),
    );

Map<String, dynamic> _$AgendamentoCarroToJson(AgendamentoCarro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'placa': instance.placa,
      'cor': instance.cor,
      'ano': instance.ano,
    };

AgendamentoSituacaoModel _$AgendamentoSituacaoModelFromJson(
  Map<String, dynamic> json,
) => AgendamentoSituacaoModel(
  id: (json['id'] as num).toInt(),
  descricao: json['descricao'] as String,
);

Map<String, dynamic> _$AgendamentoSituacaoModelToJson(
  AgendamentoSituacaoModel instance,
) => <String, dynamic>{'id': instance.id, 'descricao': instance.descricao};

AgendamentoServicoRelation _$AgendamentoServicoRelationFromJson(
  Map<String, dynamic> json,
) => AgendamentoServicoRelation(
  servicoId: (json['servicoId'] as num?)?.toInt(),
  servico: json['servico'] == null
      ? null
      : AgendamentoServico.fromJson(json['servico'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AgendamentoServicoRelationToJson(
  AgendamentoServicoRelation instance,
) => <String, dynamic>{
  'servicoId': instance.servicoId,
  'servico': instance.servico,
};

AgendamentoSlot _$AgendamentoSlotFromJson(Map<String, dynamic> json) =>
    AgendamentoSlot(
      id: (json['id'] as num).toInt(),
      slotTempo: json['slotTempo'] as String,
      disponivel: json['disponivel'] as bool?,
      programacaoId: (json['programacaoId'] as num?)?.toInt(),
      programacao: json['programacao'] == null
          ? null
          : AgendamentoProgramacao.fromJson(
              json['programacao'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AgendamentoSlotToJson(AgendamentoSlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slotTempo': instance.slotTempo,
      'disponivel': instance.disponivel,
      'programacaoId': instance.programacaoId,
      'programacao': instance.programacao,
    };

AgendamentoProgramacao _$AgendamentoProgramacaoFromJson(
  Map<String, dynamic> json,
) => AgendamentoProgramacao(
  id: (json['id'] as num).toInt(),
  data: json['data'] as String,
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  horaInicio: json['horaInicio'] as String?,
  horaTermino: json['horaTermino'] as String?,
  estabelecimento: json['estabelecimento'] == null
      ? null
      : AgendamentoEstabelecimento.fromJson(
          json['estabelecimento'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AgendamentoProgramacaoToJson(
  AgendamentoProgramacao instance,
) => <String, dynamic>{
  'id': instance.id,
  'data': instance.data,
  'estabelecimentoId': instance.estabelecimentoId,
  'horaInicio': instance.horaInicio,
  'horaTermino': instance.horaTermino,
  'estabelecimento': instance.estabelecimento,
};

AgendamentoEstabelecimento _$AgendamentoEstabelecimentoFromJson(
  Map<String, dynamic> json,
) => AgendamentoEstabelecimento(
  id: (json['id'] as num).toInt(),
  nomeFantasia: json['nomeFantasia'] as String,
  cnpj: json['cnpj'] as String?,
);

Map<String, dynamic> _$AgendamentoEstabelecimentoToJson(
  AgendamentoEstabelecimento instance,
) => <String, dynamic>{
  'id': instance.id,
  'nomeFantasia': instance.nomeFantasia,
  'cnpj': instance.cnpj,
};

AgendamentoServico _$AgendamentoServicoFromJson(Map<String, dynamic> json) =>
    AgendamentoServico(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String,
      preco: json['preco'] as String,
      tempoEstimado: json['tempoEstimado'] as String?,
      descricao: json['descricao'] as String?,
    );

Map<String, dynamic> _$AgendamentoServicoToJson(AgendamentoServico instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'preco': instance.preco,
      'tempoEstimado': instance.tempoEstimado,
      'descricao': instance.descricao,
    };

CreateAgendamentoDto _$CreateAgendamentoDtoFromJson(
  Map<String, dynamic> json,
) => CreateAgendamentoDto(
  carroId: (json['carroId'] as num).toInt(),
  situacaoId: (json['situacaoId'] as num).toInt(),
  slotId: (json['slotId'] as num).toInt(),
  servicosIds: (json['servicosIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList(),
);

Map<String, dynamic> _$CreateAgendamentoDtoToJson(
  CreateAgendamentoDto instance,
) => <String, dynamic>{
  'carroId': instance.carroId,
  'situacaoId': instance.situacaoId,
  'slotId': instance.slotId,
  'servicosIds': instance.servicosIds,
};
