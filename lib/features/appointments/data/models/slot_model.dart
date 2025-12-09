import 'package:json_annotation/json_annotation.dart';

part 'slot_model.g.dart';

@JsonSerializable()
class ProgramacaoDiariaModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final String data;
  final String horaInicio;
  final String horaTermino;
  final String intervaloHorario;
  final int agendamentosPorHorario;
  final int estabelecimentoId;
  
  /// A API retorna como "slotsTempo" quando busca por data
  @JsonKey(name: 'slotsTempo')
  final List<SlotTempoModel>? slots;

  ProgramacaoDiariaModel({
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

  factory ProgramacaoDiariaModel.fromJson(Map<String, dynamic> json) =>
      _$ProgramacaoDiariaModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgramacaoDiariaModelToJson(this);

  DateTime get dataAsDateTime => DateTime.parse(data);

  /// Factory para criar mock data para skeleton loading
  factory ProgramacaoDiariaModel.skeleton() => ProgramacaoDiariaModel(
    id: 0,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    active: true,
    data: DateTime.now().toIso8601String().split('T').first,
    horaInicio: '08:00',
    horaTermino: '18:00',
    intervaloHorario: '00:30',
    agendamentosPorHorario: 2,
    estabelecimentoId: 0,
    slots: List.generate(8, (i) => SlotTempoModel.skeleton(i)),
  );
}

@JsonSerializable()
class SlotTempoModel {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? active;
  final int? programacaoId;
  final String slotTempo;
  final bool? disponivel;

  SlotTempoModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.active,
    this.programacaoId,
    required this.slotTempo,
    this.disponivel,
  });

  factory SlotTempoModel.fromJson(Map<String, dynamic> json) =>
      _$SlotTempoModelFromJson(json);

  Map<String, dynamic> toJson() => _$SlotTempoModelToJson(this);

  /// Factory para criar mock data para skeleton loading
  factory SlotTempoModel.skeleton(int index) => SlotTempoModel(
    id: index,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    active: true,
    programacaoId: 0,
    slotTempo: '${(8 + index).toString().padLeft(2, '0')}:00',
    disponivel: true,
  );

  /// Formata o horário para exibição (HH:mm)
  String get horarioFormatado {
    if (slotTempo.contains(':')) {
      return slotTempo.substring(0, 5);
    }
    return slotTempo;
  }

  /// Verifica se o slot está disponível para agendamento
  bool get isDisponivel => disponivel ?? true;
}
