// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};

RegisterClientDto _$RegisterClientDtoFromJson(Map<String, dynamic> json) =>
    RegisterClientDto(
      nome: json['nome'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      cpf: json['cpf'] as String,
    );

Map<String, dynamic> _$RegisterClientDtoToJson(RegisterClientDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'email': instance.email,
      'password': instance.password,
      'cpf': instance.cpf,
    };

RegisterEstablishmentDto _$RegisterEstablishmentDtoFromJson(
  Map<String, dynamic> json,
) => RegisterEstablishmentDto(
  nome: json['nome'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  nomeEstabelecimento: json['nomeEstabelecimento'] as String,
);

Map<String, dynamic> _$RegisterEstablishmentDtoToJson(
  RegisterEstablishmentDto instance,
) => <String, dynamic>{
  'nome': instance.nome,
  'email': instance.email,
  'password': instance.password,
  'nomeEstabelecimento': instance.nomeEstabelecimento,
};

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  nome: json['nome'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'email': instance.email,
  'avatarUrl': instance.avatarUrl,
  'isActive': instance.isActive,
};
