import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile_flutter/features/auth/presentation/states/login_state.dart';

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
    if (email.isEmpty || password.isEmpty) {
      _status = Error('Por favor, preencha todos os campos.');
      notifyListeners();
      return;
    }

    _status = Loading();
    notifyListeners();

    try {
      final token = await _authRepository.login(email, password);
      
      // Atualiza a sessão com o novo token
      await ServiceLocator().sessionService.setToken(token);
      
      _status = Success();
      notifyListeners();
    } catch (e) {
      _status = Error(e.toString());
      notifyListeners();
    }
  }

  void reset() {
    _status = Initial();
    notifyListeners();
  }
}
