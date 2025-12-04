import 'package:json_annotation/json_annotation.dart';

part 'vehicle_model.g.dart';

@JsonSerializable()
class VehicleModel {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool active;
  final int clienteId;
  final String marca;
  final String modelo;
  final String ano;
  final String cor;
  final String? placa;

  VehicleModel({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.active,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.cor,
    this.placa,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelToJson(this);

  /// Retorna o nome completo do veículo (Marca Modelo)
  String get nomeCompleto => '$marca $modelo';

  /// Retorna a placa formatada (ABC-1234 ou ABC1D23)
  String? get placaFormatada {
    if (placa == null || placa!.isEmpty) return null;
    if (placa!.length == 7) {
      // Formato antigo: ABC-1234
      if (RegExp(r'^[A-Z]{3}\d{4}$').hasMatch(placa!)) {
        return '${placa!.substring(0, 3)}-${placa!.substring(3)}';
      }
      // Formato Mercosul: ABC1D23
      return placa;
    }
    return placa;
  }
}

@JsonSerializable()
class CreateVehicleDto {
  final int? clienteId;
  final String marca;
  final String modelo;
  final String ano;
  final String cor;
  final String? placa;

  CreateVehicleDto({
    this.clienteId,
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.cor,
    this.placa,
  });

  factory CreateVehicleDto.fromJson(Map<String, dynamic> json) =>
      _$CreateVehicleDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateVehicleDtoToJson(this);
}

@JsonSerializable()
class UpdateVehicleDto {
  final String? marca;
  final String? modelo;
  final String? ano;
  final String? cor;
  final String? placa;

  UpdateVehicleDto({
    this.marca,
    this.modelo,
    this.ano,
    this.cor,
    this.placa,
  });

  factory UpdateVehicleDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateVehicleDtoFromJson(json);

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (marca != null) json['marca'] = marca;
    if (modelo != null) json['modelo'] = modelo;
    if (ano != null) json['ano'] = ano;
    if (cor != null) json['cor'] = cor;
    if (placa != null) json['placa'] = placa;
    return json;
  }
}
