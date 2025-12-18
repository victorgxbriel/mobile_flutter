import 'package:json_annotation/json_annotation.dart';

part 'atendimento_model.g.dart';

/// Situações possíveis do atendimento
enum AtendimentoSituacao {
  @JsonValue(1)
  aguardando(1, 'Aguardando'),
  @JsonValue(2)
  emAndamento(2, 'Em Andamento'),
  @JsonValue(3)
  concluido(3, 'Concluído'),
  @JsonValue(4)
  cancelado(4, 'Cancelado');

  final int id;
  final String descricao;

  const AtendimentoSituacao(this.id, this.descricao);

  static AtendimentoSituacao fromId(int id) {
    return AtendimentoSituacao.values.firstWhere(
      (s) => s.id == id,
      orElse: () => AtendimentoSituacao.aguardando,
    );
  }
}

@JsonSerializable()
class AtendimentoModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final String? valorTotal;
  final String? valorDesconto;
  final DateTime? horaInicio;
  final DateTime? horaTerminio;
  final int? posicaoFila;
  final int situacaoId;
  final int? agendamentoId;
  final int estabelecimentoId;

  // Relacionamentos
  final AtendimentoSituacaoModel? situacao;
  final AtendimentoAgendamento? agendamento;
  final List<AtendimentoServicoRelation>? servicos;
  final List<AtendimentoAcessorioRelation>? acessorios;

  AtendimentoModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    this.valorTotal,
    this.valorDesconto,
    this.horaInicio,
    this.horaTerminio,
    this.posicaoFila,
    required this.situacaoId,
    this.agendamentoId,
    required this.estabelecimentoId,
    this.situacao,
    this.agendamento,
    this.servicos,
    this.acessorios,
  });

  factory AtendimentoModel.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoModelToJson(this);

  AtendimentoSituacao get situacaoEnum =>
      AtendimentoSituacao.fromId(situacaoId);

  String get situacaoLabel => situacao?.descricao ?? situacaoEnum.descricao;

  /// Calcula o valor total dos serviços
  double get valorTotalDouble {
    if (valorTotal == null) return 0;
    try {
      return double.parse(valorTotal!);
    } catch (_) {
      return 0;
    }
  }

  String get valorTotalFormatado {
    return 'R\$ ${valorTotalDouble.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Data do atendimento (da hora de início ou criação)
  DateTime get dataAtendimento => horaInicio ?? createdAt;

  /// Factory para criar um model vazio (usado para skeleton loaders)
  factory AtendimentoModel.skeleton() => AtendimentoModel(
    id: 0,
    createdAt: DateTime.now(),
    active: true,
    situacaoId: 1,
    estabelecimentoId: 0,
    valorTotal: '50.00',
    servicos: [
      AtendimentoServicoRelation.skeleton(),
      AtendimentoServicoRelation.skeleton(),
    ],
  );
}

@JsonSerializable()
class AtendimentoSituacaoModel {
  final int id;
  final String descricao;

  AtendimentoSituacaoModel({required this.id, required this.descricao});

  factory AtendimentoSituacaoModel.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoSituacaoModelFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoSituacaoModelToJson(this);
}

@JsonSerializable()
class AtendimentoAgendamento {
  final int? id;
  final int carroId;
  final int slotId;
  final int? situacaoId;
  final AtendimentoCarro? carro;
  final AtendimentoSlot? slot;

  AtendimentoAgendamento({
    this.id,
    required this.carroId,
    required this.slotId,
    this.situacaoId,
    this.carro,
    this.slot,
  });

  factory AtendimentoAgendamento.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoAgendamentoFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoAgendamentoToJson(this);
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
class AtendimentoCarro {
  final int id;
  final String marca;
  final String modelo;
  final String? placa;
  final String cor;

  @JsonKey(fromJson: _parseAno)
  final int? ano;

  AtendimentoCarro({
    required this.id,
    required this.marca,
    required this.modelo,
    this.placa,
    required this.cor,
    this.ano,
  });

