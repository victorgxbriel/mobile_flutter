// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramacaoDiariaModel _$ProgramacaoDiariaModelFromJson(
  Map<String, dynamic> json,
) => ProgramacaoDiariaModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  data: json['data'] as String,
  horaInicio: json['horaInicio'] as String,
  horaTermino: json['horaTermino'] as String,
  intervaloHorario: json['intervaloHorario'] as String,
  agendamentosPorHorario: (json['agendamentosPorHorario'] as num).toInt(),
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
  slots: (json['slotsTempo'] as List<dynamic>?)
      ?.map((e) => SlotTempoModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ProgramacaoDiariaModelToJson(
  ProgramacaoDiariaModel instance,
) => <String, dynamic>{ 'id': instance.id, 'createdAt': instance.createdAt.toIso8601String(), 'updatedAt': instance.updatedAt?.toIso8601String(), 'active': instance.active, 'data': instance.data, 'horaInicio': instance.horaInicio, 'horaTermino': instance.horaTermino, 'intervaloHorario': instance.intervaloHorario, 'agendamentosPorHorario': instance.agendamentosPorHorario, 'estabelecimentoId': instance.estabelecimentoId, 'slotsTempo': instance.slots,
};

SlotTempoModel _$SlotTempoModelFromJson(Map<String, dynamic> json) =>
    SlotTempoModel(
      id: (json['id'] as num).toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool?,
      programacaoId: (json['programacaoId'] as num?)?.toInt(),
      slotTempo: json['slotTempo'] as String,
      disponivel: json['disponivel'] as bool?,
    );

Map<String, dynamic> _$SlotTempoModelToJson(SlotTempoModel instance) =>
    <String, dynamic>{ 'id': instance.id, 'createdAt': instance.createdAt?.toIso8601String(), 'updatedAt': instance.updatedAt?.toIso8601String(), 'active': instance.active, 'programacaoId': instance.programacaoId, 'slotTempo': instance.slotTempo, 'disponivel': instance.disponivel,
    };
