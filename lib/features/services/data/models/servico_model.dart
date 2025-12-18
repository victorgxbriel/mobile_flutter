import 'package:json_annotation/json_annotation.dart';

part 'servico_model.g.dart';

/// Modelo do Serviço retornado pela API
@JsonSerializable()
class ServicoModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String titulo;
  final String? descricao;
  final String preco;
  final String tempoEstimado; // Duration ISO 8601 (ex: PT30M, PT1H30M)
  final int estabelecimentoId;
  final int? tipoServicoId;

  ServicoModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.titulo,
    this.descricao,
    required this.preco,
    required this.tempoEstimado,
    required this.estabelecimentoId,
    this.tipoServicoId,
  });

  factory ServicoModel.fromJson(Map<String, dynamic> json) =>
      _$ServicoModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServicoModelToJson(this);

  /// Factory para criar um modelo de skeleton (mock para loading)
  factory ServicoModel.skeleton() {
    return ServicoModel(
      id: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      active: true,
      titulo: 'Serviço Exemplo',
      descricao: 'Descrição do serviço',
      preco: '50.00',
      tempoEstimado: 'PT30M',
      estabelecimentoId: 0,
      tipoServicoId: null,
    );
  }

  ServicoModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? titulo,
    String? descricao,
    String? preco,
    String? tempoEstimado,
    int? estabelecimentoId,
    int? tipoServicoId,
  }) {
    return ServicoModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      tempoEstimado: tempoEstimado ?? this.tempoEstimado,
      estabelecimentoId: estabelecimentoId ?? this.estabelecimentoId,
      tipoServicoId: tipoServicoId ?? this.tipoServicoId,
    );
  }

  /// Formata o preço para exibição (ex: R$ 50,00)
  String get precoFormatado {
    final priceValue = double.tryParse(preco) ?? 0.0;
    return 'R\$ ${priceValue.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Converte tempoEstimado ISO 8601 Duration em minutos
  int get duracaoMinutos {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
    final match = regex.firstMatch(tempoEstimado);
    if (match == null) return 0;

    final horas = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutos = int.tryParse(match.group(2) ?? '0') ?? 0;
    return (horas * 60) + minutos;
  }

  /// Formata a duração para exibição (ex: 30 min, 1h 30min)
  String get duracaoFormatada {
    final minutos = duracaoMinutos;
    if (minutos < 60) {
      return '$minutos min';
    }
    final horas = minutos ~/ 60;
    final mins = minutos % 60;
    if (mins == 0) {
      return '${horas}h';
    }
    return '${horas}h ${mins}min';
  }
}

/// DTO para criar serviço
@JsonSerializable(includeIfNull: false)
class CreateServicoDto {
  final String titulo;
  final String? descricao;
  final String preco;
  final String tempoEstimado; // ISO 8601 Duration (ex: PT30M, PT1H30M)
  final int estabelecimentoId;
  final int? tipoServicoId;

  CreateServicoDto({
    required this.titulo,
    this.descricao,
    required this.preco,
    required this.tempoEstimado,
    required this.estabelecimentoId,
    this.tipoServicoId,
  });

  Map<String, dynamic> toJson() => _$CreateServicoDtoToJson(this);
}

/// DTO para atualizar serviço
@JsonSerializable(includeIfNull: false)
class UpdateServicoDto {
  final String? titulo;
  final String? descricao;
  final String? preco;
  final String? tempoEstimado; // ISO 8601 Duration (ex: PT30M, PT1H30M)
  final int? tipoServicoId;

  UpdateServicoDto({
    this.titulo,
    this.descricao,
    this.preco,
    this.tempoEstimado,
    this.tipoServicoId,
  });

  Map<String, dynamic> toJson() => _$UpdateServicoDtoToJson(this);
}
