import 'package:mobile_flutter/app/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../models/estabelecimento_models.dart';

final _log = logger(EstabelecimentoServiceImpl);

abstract class EstabelecimentoService {
  Future<List<EstabelecimentoModel>> getEstabelecimentos();
  Future<EstabelecimentoModel> getEstabelecimento(int id);
}

class EstabelecimentoServiceImpl implements EstabelecimentoService {
  final DioClient _dioClient;

  EstabelecimentoServiceImpl(this._dioClient);

  @override
  Future<List<EstabelecimentoModel>> getEstabelecimentos() async {
    _log.t('GET /estabelecimentos');
    final response = await _dioClient.instance.get('/estabelecimentos');
    final List<dynamic> data = response.data;
    _log.t('${data.length} estabelecimentos recebidos');
    return data.map((json) => EstabelecimentoModel.fromJson(json)).toList();
  }

  @override
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    _log.t('GET /estabelecimentos/$id');
    final response = await _dioClient.instance.get('/estabelecimentos/$id');
    return EstabelecimentoModel.fromJson(response.data);
  }
}
