import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/features/accessories/data/models/acessorio_model.dart';
import 'package:mobile_flutter/features/accessories/data/repositories/acessorio_repository.dart';
import 'package:mobile_flutter/features/services/data/models/servico_model.dart';
import 'package:mobile_flutter/features/services/data/repositories/servico_repository.dart';
import '../../data/models/cliente_model.dart';
import '../../data/models/create_atendimento_dto.dart';
import '../../data/repositories/atendimento_repository.dart';
import '../../data/repositories/cliente_repository.dart';
import '../states/create_atendimento_state.dart';

final _log = logger(CreateAtendimentoNotifier);

class CreateAtendimentoNotifier extends ChangeNotifier {
  final AtendimentoRepository _atendimentoRepository;
  final ClienteRepository _clienteRepository;
  final ServicoRepository _servicoRepository;
  final AcessorioRepository _acessorioRepository;
  final int _estabelecimentoId;

  CreateAtendimentoNotifier({
    required AtendimentoRepository atendimentoRepository,
    required ClienteRepository clienteRepository,
    required ServicoRepository servicoRepository,
    required AcessorioRepository acessorioRepository,
    required int estabelecimentoId,
  }) : _atendimentoRepository = atendimentoRepository,
       _clienteRepository = clienteRepository,
       _servicoRepository = servicoRepository,
       _acessorioRepository = acessorioRepository,
       _estabelecimentoId = estabelecimentoId;

  CreateAtendimentoState _state = const CreateAtendimentoInitial();
  CreateAtendimentoState get state => _state;

  // Dados carregados
  List<ClienteModel> _clientes = [];
  List<ServicoModel> _servicos = [];
  List<AcessorioModel> _acessorios = [];

  List<ClienteModel> get clientes => _clientes;
  List<ServicoModel> get servicos => _servicos;
  List<AcessorioModel> get acessorios => _acessorios;

  // Seleção do formulário
  ClienteModel? _selectedCliente;
  ClienteCarroModel? _selectedCarro;
  List<ClienteCarroModel> _carrosDoCliente = [];
  final List<ServicoModel> _selectedServicos = [];
  final List<AcessorioModel> _selectedAcessorios = [];

  ClienteModel? get selectedCliente => _selectedCliente;
  ClienteCarroModel? get selectedCarro => _selectedCarro;
  List<ClienteCarroModel> get carrosDoCliente => _carrosDoCliente;
  List<ServicoModel> get selectedServicos =>
      List.unmodifiable(_selectedServicos);
  List<AcessorioModel> get selectedAcessorios =>
      List.unmodifiable(_selectedAcessorios);

  /// Valor total calculado dos serviços e acessórios selecionados
  double get valorTotal {
    double total = 0;
    for (final servico in _selectedServicos) {
      total += double.tryParse(servico.preco) ?? 0;
    }
    for (final acessorio in _selectedAcessorios) {
      total += double.tryParse(acessorio.preco) ?? 0;
    }
    return total;
  }

