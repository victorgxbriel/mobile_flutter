// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'atendimento_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AtendimentoModel _$AtendimentoModelFromJson(Map<String, dynamic> json) =>
    AtendimentoModel(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
      valorTotal: json['valorTotal'] as String?,
      valorDesconto: json['valorDesconto'] as String?,
      horaInicio: json['horaInicio'] == null
          ? null
          : DateTime.parse(json['horaInicio'] as String),
      horaTerminio: json['horaTerminio'] == null
          ? null
          : DateTime.parse(json['horaTerminio'] as String),
      posicaoFila: (json['posicaoFila'] as num?)?.toInt(),
      situacaoId: (json['situacaoId'] as num).toInt(),
      agendamentoId: (json['agendamentoId'] as num?)?.toInt(),
      estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
      situacao: json['situacao'] == null
          ? null
          : AtendimentoSituacaoModel.fromJson(
              json['situacao'] as Map<String, dynamic>,
            ),
      agendamento: json['agendamento'] == null
          ? null
          : AtendimentoAgendamento.fromJson(
              json['agendamento'] as Map<String, dynamic>,
            ),
      servicos: (json['servicos'] as List<dynamic>?)
          ?.map(
            (e) =>
                AtendimentoServicoRelation.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      acessorios: (json['acessorios'] as List<dynamic>?)
          ?.map(
            (e) => AtendimentoAcessorioRelation.fromJson(
              e as Map<String, dynamic>,
            ),
          )
          .toList(),
    );

Map<String, dynamic> _$AtendimentoModelToJson(AtendimentoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'valorTotal': instance.valorTotal,
      'valorDesconto': instance.valorDesconto,
      'horaInicio': instance.horaInicio?.toIso8601String(),
      'horaTerminio': instance.horaTerminio?.toIso8601String(),
      'posicaoFila': instance.posicaoFila,
      'situacaoId': instance.situacaoId,
      'agendamentoId': instance.agendamentoId,
      'estabelecimentoId': instance.estabelecimentoId,
      'situacao': instance.situacao,
      'agendamento': instance.agendamento,
      'servicos': instance.servicos,
      'acessorios': instance.acessorios,
    };

AtendimentoSituacaoModel _$AtendimentoSituacaoModelFromJson(
  Map<String, dynamic> json,
) => AtendimentoSituacaoModel(
  id: (json['id'] as num).toInt(),
  descricao: json['descricao'] as String,
);

Map<String, dynamic> _$AtendimentoSituacaoModelToJson(
  AtendimentoSituacaoModel instance,
) => <String, dynamic>{'id': instance.id, 'descricao': instance.descricao};

AtendimentoAgendamento _$AtendimentoAgendamentoFromJson(
  Map<String, dynamic> json,
) => AtendimentoAgendamento(
  id: (json['id'] as num?)?.toInt(),
  carroId: (json['carroId'] as num).toInt(),
  slotId: (json['slotId'] as num).toInt(),
  situacaoId: (json['situacaoId'] as num?)?.toInt(),
  carro: json['carro'] == null
      ? null
      : AtendimentoCarro.fromJson(json['carro'] as Map<String, dynamic>),
  slot: json['slot'] == null
      ? null
      : AtendimentoSlot.fromJson(json['slot'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AtendimentoAgendamentoToJson(
  AtendimentoAgendamento instance,
) => <String, dynamic>{
  'id': instance.id,
  'carroId': instance.carroId,
  'slotId': instance.slotId,
  'situacaoId': instance.situacaoId,
  'carro': instance.carro,
  'slot': instance.slot,
};

AtendimentoCarro _$AtendimentoCarroFromJson(Map<String, dynamic> json) =>
    AtendimentoCarro(
      id: (json['id'] as num).toInt(),
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      placa: json['placa'] as String?,
      cor: json['cor'] as String,
      ano: _parseAno(json['ano']),
    );

Map<String, dynamic> _$AtendimentoCarroToJson(AtendimentoCarro instance) =>
    <String, dynamic>{
      'id': instance.id,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'placa': instance.placa,
      'cor': instance.cor,
      'ano': instance.ano,
    };

AtendimentoSlot _$AtendimentoSlotFromJson(Map<String, dynamic> json) =>
    AtendimentoSlot(
      id: (json['id'] as num).toInt(),
      slotTempo: json['slotTempo'] as String,
      programacaoId: (json['programacaoId'] as num?)?.toInt(),
      programacao: json['programacao'] == null
          ? null
          : AtendimentoProgramacao.fromJson(
              json['programacao'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$AtendimentoSlotToJson(AtendimentoSlot instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slotTempo': instance.slotTempo,
      'programacaoId': instance.programacaoId,
      'programacao': instance.programacao,
    };

AtendimentoProgramacao _$AtendimentoProgramacaoFromJson(
  Map<String, dynamic> json,
) => AtendimentoProgramacao(
  id: (json['id'] as num).toInt(),
  data: json['data'] as String,
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
);

Map<String, dynamic> _$AtendimentoProgramacaoToJson(
  AtendimentoProgramacao instance,
) => <String, dynamic>{
  'id': instance.id,
  'data': instance.data,
  'estabelecimentoId': instance.estabelecimentoId,
};

AtendimentoServicoRelation _$AtendimentoServicoRelationFromJson(
  Map<String, dynamic> json,
) => AtendimentoServicoRelation(
  id: (json['id'] as num?)?.toInt(),
  servicoId: (json['servicoId'] as num?)?.toInt(),
  quantidade: (json['quantidade'] as num?)?.toInt(),
  valorUnitario: json['valorUnitario'] as String?,
  desconto: json['desconto'] as String?,
  servico: json['servico'] == null
      ? null
      : AtendimentoServico.fromJson(json['servico'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AtendimentoServicoRelationToJson(
  AtendimentoServicoRelation instance,
) => <String, dynamic>{
  'id': instance.id,
  'servicoId': instance.servicoId,
  'quantidade': instance.quantidade,
  'valorUnitario': instance.valorUnitario,
  'desconto': instance.desconto,
  'servico': instance.servico,
};

AtendimentoServico _$AtendimentoServicoFromJson(Map<String, dynamic> json) =>
    AtendimentoServico(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo'] as String,
      preco: json['preco'] as String,
      tempoEstimado: json['tempoEstimado'] as String?,
      descricao: json['descricao'] as String?,
    );

Map<String, dynamic> _$AtendimentoServicoToJson(AtendimentoServico instance) =>
    <String, dynamic>{
      'id': instance.id,
      'titulo': instance.titulo,
      'preco': instance.preco,
      'tempoEstimado': instance.tempoEstimado,
      'descricao': instance.descricao,
    };

AtendimentoAcessorioRelation _$AtendimentoAcessorioRelationFromJson(
  Map<String, dynamic> json,
) => AtendimentoAcessorioRelation(
  id: (json['id'] as num?)?.toInt(),
  acessorioId: (json['acessorioId'] as num?)?.toInt(),
  quantidade: (json['quantidade'] as num?)?.toInt(),
  valorUnitario: json['valorUnitario'] as String?,
  desconto: json['desconto'] as String?,
  acessorio: json['acessorio'] == null
      ? null
      : AtendimentoAcessorio.fromJson(
          json['acessorio'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AtendimentoAcessorioRelationToJson(
  AtendimentoAcessorioRelation instance,
) => <String, dynamic>{
  'id': instance.id,
  'acessorioId': instance.acessorioId,
  'quantidade': instance.quantidade,
  'valorUnitario': instance.valorUnitario,
  'desconto': instance.desconto,
  'acessorio': instance.acessorio,
};

AtendimentoAcessorio _$AtendimentoAcessorioFromJson(
  Map<String, dynamic> json,
) => AtendimentoAcessorio(
  id: (json['id'] as num).toInt(),
  nome: json['nome'] as String,
  preco: json['preco'] as String,
);

Map<String, dynamic> _$AtendimentoAcessorioToJson(
  AtendimentoAcessorio instance,
) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'preco': instance.preco,
};
