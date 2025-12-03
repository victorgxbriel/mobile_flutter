import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/nhtsa_models.dart';

final _log = logger(NhtsaServiceImpl);

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
    _log.t('GET /nhtsa/makes');
    final response = await _dioClient.instance.get('/nhtsa/makes');
    final result = MakesResponse.fromJson(response.data);
    _log.t('${result.results.length} marcas recebidas');
    return result;
  }

  @override
  Future<MakeModel> findMakeByName(String name) async {
    _log.t('GET /nhtsa/makes/search?name=$name');
    final response = await _dioClient.instance.get( '/nhtsa/makes/search',
      queryParameters: {'name': name},
    );
    return MakeModel.fromJson(response.data);
  }

  @override
  Future<ModelsResponse> getModelsByMakeId(int makeId, {int? year}) async {
    _log.t('GET /nhtsa/makes/$makeId/models${year != null ? '?year=$year' : ''}');
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;

    final response = await _dioClient.instance.get( '/nhtsa/makes/$makeId/models',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    final result = ModelsResponse.fromJson(response.data);
    _log.t('${result.results.length} modelos recebidos');
    return result;
  }

  @override
  Future<ModelsResponse> getModelsByMakeName(String makeName, {int? year}) async {
    _log.t('GET /nhtsa/search/models?makeName=$makeName');
    final queryParams = <String, dynamic>{'makeName': makeName};
    if (year != null) queryParams['year'] = year;

    final response = await _dioClient.instance.get( '/nhtsa/search/models',
      queryParameters: queryParams,
    );
    final result = ModelsResponse.fromJson(response.data);
    _log.t('${result.results.length} modelos recebidos');
    return result;
  }
}
