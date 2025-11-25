import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/features/auth/presentation/states/login_state.dart';

class LoginNotifier extends ChangeNotifier {
  LoginState _status = Initial();
  bool _isPasswordVisible = false;

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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (email == 'test@test.com' && password == '123456') {
        _status = Success();
      } else {
        _status = Error('Credenciais inválidas');
      }
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
