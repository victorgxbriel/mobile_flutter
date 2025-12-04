import 'package:json_annotation/json_annotation.dart';

part 'agendamento_model.g.dart';

/// Situações possíveis do agendamento
enum AgendamentoSituacao {
  @JsonValue(1)
  agendado(1, 'Agendado'),
  @JsonValue(2)
  atrasado(2, 'Atrasado'),
  @JsonValue(3)
  iniciado(3, 'Iniciado'),
  @JsonValue(4)
  cancelado(4, 'Cancelado');

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
  
  // Relacionamentos incluídos via ?include=full
  final AgendamentoCarro? carro;
  
  // A API pode retornar o slot como "slot" ou como "agendamento"
  // Usamos um campo privado para capturar "agendamento" e um getter para unificar
  @JsonKey(name: 'slot')
  final AgendamentoSlot? slotDirect;
  
  @JsonKey(name: 'agendamento')
  final AgendamentoSlot? slotFromAgendamento;
  
  final List<AgendamentoServicoRelation>? servicos;
  
  @JsonKey(name: 'situacao')
  final AgendamentoSituacaoModel? situacaoModel;

  AgendamentoModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.carroId,
    required this.situacaoId,
    required this.slotId,
    this.carro,
    this.slotDirect,
    this.slotFromAgendamento,
    this.servicos,
    this.situacaoModel,
  });
  
  /// Retorna o slot, seja ele vindo do campo "slot" ou "agendamento"
  AgendamentoSlot? get slot => slotDirect ?? slotFromAgendamento;

  factory AgendamentoModel.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoModelToJson(this);

  AgendamentoSituacao get situacao => AgendamentoSituacao.fromId(situacaoId);
  
  String get situacaoLabel => situacaoModel?.descricao ?? situacao.descricao;
  
  /// Calcula o valor total dos serviços
  double get valorTotal {
    if (servicos == null || servicos!.isEmpty) return 0;
    return servicos!.fold(0.0, (sum, s) {
      final servico = s.servico;
      if (servico == null) return sum;
      try {
        return sum + double.parse(servico.preco);
      } catch (_) {
        return sum;
      }
    });
  }
  
  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

/// Helper para converter ano que pode vir como String ou int
int? _parseAno(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}

@JsonSerializable()
class AgendamentoCarro {
  final int id;
  final String marca;
  final String modelo;
  final String? placa;
  final String cor;
  
  @JsonKey(fromJson: _parseAno)
  final int? ano;

  AgendamentoCarro({
    required this.id,
    required this.marca,
    required this.modelo,
    this.placa,
    required this.cor,
    this.ano,
  });

  factory AgendamentoCarro.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoCarroFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoCarroToJson(this);

  String get nomeCompleto => '$marca $modelo';
}

/// Modelo para a situação retornada pela API
@JsonSerializable()
class AgendamentoSituacaoModel {
  final int id;
  final String descricao;

  AgendamentoSituacaoModel({
    required this.id,
    required this.descricao,
  });

  factory AgendamentoSituacaoModel.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoSituacaoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoSituacaoModelToJson(this);
}

/// Relação entre agendamento e serviço (vem da tabela de relacionamento)
@JsonSerializable()
class AgendamentoServicoRelation {
  final int? servicoId;
  final AgendamentoServico? servico;

  AgendamentoServicoRelation({
    this.servicoId,
    this.servico,
  });

  factory AgendamentoServicoRelation.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoServicoRelationFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoServicoRelationToJson(this);
}

@JsonSerializable()
class AgendamentoSlot {
  final int id;
  final String slotTempo;
  final bool? disponivel;
  final int? programacaoId;
  final AgendamentoProgramacao? programacao;

  AgendamentoSlot({
    required this.id,
    required this.slotTempo,
    this.disponivel,
    this.programacaoId,
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
  final String? horaInicio;
  final String? horaTermino;
  final AgendamentoEstabelecimento? estabelecimento;

  AgendamentoProgramacao({
    required this.id,
    required this.data,
    required this.estabelecimentoId,
    this.horaInicio,
    this.horaTermino,
    this.estabelecimento,
  });

  factory AgendamentoProgramacao.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoProgramacaoFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoProgramacaoToJson(this);

  DateTime get dataAsDateTime => DateTime.parse(data);
}

/// Modelo simplificado do estabelecimento para o agendamento
@JsonSerializable()
class AgendamentoEstabelecimento {
  final int id;
  final String nomeFantasia;
  final String? cnpj;

  AgendamentoEstabelecimento({
    required this.id,
    required this.nomeFantasia,
    this.cnpj,
  });

  factory AgendamentoEstabelecimento.fromJson(Map<String, dynamic> json) =>
      _$AgendamentoEstabelecimentoFromJson(json);

  Map<String, dynamic> toJson() => _$AgendamentoEstabelecimentoToJson(this);
}

@JsonSerializable()
class AgendamentoServico {
  final int id;
  final String titulo;
  final String preco;
  final String? tempoEstimado;
  final String? descricao;

  AgendamentoServico({
    required this.id,
    required this.titulo,
    required this.preco,
    this.tempoEstimado,
    this.descricao,
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
  
  String get tempoFormatado {
    if (tempoEstimado == null) return '';
    // Formato HH:mm:ss para exibição mais amigável
    final parts = tempoEstimado!.split(':');
    if (parts.length >= 2) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}min';
      } else if (hours > 0) {
        return '${hours}h';
      } else if (minutes > 0) {
        return '${minutes}min';
      }
    }
    return tempoEstimado!;
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
