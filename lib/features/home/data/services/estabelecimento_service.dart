import '../../../../core/network/dio_client.dart';
import '../models/estabelecimento_models.dart';

abstract class EstabelecimentoService {
  Future<List<EstabelecimentoModel>> getEstabelecimentos();
  Future<EstabelecimentoModel> getEstabelecimento(int id);
}

class EstabelecimentoServiceImpl implements EstabelecimentoService {
  final DioClient _dioClient;

  EstabelecimentoServiceImpl(this._dioClient);

  @override
  Future<List<EstabelecimentoModel>> getEstabelecimentos() async {
    final response = await _dioClient.instance.get('/estabelecimentos');
    final List<dynamic> data = response.data;
    return data.map((json) => EstabelecimentoModel.fromJson(json)).toList();
  }

  @override
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    final response = await _dioClient.instance.get('/estabelecimentos/$id');
    return EstabelecimentoModel.fromJson(response.data);
  }
}
