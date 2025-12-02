import '../../../../core/network/dio_client.dart';
import '../models/estabelecimento_model.dart';
import '../models/servico_model.dart';

abstract class EstabelecimentoDetailsService {
  Future<EstabelecimentoModel> getEstabelecimento(int id);
  Future<List<ServicoModel>> getServicosDoEstabelecimento(int estabelecimentoId);
}

class EstabelecimentoDetailsServiceImpl implements EstabelecimentoDetailsService {
  final DioClient _dioClient;

  EstabelecimentoDetailsServiceImpl(this._dioClient);

  @override
  Future<EstabelecimentoModel> getEstabelecimento(int id) async {
    final response = await _dioClient.instance.get('/estabelecimentos/$id');
    return EstabelecimentoModel.fromJson(response.data);
  }

  @override
  Future<List<ServicoModel>> getServicosDoEstabelecimento(int estabelecimentoId) async {
    final response = await _dioClient.instance.get(
      '/servicos/estabelecimentos/$estabelecimentoId',
      queryParameters: {'include': 'tipoServico'},
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ServicoModel.fromJson(json)).toList();
  }
}
