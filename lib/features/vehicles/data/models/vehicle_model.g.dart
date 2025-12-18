// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleModel _$VehicleModelFromJson(Map<String, dynamic> json) => VehicleModel(
  id: (json['id'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  active: json['active'] as bool,
  clienteId: (json['clienteId'] as num).toInt(),
  marca: json['marca'] as String,
  modelo: json['modelo'] as String,
  ano: VehicleModel._anoFromJson(json['ano']),
  cor: json['cor'] as String,
  placa: json['placa'] as String?,
);

Map<String, dynamic> _$VehicleModelToJson(VehicleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'active': instance.active,
      'clienteId': instance.clienteId,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'ano': instance.ano,
      'cor': instance.cor,
      'placa': instance.placa,
    };

CreateVehicleDto _$CreateVehicleDtoFromJson(Map<String, dynamic> json) =>
    CreateVehicleDto(
      clienteId: (json['clienteId'] as num?)?.toInt(),
      marca: json['marca'] as String,
      modelo: json['modelo'] as String,
      ano: json['ano'] as String,
      cor: json['cor'] as String,
      placa: json['placa'] as String?,
    );

Map<String, dynamic> _$CreateVehicleDtoToJson(CreateVehicleDto instance) =>
    <String, dynamic>{
      'clienteId': instance.clienteId,
      'marca': instance.marca,
      'modelo': instance.modelo,
      'ano': instance.ano,
      'cor': instance.cor,
      'placa': instance.placa,
    };

UpdateVehicleDto _$UpdateVehicleDtoFromJson(Map<String, dynamic> json) =>
    UpdateVehicleDto(
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      ano: json['ano'] as String?,
      cor: json['cor'] as String?,
      placa: json['placa'] as String?,
    );

Map<String, dynamic> _$UpdateVehicleDtoToJson(UpdateVehicleDto instance) =>
    <String, dynamic>{
      'marca': instance.marca,
      'modelo': instance.modelo,
      'ano': instance.ano,
      'cor': instance.cor,
      'placa': instance.placa,
    };
