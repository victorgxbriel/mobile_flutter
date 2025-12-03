// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nhtsa_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MakeModel _$MakeModelFromJson(Map<String, dynamic> json) => MakeModel(
  makeId: (json['Make_ID'] as num).toInt(),
  makeName: json['Make_Name'] as String,
);

Map<String, dynamic> _$MakeModelToJson(MakeModel instance) => <String, dynamic>{
  'Make_ID': instance.makeId,
  'Make_Name': instance.makeName,
};

VehicleModelNhtsa _$VehicleModelNhtsaFromJson(Map<String, dynamic> json) =>
    VehicleModelNhtsa(
      makeId: (json['Make_ID'] as num).toInt(),
      makeName: json['Make_Name'] as String,
      modelId: (json['Model_ID'] as num).toInt(),
      modelName: json['Model_Name'] as String,
    );

Map<String, dynamic> _$VehicleModelNhtsaToJson(VehicleModelNhtsa instance) =>
    <String, dynamic>{
      'Make_ID': instance.makeId,
      'Make_Name': instance.makeName,
      'Model_ID': instance.modelId,
      'Model_Name': instance.modelName,
    };

MakesResponse _$MakesResponseFromJson(Map<String, dynamic> json) =>
    MakesResponse(
      count: (json['Count'] as num).toInt(),
      message: json['Message'] as String,
      results: (json['Results'] as List<dynamic>)
          .map((e) => MakeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MakesResponseToJson(MakesResponse instance) =>
    <String, dynamic>{
      'Count': instance.count,
      'Message': instance.message,
      'Results': instance.results,
    };

ModelsResponse _$ModelsResponseFromJson(Map<String, dynamic> json) =>
    ModelsResponse(
      count: (json['Count'] as num).toInt(),
      message: json['Message'] as String,
      results: (json['Results'] as List<dynamic>)
          .map((e) => VehicleModelNhtsa.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModelsResponseToJson(ModelsResponse instance) =>
    <String, dynamic>{
      'Count': instance.count,
      'Message': instance.message,
      'Results': instance.results,
    };
