import 'package:json_annotation/json_annotation.dart';

part 'programacao_diaria_model.g.dart';

/// Modelo de Programação Diária retornado pela API
@JsonSerializable()
class ProgramacaoDiaria {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final DateTime data;
  final String horaInicio;
  final String horaTermino;
  final String intervaloHorario;
  final int agendamentosPorHorario;
  final int estabelecimentoId;
  final List<SlotTempo>? slots;

  ProgramacaoDiaria({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.data,
    required this.horaInicio,
    required this.horaTermino,
    required this.intervaloHorario,
    required this.agendamentosPorHorario,
    required this.estabelecimentoId,
    this.slots,
  });

  factory ProgramacaoDiaria.fromJson(Map<String, dynamic> json) =>
      _$ProgramacaoDiariaFromJson(json);
  Map<String, dynamic> toJson() => _$ProgramacaoDiariaToJson(this);

  ProgramacaoDiaria copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    DateTime? data,
    String? horaInicio,
    String? horaTermino,
    String? intervaloHorario,
    int? agendamentosPorHorario,
    int? estabelecimentoId,
    List<SlotTempo>? slots,
  }) {
    return ProgramacaoDiaria(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      data: data ?? this.data,
      horaInicio: horaInicio ?? this.horaInicio,
      horaTermino: horaTermino ?? this.horaTermino,
      intervaloHorario: intervaloHorario ?? this.intervaloHorario,
      agendamentosPorHorario: agendamentosPorHorario ?? this.agendamentosPorHorario,
      estabelecimentoId: estabelecimentoId ?? this.estabelecimentoId,
      slots: slots ?? this.slots,
    );
  }
}

/// Modelo de Slot de Tempo
@JsonSerializable()
class SlotTempo {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final int programacaoId;
  final String slotTempo;
  final bool? disponivel;

  SlotTempo({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.programacaoId,
    required this.slotTempo,
    this.disponivel,
  });

  factory SlotTempo.fromJson(Map<String, dynamic> json) =>
      _$SlotTempoFromJson(json);
  Map<String, dynamic> toJson() => _$SlotTempoToJson(this);

  SlotTempo copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    int? programacaoId,
    String? slotTempo,
    bool? disponivel,
  }) {
    return SlotTempo(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      programacaoId: programacaoId ?? this.programacaoId,
      slotTempo: slotTempo ?? this.slotTempo,
      disponivel: disponivel ?? this.disponivel,
    );
  }
}

/// DTO para criar programação diária
@JsonSerializable(includeIfNull: false)
class CreateProgramacaoDiariaDto {
  final String data; // formato: YYYY-MM-DD
  final String horaInicio; // formato: HH:mm ou HH:mm:ss
  final String horaTermino;
  final String intervaloHorario; // formato ISO 8601 Duration (ex: PT30M para 30 minutos)
  final int agendamentosPorHorario;
  final int estabelecimentoId;

  CreateProgramacaoDiariaDto({
    required this.data,
    required this.horaInicio,
    required this.horaTermino,
    required this.intervaloHorario,
    this.agendamentosPorHorario = 1,
    required this.estabelecimentoId,
  });

  Map<String, dynamic> toJson() => _$CreateProgramacaoDiariaDtoToJson(this);
}

/// DTO para atualizar programação diária
@JsonSerializable(includeIfNull: false)
class UpdateProgramacaoDiariaDto {
  final String? data;
  final String? horaInicio;
  final String? horaTermino;
  final String? intervaloHorario;
  final int? agendamentosPorHorario;
  final int? estabelecimentoId;

  UpdateProgramacaoDiariaDto({
    this.data,
    this.horaInicio,
    this.horaTermino,
    this.intervaloHorario,
    this.agendamentosPorHorario,
    this.estabelecimentoId,
  });

  Map<String, dynamic> toJson() => _$UpdateProgramacaoDiariaDtoToJson(this);
}
