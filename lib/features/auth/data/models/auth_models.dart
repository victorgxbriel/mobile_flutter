import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

// --- MODELO DE PERFIL DO USUÁRIO (Baseado no ProfileResponseDto do /auth/me) ---
@JsonSerializable()
class ProfileModel {
  final int id;
  final String nome;
  final String email;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final List<String> roles;
  final int? clienteId; // Presente se role = CLIENTE
  final int? estabelecimentoId; // Presente se role = GERENTE, PROPRIETARIO ou FUNCIONARIO
  
  ProfileModel({
    required this.id,
    required this.nome,
    required this.email,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.roles,
    this.clienteId,
    this.estabelecimentoId,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  /// Verifica se o usuário é cliente
  bool get isCliente => roles.contains('CLIENTE');
  
  /// Verifica se o usuário é do estabelecimento (gerente, proprietário ou funcionário)
  bool get isEstabelecimento => 
      roles.contains('GERENTE') || 
      roles.contains('PROPRIETARIO') || 
      roles.contains('FUNCIONARIO');
}

// --- DTO DE LOGIN (Request) ---
@JsonSerializable()
class LoginDto {
  final String email;
  final String password;

  LoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() => _$LoginDtoToJson(this);
}

// --- RESPOSTA DO LOGIN (Response) ---
@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  LoginResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
}

// --- DTO PARA REFRESH TOKEN (Request) ---
@JsonSerializable()
class RefreshTokenDto {
  final String refreshToken;

  RefreshTokenDto({required this.refreshToken});

  Map<String, dynamic> toJson() => _$RefreshTokenDtoToJson(this);
}

// --- RESPOSTA DO REFRESH TOKEN (Response) ---
@JsonSerializable()
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  
  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  RefreshTokenResponse({
    required this.accessToken,
    this.refreshToken,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => _$RefreshTokenResponseFromJson(json);
}

@JsonSerializable()
class RegisterDto {
  final String nome;
  final String email;
  final String password;
  final String cpf; // Lembre-se: String para documentos

  RegisterDto({
    required this.nome,
    required this.email,
    required this.password,
    required this.cpf,
  });

  Map<String, dynamic> toJson() => _$RegisterDtoToJson(this);
}

// --- RESPOSTA DO REGISTRO (Response) ---
@JsonSerializable()
class RegisterResponse {
  final String message;
  final int userId;

  RegisterResponse({required this.message, required this.userId});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => _$RegisterResponseFromJson(json);
}

// --- DTO DE REGISTRO CLIENTE (Para uso na UI) ---
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
}

// --- DTO DE REGISTRO ESTABELECIMENTO (Para uso na UI) ---
class RegisterEstablishmentDto {
  final String nome; // Nome do responsável
  final String email;
  final String password;
  final String nomeEstabelecimento; // Nome fantasia
  final String cnpj;

  RegisterEstablishmentDto({
    required this.nome,
    required this.email,
    required this.password,
    required this.nomeEstabelecimento,
    required this.cnpj,
  });
}

// --- DTO PARA CRIAR CLIENTE (Endpoint /clientes) ---
@JsonSerializable()
class CreateClienteDto {
  final String nome;
  final String cpf;
  final String email;

  CreateClienteDto({
    required this.nome,
    required this.cpf,
    required this.email,
  });

  Map<String, dynamic> toJson() => _$CreateClienteDtoToJson(this);
}

// --- DTO PARA SETUP DE ESTABELECIMENTO (Endpoint /estabelecimentos/setup) ---
@JsonSerializable()
class SetupEstabelecimentoDto {
  final UsuarioSetupDto usuario;
  final EstabelecimentoSetupDto estabelecimento;

  SetupEstabelecimentoDto({
    required this.usuario,
    required this.estabelecimento,
  });

  Map<String, dynamic> toJson() => _$SetupEstabelecimentoDtoToJson(this);
}

@JsonSerializable()
class UsuarioSetupDto {
  final String nome;
  final String email;
  final String password;

  UsuarioSetupDto({
    required this.nome,
    required this.email,
    required this.password,
  });

  factory UsuarioSetupDto.fromJson(Map<String, dynamic> json) => _$UsuarioSetupDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UsuarioSetupDtoToJson(this);
}

@JsonSerializable()
class EstabelecimentoSetupDto {
  final String cnpj;
  final String nomeFantasia;

  EstabelecimentoSetupDto({
    required this.cnpj,
    required this.nomeFantasia,
  });

  factory EstabelecimentoSetupDto.fromJson(Map<String, dynamic> json) => _$EstabelecimentoSetupDtoFromJson(json);
  Map<String, dynamic> toJson() => _$EstabelecimentoSetupDtoToJson(this);
}

// --- DTO PARA FORGOT PASSWORD (Request) ---
@JsonSerializable()
class ForgotPasswordDto {
  final String email;

  ForgotPasswordDto({required this.email});

  Map<String, dynamic> toJson() => _$ForgotPasswordDtoToJson(this);
}

// --- DTO PARA RESET PASSWORD (Request) ---
@JsonSerializable()
class ResetPasswordDto {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordDto({
    required this.email,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);
}