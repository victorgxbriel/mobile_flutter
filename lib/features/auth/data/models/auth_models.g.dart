// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num).toInt(),
  nome: json['nome'] as String,
  email: json['email'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  clienteId: (json['clienteId'] as num?)?.toInt(),
  estabelecimentoId: (json['estabelecimentoId'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'email': instance.email,
      'avatarUrl': instance.avatarUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'roles': instance.roles,
      'clienteId': instance.clienteId,
      'estabelecimentoId': instance.estabelecimentoId,
    };

LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => LoginDto(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginDtoToJson(LoginDto instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

RefreshTokenDto _$RefreshTokenDtoFromJson(Map<String, dynamic> json) =>
    RefreshTokenDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenDtoToJson(RefreshTokenDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};

RefreshTokenResponse _$RefreshTokenResponseFromJson(
  Map<String, dynamic> json,
) => RefreshTokenResponse(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String?,
);

Map<String, dynamic> _$RefreshTokenResponseToJson(
  RefreshTokenResponse instance,
) => <String, dynamic>{
  'access_token': instance.accessToken,
  'refresh_token': instance.refreshToken,
};

RegisterDto _$RegisterDtoFromJson(Map<String, dynamic> json) => RegisterDto(
  nome: json['nome'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
  cpf: json['cpf'] as String,
);

Map<String, dynamic> _$RegisterDtoToJson(RegisterDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'email': instance.email,
      'password': instance.password,
      'cpf': instance.cpf,
    };

RegisterResponse _$RegisterResponseFromJson(Map<String, dynamic> json) =>
    RegisterResponse(
      message: json['message'] as String,
      userId: (json['userId'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterResponseToJson(RegisterResponse instance) =>
    <String, dynamic>{'message': instance.message, 'userId': instance.userId};

CreateClienteDto _$CreateClienteDtoFromJson(Map<String, dynamic> json) =>
    CreateClienteDto(
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$CreateClienteDtoToJson(CreateClienteDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'cpf': instance.cpf,
      'email': instance.email,
    };

SetupEstabelecimentoDto _$SetupEstabelecimentoDtoFromJson(
  Map<String, dynamic> json,
) => SetupEstabelecimentoDto(
  usuario: UsuarioSetupDto.fromJson(json['usuario'] as Map<String, dynamic>),
  estabelecimento: EstabelecimentoSetupDto.fromJson(
    json['estabelecimento'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$SetupEstabelecimentoDtoToJson(
  SetupEstabelecimentoDto instance,
) => <String, dynamic>{
  'usuario': instance.usuario,
  'estabelecimento': instance.estabelecimento,
};

UsuarioSetupDto _$UsuarioSetupDtoFromJson(Map<String, dynamic> json) =>
    UsuarioSetupDto(
      nome: json['nome'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$UsuarioSetupDtoToJson(UsuarioSetupDto instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'email': instance.email,
      'password': instance.password,
    };

EstabelecimentoSetupDto _$EstabelecimentoSetupDtoFromJson(
  Map<String, dynamic> json,
) => EstabelecimentoSetupDto(
  cnpj: json['cnpj'] as String,
  nomeFantasia: json['nomeFantasia'] as String,
);

Map<String, dynamic> _$EstabelecimentoSetupDtoToJson(
  EstabelecimentoSetupDto instance,
) => <String, dynamic>{
  'cnpj': instance.cnpj,
  'nomeFantasia': instance.nomeFantasia,
};

ForgotPasswordDto _$ForgotPasswordDtoFromJson(Map<String, dynamic> json) =>
    ForgotPasswordDto(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordDtoToJson(ForgotPasswordDto instance) =>
    <String, dynamic>{'email': instance.email};

ResetPasswordDto _$ResetPasswordDtoFromJson(Map<String, dynamic> json) =>
    ResetPasswordDto(
      email: json['email'] as String,
      code: json['code'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ResetPasswordDtoToJson(ResetPasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'code': instance.code,
      'newPassword': instance.newPassword,
    };
