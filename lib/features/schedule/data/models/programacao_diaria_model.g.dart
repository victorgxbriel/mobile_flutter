// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'programacao_diaria_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramacaoDiaria _$ProgramacaoDiariaFromJson(Map<String, dynamic> json) =>
    ProgramacaoDiaria(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      active: json['active'] as bool,
      data: DateTime.parse(json['data'] as String),
      horaInicio: json['horaInicio'] as String,
      horaTermino: json['horaTermino'] as String,
      intervaloHorario: json['intervaloHorario'] as String,
      agendamentosPorHorario: (json['agendamentosPorHorario'] as num).toInt(),
      estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
      slots: (json['slots'] as List<dynamic>?)
          ?.map((e) => SlotTempo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProgramacaoDiariaToJson(ProgramacaoDiaria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'data': instance.data.toIso8601String(),
      'horaInicio': instance.horaInicio,
      'horaTermino': instance.horaTermino,
      'intervaloHorario': instance.intervaloHorario,
      'agendamentosPorHorario': instance.agendamentosPorHorario,
      'estabelecimentoId': instance.estabelecimentoId,
      'slots': instance.slots,
    };

SlotTempo _$SlotTempoFromJson(Map<String, dynamic> json) => SlotTempo(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  programacaoId: (json['programacaoId'] as num).toInt(),
  slotTempo: json['slotTempo'] as String,
  disponivel: json['disponivel'] as bool?,
);

Map<String, dynamic> _$SlotTempoToJson(SlotTempo instance) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'active': instance.active,
  'programacaoId': instance.programacaoId,
  'slotTempo': instance.slotTempo,
  'disponivel': instance.disponivel,
};

CreateProgramacaoDiariaDto _$CreateProgramacaoDiariaDtoFromJson(
  Map<String, dynamic> json,
) => CreateProgramacaoDiariaDto(
  data: json['data'] as String,
  horaInicio: json['horaInicio'] as String,
  horaTermino: json['horaTermino'] as String,
  intervaloHorario: json['intervaloHorario'] as String,
  agendamentosPorHorario:
      (json['agendamentosPorHorario'] as num?)?.toInt() ?? 1,
  estabelecimentoId: (json['estabelecimentoId'] as num).toInt(),
);

Map<String, dynamic> _$CreateProgramacaoDiariaDtoToJson(
  CreateProgramacaoDiariaDto instance,
) => <String, dynamic>{
  'data': instance.data,
  'horaInicio': instance.horaInicio,
  'horaTermino': instance.horaTermino,
  'intervaloHorario': instance.intervaloHorario,
  'agendamentosPorHorario': instance.agendamentosPorHorario,
  'estabelecimentoId': instance.estabelecimentoId,
};

UpdateProgramacaoDiariaDto _$UpdateProgramacaoDiariaDtoFromJson(
  Map<String, dynamic> json,
) => UpdateProgramacaoDiariaDto(
  data: json['data'] as String?,
  horaInicio: json['horaInicio'] as String?,
  horaTermino: json['horaTermino'] as String?,
  intervaloHorario: json['intervaloHorario'] as String?,
  agendamentosPorHorario: (json['agendamentosPorHorario'] as num?)?.toInt(),
  estabelecimentoId: (json['estabelecimentoId'] as num?)?.toInt(),
);

Map<String, dynamic> _$UpdateProgramacaoDiariaDtoToJson(
  UpdateProgramacaoDiariaDto instance,
) => <String, dynamic>{
  'data': ?instance.data,
  'horaInicio': ?instance.horaInicio,
  'horaTermino': ?instance.horaTermino,
  'intervaloHorario': ?instance.intervaloHorario,
  'agendamentosPorHorario': ?instance.agendamentosPorHorario,
  'estabelecimentoId': ?instance.estabelecimentoId,
};