  factory AtendimentoCarro.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoCarroFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoCarroToJson(this);

  String get nomeCompleto => '$marca $modelo';

  factory AtendimentoCarro.skeleton() => AtendimentoCarro(
    id: 0,
    marca: 'Marca Exemplo',
    modelo: 'Modelo',
    cor: 'Cor',
    placa: 'ABC1D23',
    ano: 2024,
  );
}

@JsonSerializable()
class AtendimentoSlot {
  final int id;
  final String slotTempo;
  final int? programacaoId;
  final AtendimentoProgramacao? programacao;

  AtendimentoSlot({
    required this.id,
    required this.slotTempo,
    this.programacaoId,
    this.programacao,
  });

  factory AtendimentoSlot.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoSlotFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoSlotToJson(this);

  String get horarioFormatado {
    if (slotTempo.contains(':')) {
      return slotTempo.substring(0, 5);
    }
    return slotTempo;
  }
}

@JsonSerializable()
class AtendimentoProgramacao {
  final int id;
  final String data;
  final int estabelecimentoId;

  AtendimentoProgramacao({
    required this.id,
    required this.data,
    required this.estabelecimentoId,
  });

  factory AtendimentoProgramacao.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoProgramacaoFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoProgramacaoToJson(this);

  DateTime get dataAsDateTime => DateTime.parse(data);
}

@JsonSerializable()
class AtendimentoServicoRelation {
  final int? id;
  final int? servicoId;
  final int? quantidade;
  final String? valorUnitario;
  final String? desconto;
  final AtendimentoServico? servico;

  AtendimentoServicoRelation({
    this.id,
    this.servicoId,
    this.quantidade,
    this.valorUnitario,
    this.desconto,
    this.servico,
  });

  factory AtendimentoServicoRelation.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoServicoRelationFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoServicoRelationToJson(this);

  factory AtendimentoServicoRelation.skeleton() => AtendimentoServicoRelation(
    id: 0,
    servicoId: 0,
    quantidade: 1,
    valorUnitario: '50.00',
    servico: AtendimentoServico.skeleton(),
  );
}

@JsonSerializable()
class AtendimentoServico {
  final int id;
  final String titulo;
  final String preco;
  final String? tempoEstimado;
  final String? descricao;

  AtendimentoServico({
    required this.id,
    required this.titulo,
    required this.preco,
    this.tempoEstimado,
    this.descricao,
  });

  factory AtendimentoServico.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoServicoFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoServicoToJson(this);

  String get precoFormatado {
    try {
      final valor = double.parse(preco);
      return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$ $preco';
    }
  }

  factory AtendimentoServico.skeleton() => AtendimentoServico(
    id: 0,
    titulo: 'Serviço Exemplo',
    preco: '50.00',
    tempoEstimado: '01:00:00',
    descricao: 'Descrição do serviço',
  );
}

@JsonSerializable()
class AtendimentoAcessorioRelation {
  final int? id;
  final int? acessorioId;
  final int? quantidade;
  final String? valorUnitario;
  final String? desconto;
  final AtendimentoAcessorio? acessorio;

  AtendimentoAcessorioRelation({
    this.id,
    this.acessorioId,
    this.quantidade,
    this.valorUnitario,
    this.desconto,
    this.acessorio,
  });

  factory AtendimentoAcessorioRelation.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoAcessorioRelationFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoAcessorioRelationToJson(this);
}

@JsonSerializable()
class AtendimentoAcessorio {
  final int id;
  final String nome;
  final String preco;

  AtendimentoAcessorio({
    required this.id,
    required this.nome,
    required this.preco,
  });

  factory AtendimentoAcessorio.fromJson(Map<String, dynamic> json) =>
      _$AtendimentoAcessorioFromJson(json);

  Map<String, dynamic> toJson() => _$AtendimentoAcessorioToJson(this);
}
