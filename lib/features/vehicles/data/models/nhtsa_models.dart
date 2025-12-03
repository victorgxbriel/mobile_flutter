import 'package:json_annotation/json_annotation.dart';

part 'nhtsa_models.g.dart';

/// Representa uma marca de veículo da NHTSA
@JsonSerializable()
class MakeModel {
  @JsonKey(name: 'Make_ID')
  final int makeId;

  @JsonKey(name: 'Make_Name')
  final String makeName;

  MakeModel({
    required this.makeId,
    required this.makeName,
  });

  factory MakeModel.fromJson(Map<String, dynamic> json) =>
      _$MakeModelFromJson(json);

  Map<String, dynamic> toJson() => _$MakeModelToJson(this);

  @override
  String toString() => makeName;
}

/// Representa um modelo de veículo da NHTSA
@JsonSerializable()
class VehicleModelNhtsa {
  @JsonKey(name: 'Make_ID')
  final int makeId;

  @JsonKey(name: 'Make_Name')
  final String makeName;

  @JsonKey(name: 'Model_ID')
  final int modelId;

  @JsonKey(name: 'Model_Name')
  final String modelName;

  VehicleModelNhtsa({
    required this.makeId,
    required this.makeName,
    required this.modelId,
    required this.modelName,
  });

  factory VehicleModelNhtsa.fromJson(Map<String, dynamic> json) =>
      _$VehicleModelNhtsaFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleModelNhtsaToJson(this);

  @override
  String toString() => modelName;
}

/// Response wrapper para lista de marcas
@JsonSerializable()
class MakesResponse {
  @JsonKey(name: 'Count')
  final int count;

  @JsonKey(name: 'Message')
  final String message;

  @JsonKey(name: 'Results')
  final List<MakeModel> results;

  MakesResponse({
    required this.count,
    required this.message,
    required this.results,
  });

  factory MakesResponse.fromJson(Map<String, dynamic> json) =>
      _$MakesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MakesResponseToJson(this);
}

/// Response wrapper para lista de modelos
@JsonSerializable()
class ModelsResponse {
  @JsonKey(name: 'Count')
  final int count;

  @JsonKey(name: 'Message')
  final String message;

  @JsonKey(name: 'Results')
  final List<VehicleModelNhtsa> results;

  ModelsResponse({
    required this.count,
    required this.message,
    required this.results,
  });

  factory ModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$ModelsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ModelsResponseToJson(this);
}
