import '../../../../core/network/dio_client.dart';
import '../models/nhtsa_models.dart';

abstract class NhtsaService {
  /// Busca todas as marcas (10.000+)
  Future<MakesResponse> getAllMakes();

  /// Busca marca por nome (case-insensitive)
  Future<MakeModel> findMakeByName(String name);

  /// Busca modelos por ID da marca
  Future<ModelsResponse> getModelsByMakeId(int makeId, {int? year});

  /// Busca modelos por nome da marca
  Future<ModelsResponse> getModelsByMakeName(String makeName, {int? year});
}

class NhtsaServiceImpl implements NhtsaService {
  final DioClient _dioClient;

  NhtsaServiceImpl(this._dioClient);

  @override
  Future<MakesResponse> getAllMakes() async {
    final response = await _dioClient.instance.get('/nhtsa/makes');
    return MakesResponse.fromJson(response.data);
  }

  @override
  Future<MakeModel> findMakeByName(String name) async {
    final response = await _dioClient.instance.get(
      '/nhtsa/makes/search',
      queryParameters: {'name': name},
    );
    return MakeModel.fromJson(response.data);
  }

  @override
  Future<ModelsResponse> getModelsByMakeId(int makeId, {int? year}) async {
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;

    final response = await _dioClient.instance.get(
      '/nhtsa/makes/$makeId/models',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ModelsResponse.fromJson(response.data);
  }

  @override
  Future<ModelsResponse> getModelsByMakeName(String makeName, {int? year}) async {
    final queryParams = <String, dynamic>{'makeName': makeName};
    if (year != null) queryParams['year'] = year;

    final response = await _dioClient.instance.get(
      '/nhtsa/search/models',
      queryParameters: queryParams,
    );
    return ModelsResponse.fromJson(response.data);
  }
}
