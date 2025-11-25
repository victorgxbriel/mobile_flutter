import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}

@JsonSerializable()
class RegisterClientDto {
  final String nome;
  final String email;
  final String password;
  final String cpf;

  RegisterClientDto({
    required this.nome,
    required this.email,
    required this.password,
    required this.cpf,
  });

  Map<String, dynamic> toJson() => _$RegisterClientDtoToJson(this);
}

@JsonSerializable()
class RegisterEstablishmentDto {
  final String nome; // Nome do responsável
  final String email;
  final String password;
  final String nomeEstabelecimento;
  // Adicione outros campos conforme necessário para o setup inicial

  RegisterEstablishmentDto({
    required this.nome,
    required this.email,
    required this.password,
    required this.nomeEstabelecimento,
  });

  Map<String, dynamic> toJson() => _$RegisterEstablishmentDtoToJson(this);
}

@JsonSerializable()
class User {
  final int? id;
  final String nome;
  final String email;
  final String? avatarUrl;
  final bool isActive;

  User({
    this.id,
    required this.nome,
    required this.email,
    this.avatarUrl,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
