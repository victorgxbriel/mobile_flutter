import 'package:json_annotation/json_annotation.dart';

part 'agendamento_model.g.dart';

/// Situações possíveis do agendamento
enum AgendamentoSituacao {
  @JsonValue(1)
  agendado(1, 'Agendado'),
  @JsonValue(2)
  confirmado(2, 'Confirmado'),
  @JsonValue(3)
  emAndamento(3, 'Em Andamento'),
  @JsonValue(4)
  concluido(4, 'Concluído'),
  @JsonValue(5)
  cancelado(5, 'Cancelado');

  final int id;
  final String descricao;

  const AgendamentoSituacao(this.id, this.descricao);

  static AgendamentoSituacao fromId(int id) {
    return AgendamentoSituacao.values.firstWhere(
      (s) => s.id == id,
      orElse: () => AgendamentoSituacao.agendado,
    );
  }
}

@JsonSerializable()
class AgendamentoModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final int carroId;
  final int situacaoId;
  final int slotId;
  
  // Relacionamentos incluídos via ?includes
  final AgendamentoCarro? carro;
  final AgendamentoSlot? slot;
  final List<AgendamentoServico>? servicos;

  AgendamentoModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.carroId,
    required this.situacaoId,
    required this.slotId,
    this.carro,
    this.slot,
    this.servicos,
  });

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoModelToJson(this);

  AgendamentoSituacao get situacao => AgendamentoSituacao.fromId(situacaoId);
  
  String get situacaoLabel => situacao.descricao;
}

@JsonSerializable()
class AgendamentoCarro {
  final int id;
  final String marca;
  final String modelo;
  final String? placa;
  final String cor;

  AgendamentoCarro({
    required this.id,
    required this.marca,
    required this.modelo,
    this.placa,
    required this.cor,
  });

  factory AgendamentoCarro.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoCarroFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoCarroToJson(this);

  String get nomeCompleto => '$marca $modelo';
}

@JsonSerializable()
class AgendamentoSlot {
  final int id;
  final String slotTempo;
  final bool? disponivel;
  final int programacaoId;
  final AgendamentoProgramacao? programacao;

  AgendamentoSlot({
    required this.id,
    required this.slotTempo,
    this.disponivel,
    required this.programacaoId,
    this.programacao,
  });

  factory AgendamentoSlot.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoSlotFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoSlotToJson(this);

  /// Formata o horário para exibição (HH:mm)
  String get horarioFormatado {
    if (slotTempo.contains(':')) {
      return slotTempo.substring(0, 5);
    }
    return slotTempo;
  }
}

@JsonSerializable()
class AgendamentoProgramacao {
  final int id;
  final String data;
  final int estabelecimentoId;

  AgendamentoProgramacao({
    required this.id,
    required this.data,
    required this.estabelecimentoId,
  });

  factory AgendamentoProgramacao.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoProgramacaoFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoProgramacaoToJson(this);

  DateTime get dataAsDateTime => DateTime.parse(data);
}

@JsonSerializable()
class AgendamentoServico {
  final int id;
  final String titulo;
  final String preco;
  final String tempoEstimado;

  AgendamentoServico({
    required this.id,
    required this.titulo,
    required this.preco,
    required this.tempoEstimado,
  });

  factory AgendamentoServico.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoServicoFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoServicoToJson(this);

  String get precoFormatado {
    try {
      final valor = double.parse(preco);
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ $preco';
    }
  }
}

@JsonSerializable()
class CreateAgendamentoDto {
  final int carroId;
  final int situacaoId;
  final int slotId;
  final List<int> servicosIds;

  CreateAgendamentoDto({
    required this.carroId,
    required this.situacaoId,
    required this.slotId,
    required this.servicosIds,
  });

  factory CreateAgendamentoDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAgendamentoDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateAgendamentoDtoToJson(this);
}
