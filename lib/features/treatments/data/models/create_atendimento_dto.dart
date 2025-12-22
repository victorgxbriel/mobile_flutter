import 'package:json_annotation/json_annotation.dart';

part 'create_atendimento_dto.g.dart';

/// DTO para criar um novo atendimento
@JsonSerializable(includeIfNull: false)
class CreateAtendimentoDto {
  final int estabelecimentoId;
  final int clienteId;
  final int carroId;
  final int? situacaoId; // Default: 1 (Em Espera)
  final List<CreateServicoAtendimentoItem> servicos;
  final List<CreateAcessorioAtendimentoItem>? acessorios;

  CreateAtendimentoDto({
    required this.estabelecimentoId,
    required this.clienteId,
    required this.carroId,
    this.situacaoId,
    required this.servicos,
    this.acessorios,
  });

  factory CreateAtendimentoDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAtendimentoDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAtendimentoDtoToJson(this);
}

/// Item de serviço para adicionar ao atendimento
@JsonSerializable(includeIfNull: false)
class CreateServicoAtendimentoItem {
  final int servicoId;
  final String valorUnitario;
  final int quantidade;
  final String? desconto;

  CreateServicoAtendimentoItem({
    required this.servicoId,
    required this.valorUnitario,
    this.quantidade = 1,
    this.desconto,
  });

  factory CreateServicoAtendimentoItem.fromJson(Map<String, dynamic> json) =>
      _$CreateServicoAtendimentoItemFromJson(json);
  Map<String, dynamic> toJson() => _$CreateServicoAtendimentoItemToJson(this);

  /// Valor total do item (valorUnitario * quantidade)
  double get valorTotal {
    final valor = double.tryParse(valorUnitario) ?? 0;
    final desc = double.tryParse(desconto ?? '0') ?? 0;
    return (valor * quantidade) - desc;
  }
}

/// Item de acessório para adicionar ao atendimento
@JsonSerializable(includeIfNull: false)
class CreateAcessorioAtendimentoItem {
  final int acessorioId;
  final String valorUnitario;
  final int quantidade;
  final String? desconto;

  CreateAcessorioAtendimentoItem({
    required this.acessorioId,
    required this.valorUnitario,
    this.quantidade = 1,
    this.desconto,
  });

  factory CreateAcessorioAtendimentoItem.fromJson(Map<String, dynamic> json) =>
      _$CreateAcessorioAtendimentoItemFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAcessorioAtendimentoItemToJson(this);

  /// Valor total do item (valorUnitario * quantidade)
  double get valorTotal {
    final valor = double.tryParse(valorUnitario) ?? 0;
    final desc = double.tryParse(desconto ?? '0') ?? 0;
    return (valor * quantidade) - desc;
  }
}
