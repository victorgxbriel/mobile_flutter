import 'package:json_annotation/json_annotation.dart';

part 'cliente_model.g.dart';

/// Modelo da relação Cliente-Estabelecimento retornado pela API
/// GET /estabelecimentos/{id}/clientes
@JsonSerializable()
class ClienteModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final int clienteId;
  final int estabelecimentoId;

  // Dados do cliente (quando a API retorna populado)
  final ClienteDetalheModel? cliente;

  ClienteModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.clienteId,
    required this.estabelecimentoId,
    this.cliente,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) =>
      _$ClienteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteModelToJson(this);

  /// Nome de exibição do cliente
  String get nomeExibicao => cliente?.nome ?? 'Cliente #$clienteId';

  /// CPF formatado para exibição
  String get cpfFormatado {
    final cpf = cliente?.cpf;
    if (cpf == null || cpf.isEmpty) return '';
    final cleaned = cpf.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 11) return cpf;
    return '${cleaned.substring(0, 3)}.${cleaned.substring(3, 6)}.${cleaned.substring(6, 9)}-${cleaned.substring(9)}';
  }

  /// Factory para criar um modelo de skeleton (mock para loading)
  factory ClienteModel.skeleton() {
    return ClienteModel(
      id: 0,
      createdAt: DateTime.now(),
      active: true,
      clienteId: 0,
      estabelecimentoId: 0,
    );
  }
}

/// Modelo dos detalhes do cliente (dados aninhados)
@JsonSerializable()
class ClienteDetalheModel {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? active;
  final String? nome;
  final String? cpf;
  final String? email;
  final int? userId;

  ClienteDetalheModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.active,
    this.nome,
    this.cpf,
    this.email,
    this.userId,
  });

  factory ClienteDetalheModel.fromJson(Map<String, dynamic> json) =>
      _$ClienteDetalheModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteDetalheModelToJson(this);
}

/// Modelo simplificado do Carro do Cliente
@JsonSerializable()
class ClienteCarroModel {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? active;
  final int? clienteId;
  final String marca;
  final String modelo;
  final String? placa;
  final String cor;
  @JsonKey(fromJson: _parseAno)
  final int? ano;

  ClienteCarroModel({
    required this.id,
    this.createdAt,
    this.updatedAt,
    this.active,
    this.clienteId,
    required this.marca,
    required this.modelo,
    this.placa,
    required this.cor,
    this.ano,
  });

  factory ClienteCarroModel.fromJson(Map<String, dynamic> json) =>
      _$ClienteCarroModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteCarroModelToJson(this);

  /// Nome completo do veículo
  String get nomeCompleto => '$marca $modelo';

  /// Descrição do veículo para exibição
  String get descricao {
    final parts = <String>[];
    parts.add(nomeCompleto);
    if (cor.isNotEmpty) parts.add(cor);
    if (ano != null) parts.add(ano.toString());
    return parts.join(' - ');
  }

  factory ClienteCarroModel.skeleton() => ClienteCarroModel(
    id: 0,
    marca: 'Marca',
    modelo: 'Modelo',
    placa: 'ABC1234',
    cor: 'Cor',
    ano: 2024,
  );
}

/// Helper para converter ano que pode vir como String ou int
int? _parseAno(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is num) return value.toInt();
  return null;
}
