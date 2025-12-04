import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/presentation/states/login_state.dart';

final _log = logger(LoginNotifier);

class LoginNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  LoginState _status = Initial();
  bool _isPasswordVisible = false;

  LoginNotifier(this._authRepository);

  LoginState get status => _status;
  bool get isPasswordVisible => _isPasswordVisible;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _log.i('Iniciando processo de login para: $email');
    
    if (email.isEmpty || password.isEmpty) {
      _log.w('Campos vazios no login');
      _status = Error('Por favor, preencha todos os campos.');
      notifyListeners();
      return;
    }

    _status = Loading();
    notifyListeners();

    try {
      final token = await _authRepository.login(email, password);
      _log.d('Token obtido, atualizando sessão...');
      
      // Atualiza a sessão com o novo token
      await ServiceLocator().sessionService.setToken(token);
      
      // Busca o perfil para obter clienteId/estabelecimentoId (não bloqueia o login se falhar)
      try {
        final profile = await _authRepository.getProfile();
        if (profile != null) {
          ServiceLocator().sessionService.updateProfile(
            clienteId: profile.clienteId,
            estabelecimentoId: profile.estabelecimentoId,
          );
          _log.d('Perfil carregado - clienteId: ${profile.clienteId}, estabelecimentoId: ${profile.estabelecimentoId}');
        }
      } catch (profileError) {
        _log.w('Não foi possível carregar o perfil: $profileError');
        // Continua mesmo sem o perfil - será carregado depois
      }
      
      _log.i('Login realizado com sucesso');
      _status = Success();
      notifyListeners();
    } catch (e) {
      _log.e('Erro no login', error: e);
      _status = Error(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  void reset() {
    _log.t('Reset do estado de login');
    _status = Initial();
    notifyListeners();
  }
}
