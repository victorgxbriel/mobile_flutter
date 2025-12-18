import 'package:json_annotation/json_annotation.dart';

part 'acessorio_model.g.dart';

/// Modelo do Acessório retornado pela API
@JsonSerializable()
class AcessorioModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String titulo;
  final String? descricao;
  final String preco;
  final int estabelecimentoId;

  AcessorioModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.titulo,
    this.descricao,
    required this.preco,
    required this.estabelecimentoId,
  });

  factory AcessorioModel.fromJson(Map<String, dynamic> json) =>
      _$AcessorioModelFromJson(json);
  Map<String, dynamic> toJson() => _$AcessorioModelToJson(this);

  /// Factory para criar um modelo de skeleton (mock para loading)
  factory AcessorioModel.skeleton() {
    return AcessorioModel(
      id: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      active: true,
      titulo: 'Acessório Exemplo',
      descricao: 'Descrição do acessório',
      preco: '25.00',
      estabelecimentoId: 0,
    );
  }

  AcessorioModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? titulo,
    String? descricao,
    String? preco,
    int? estabelecimentoId,
  }) {
    return AcessorioModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      estabelecimentoId: estabelecimentoId ?? this.estabelecimentoId,
    );
  }

  /// Formata o preço para exibição (ex: R$ 25,00)
  String get precoFormatado {
    final priceValue = double.tryParse(preco) ?? 0.0;
    return 'R\$ ${priceValue.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

/// DTO para criar um novo acessório
@JsonSerializable()
class CreateAcessorioDto {
  final String titulo;
  final String? descricao;
  final String preco;
  final int estabelecimentoId;

  CreateAcessorioDto({
    required this.titulo,
    this.descricao,
    required this.preco,
    required this.estabelecimentoId,
  });

  factory CreateAcessorioDto.fromJson(Map<String, dynamic> json) =>
      _$CreateAcessorioDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateAcessorioDtoToJson(this);
}

/// DTO para atualizar um acessório existente
@JsonSerializable()
class UpdateAcessorioDto {
  final String? titulo;
  final String? descricao;
  final String? preco;

  UpdateAcessorioDto({this.titulo, this.descricao, this.preco});

  factory UpdateAcessorioDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateAcessorioDtoFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (titulo != null) json['titulo'] = titulo;
    if (descricao != null) json['descricao'] = descricao;
    if (preco != null) json['preco'] = preco;
    return json;
  }
}
