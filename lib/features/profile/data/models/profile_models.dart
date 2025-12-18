import 'package:json_annotation/json_annotation.dart';

part 'profile_models.g.dart';

/// Modelo do Cliente retornado pela API (GET /clientes/{id})
@JsonSerializable()
class ClienteModel {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;
  final String nome;
  final String cpf;
  final String email;
  final int? userId;
  final String? fotoUrl;

  ClienteModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.nome,
    required this.cpf,
    required this.email,
    this.userId,
    this.fotoUrl,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) =>
      _$ClienteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteModelToJson(this);

  /// Factory para criar um modelo de skeleton (mock para loading)
  factory ClienteModel.skeleton() {
    return ClienteModel(
      id: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      active: true,
      nome: 'Nome do Cliente Exemplo',
      cpf: '000.000.000-00',
      email: 'cliente@email.com',
      userId: 0,
      fotoUrl: null,
    );
  }

  ClienteModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? nome,
    String? cpf,
    String? email,
    int? userId,
    String? fotoUrl,
  }) {
    return ClienteModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      active: active ?? this.active,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      userId: userId ?? this.userId,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}

/// DTO para atualizar cliente (PATCH /clientes/{id})
@JsonSerializable()
class UpdateClienteDto {
  final String? nome;
  final String? cpf;
  final String? email;
  final String? fotoUrl;

  UpdateClienteDto({this.nome, this.cpf, this.email, this.fotoUrl});

  Map<String, dynamic> toJson() => _$UpdateClienteDtoToJson(this);
}

@JsonSerializable()
class EstabelecimentoModel {
  final int id;
  final String cnpj;
  final String nomeFantasia;
  final String? avaliacaoMedia;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool active;

  EstabelecimentoModel({
    required this.id,
    required this.cnpj,
    required this.nomeFantasia,
    this.avaliacaoMedia,
    required this.createdAt,
    required this.updatedAt,
    required this.active
  });

  factory EstabelecimentoModel.fromJson(Map<String, dynamic> json) => 
      _$EstabelecimentoModelFromJson(json);
  Map<String, dynamic> toJson() => _$EstabelecimentoModelToJson(this);

  /// Formata o CNPJ para exibição (XX.XXX.XXX/XXXX-XX)
  String get cnpjFormatado {
    if (cnpj.length != 14) return cnpj;
    return '${cnpj.substring(0, 2)}.${cnpj.substring(2, 5)}.${cnpj.substring(5, 8)}/${cnpj.substring(8, 12)}-${cnpj.substring(12)}';
  }

  factory EstabelecimentoModel.skeleton() {
    return EstabelecimentoModel(
      id: 1, 
      cnpj: "00000000000000", 
      nomeFantasia: "Lava-jato", 
      avaliacaoMedia: "4.6", 
      createdAt: DateTime.now(), 
      updatedAt: DateTime.now(),
      active: true
    );
  }

  EstabelecimentoModel copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? active,
    String? cnpj,
    String? nomeFantasia,
    String? avaliacaoMedia
  }) {
    return EstabelecimentoModel(
      id: id ?? this.id,
      cnpj: cnpj ?? this.cnpj, 
      nomeFantasia: nomeFantasia ?? this.nomeFantasia, 
      avaliacaoMedia: avaliacaoMedia ?? this.avaliacaoMedia, 
      createdAt: createdAt ?? this.createdAt, 
      updatedAt: updatedAt ?? this.updatedAt, 
      active: active ?? this.active
    );
  }
}

@JsonSerializable()
class UpdateEstabelecimentoDto {
  final String? cnpj;
  final String? nomeFantasia;

  UpdateEstabelecimentoDto({this.cnpj, this.nomeFantasia});
  Map<String, dynamic> toJson() => _$UpdateEstabelecimentoDtoToJson(this);
}