import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/presentation/states/register_state.dart';

final _log = logger(RegisterNotifier);

class RegisterNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterState _status = Cliente();

  RegisterNotifier(this._authRepository);

  RegisterState get status => _status;

  void toggleType(num type) {
    if (type == 0) {
      _log.d('Tipo alterado para: Cliente');
      _status = Cliente();
    } else {
      _log.d('Tipo alterado para: Estabelecimento');
      _status = Estabelecimento();
    }
    notifyListeners();
  }

  Future<void> registerClient(RegisterClientDto dto) async {
    _log.i('Iniciando registro de cliente: ${dto.email}');
    _status = Loading();
    notifyListeners();

    try {
      await _authRepository.registerClient(
        nome: dto.nome,
        email: dto.email,
        password: dto.password,
        cpf: dto.cpf,
      );
      _log.i('Cliente registrado com sucesso, fazendo login automático...');

      // Faz login automático após registro
      await _loginAfterRegister(dto.email, dto.password);

      _status = Success();
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao registrar cliente', error: e);
      _status = Error(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  Future<void> registerEstablishment(RegisterEstablishmentDto dto) async {
    _log.i('Iniciando registro de estabelecimento: ${dto.nomeEstabelecimento}');
    _status = Loading();
    notifyListeners();

    try {
      await _authRepository.registerEstablishment(
        nome: dto.nome,
        email: dto.email,
        password: dto.password,
        cnpj: dto.cnpj,
        nomeFantasia: dto.nomeEstabelecimento,
      );
      _log.i(
        'Estabelecimento registrado com sucesso, fazendo login automático...',
      );

      // Faz login automático após registro
      await _loginAfterRegister(dto.email, dto.password);

      _status = Success();
      notifyListeners();
    } catch (e) {
      _log.e('Erro ao registrar estabelecimento', error: e);
      _status = Error(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  /// Faz login automático após o registro e atualiza a sessão
  Future<void> _loginAfterRegister(String email, String password) async {
    _log.d('Executando login automático para: $email');

    final token = await _authRepository.login(email, password);
    await ServiceLocator().sessionService.setToken(token);

    // Busca o perfil para obter clienteId/estabelecimentoId
    try {
      final profile = await _authRepository.getProfile();
      if (profile != null) {
        await ServiceLocator().sessionService.updateProfile(
          clienteId: profile.clienteId,
          estabelecimentoId: profile.estabelecimentoId,
        );
        _log.d(
          'Perfil carregado - clienteId: ${profile.clienteId}, estabelecimentoId: ${profile.estabelecimentoId}',
        );
      }
    } catch (profileError) {
      _log.w('Não foi possível carregar o perfil: $profileError');
      // Continua mesmo sem o perfil - será carregado depois
    }

    _log.i('Login automático realizado com sucesso');
  }

  void reset() {
    _log.t('Reset do estado de registro');
    _status = Cliente();
    notifyListeners();
  }
}
