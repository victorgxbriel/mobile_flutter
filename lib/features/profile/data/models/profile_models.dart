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

  ClienteModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.active,
    required this.nome,
    required this.cpf,
    required this.email,
    this.userId,
  });

  factory ClienteModel.fromJson(Map<String, dynamic> json) => _$ClienteModelFromJson(json);
  Map<String, dynamic> toJson() => _$ClienteModelToJson(this);
}

/// DTO para atualizar cliente (PATCH /clientes/{id})
@JsonSerializable()
class UpdateClienteDto {
  final String? nome;
  final String? cpf;
  final String? email;

  UpdateClienteDto({
    this.nome,
    this.cpf,
    this.email,
  });

  Map<String, dynamic> toJson() => _$UpdateClienteDtoToJson(this);
}