  String get valorTotalFormatado {
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Verifica se o formulário está pronto para submissão
  bool get canSubmit {
    return _selectedCliente != null &&
        _selectedCarro != null &&
        _selectedServicos.isNotEmpty;
  }

  /// Carrega todos os dados necessários para o formulário
  Future<void> loadData() async {
    _log.i('Carregando dados para criação de atendimento');
    _state = const CreateAtendimentoLoadingData();
    notifyListeners();

    try {
      // Carregar clientes, serviços e acessórios em paralelo
      final results = await Future.wait([
        _clienteRepository.getClientes(),
        _servicoRepository.getServicosByEstabelecimento(_estabelecimentoId),
        _acessorioRepository.getAcessoriosByEstabelecimento(_estabelecimentoId),
      ]);

      _clientes = results[0] as List<ClienteModel>;
      _servicos = results[1] as List<ServicoModel>;
      _acessorios = results[2] as List<AcessorioModel>;

      _log.d(
        'Dados carregados: ${_clientes.length} clientes, ${_servicos.length} serviços, ${_acessorios.length} acessórios',
      );

      _state = CreateAtendimentoReady(
        clientes: _clientes,
        servicos: _servicos,
        acessorios: _acessorios,
      );
    } catch (e, stackTrace) {
      _log.e('Erro ao carregar dados', error: e, stackTrace: stackTrace);
      _state = CreateAtendimentoError(e);
    }

    notifyListeners();
  }

  /// Seleciona um cliente e carrega seus carros
  Future<void> selectCliente(ClienteModel cliente) async {
    _log.d(
      'Cliente selecionado: ${cliente.clienteId} - ${cliente.nomeExibicao}',
    );
    _selectedCliente = cliente;
    _selectedCarro = null; // Limpa o carro ao trocar cliente
    _carrosDoCliente = [];
    notifyListeners();

    try {
      _carrosDoCliente = await _clienteRepository.getCarrosByCliente(
        cliente.clienteId,
      );
      _log.d('${_carrosDoCliente.length} carros carregados para cliente');

      // Se o cliente tiver apenas um carro, seleciona automaticamente
      if (_carrosDoCliente.length == 1) {
        _selectedCarro = _carrosDoCliente.first;
      }
    } catch (e) {
      _log.e('Erro ao carregar carros do cliente', error: e);
    }

    notifyListeners();
  }

  /// Limpa a seleção de cliente
  void clearCliente() {
    _selectedCliente = null;
    _selectedCarro = null;
    _carrosDoCliente = [];
    notifyListeners();
  }

  /// Seleciona um carro
  void selectCarro(ClienteCarroModel carro) {
    _log.d('Carro selecionado: ${carro.id} - ${carro.nomeCompleto}');
    _selectedCarro = carro;
    notifyListeners();
  }

  /// Adiciona um serviço à lista
  void addServico(ServicoModel servico) {
    if (!_selectedServicos.contains(servico)) {
      _log.d('Serviço adicionado: ${servico.titulo}');
      _selectedServicos.add(servico);
      notifyListeners();
    }
  }

  /// Remove um serviço da lista
  void removeServico(ServicoModel servico) {
    _log.d('Serviço removido: ${servico.titulo}');
    _selectedServicos.remove(servico);
    notifyListeners();
  }

  /// Verifica se um serviço está selecionado
  bool isServicoSelected(ServicoModel servico) {
    return _selectedServicos.contains(servico);
  }

  /// Adiciona um acessório à lista
  void addAcessorio(AcessorioModel acessorio) {
    if (!_selectedAcessorios.contains(acessorio)) {
      _log.d('Acessório adicionado: ${acessorio.titulo}');
      _selectedAcessorios.add(acessorio);
      notifyListeners();
    }
  }

  /// Remove um acessório da lista
  void removeAcessorio(AcessorioModel acessorio) {
    _log.d('Acessório removido: ${acessorio.titulo}');
    _selectedAcessorios.remove(acessorio);
    notifyListeners();
  }

  /// Verifica se um acessório está selecionado
  bool isAcessorioSelected(AcessorioModel acessorio) {
    return _selectedAcessorios.contains(acessorio);
  }

  /// Submete o formulário e cria o atendimento
  Future<bool> submit() async {
    if (!canSubmit) {
      _log.w('Tentando submeter formulário inválido');
      return false;
    }

    _log.i('Criando atendimento...');
    _state = const CreateAtendimentoSubmitting();
    notifyListeners();

    try {
      final servicosDto = _selectedServicos
          .map(
            (s) => CreateServicoAtendimentoItem(
              servicoId: s.id,
              valorUnitario: s.preco,
              quantidade: 1,
            ),
          )
          .toList();

      final acessoriosDto = _selectedAcessorios.isNotEmpty
          ? _selectedAcessorios
                .map(
                  (a) => CreateAcessorioAtendimentoItem(
                    acessorioId: a.id,
                    valorUnitario: a.preco,
                    quantidade: 1,
                  ),
                )
                .toList()
          : null;

      final atendimento = await _atendimentoRepository.createAtendimento(
        clienteId: _selectedCliente!.id,
        carroId: _selectedCarro!.id,
        servicos: servicosDto,
        acessorios: acessoriosDto,
      );

      _log.i('Atendimento criado com sucesso: ID ${atendimento.id}');
      _state = CreateAtendimentoSuccess(atendimento);
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _log.e('Erro ao criar atendimento', error: e, stackTrace: stackTrace);
      _state = CreateAtendimentoError(e, canRetry: true);
      notifyListeners();
      return false;
    }
  }

  /// Reseta o formulário para o estado inicial
  void reset() {
    _log.t('Resetando formulário');
    _selectedCliente = null;
    _selectedCarro = null;
    _carrosDoCliente = [];
    _selectedServicos.clear();
    _selectedAcessorios.clear();
    _state = CreateAtendimentoReady(
      clientes: _clientes,
      servicos: _servicos,
      acessorios: _acessorios,
    );
    notifyListeners();
  }
}
