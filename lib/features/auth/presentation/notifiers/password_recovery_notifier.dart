import 'package:flutter/foundation.dart';
import '../../data/repositories/auth_repository.dart';
import '../states/password_recovery_state.dart';

class PasswordRecoveryNotifier extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  ForgotPasswordState _forgotState = ForgotPasswordInitial();
  ResetPasswordState _resetState = ResetPasswordInitial();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  // Email armazenado para uso no reset
  String _email = '';

  PasswordRecoveryNotifier(this._authRepository);

  // Getters
  ForgotPasswordState get forgotState => _forgotState;
  ResetPasswordState get resetState => _resetState;
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  String get email => _email;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  /// Solicita o envio do código de recuperação
  Future<void> sendRecoveryCode(String email) async {
    if (email.isEmpty) {
      _forgotState = ForgotPasswordError('Por favor, informe seu email.');
      notifyListeners();
      return;
    }

    // Validação básica de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _forgotState = ForgotPasswordError('Por favor, informe um email válido.');
      notifyListeners();
      return;
    }

    _forgotState = ForgotPasswordLoading();
    notifyListeners();

    try {
      await _authRepository.forgotPassword(email);
      _email = email; // Armazena para uso no reset
      _forgotState = ForgotPasswordSuccess(email);
      notifyListeners();
    } catch (e) {
      _forgotState = ForgotPasswordError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  /// Redefine a senha com o código recebido
  Future<void> resetPassword({
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validações
    if (code.isEmpty) {
      _resetState = ResetPasswordError('Por favor, informe o código.');
      notifyListeners();
      return;
    }

    if (code.length != 6) {
      _resetState = ResetPasswordError('O código deve ter 6 dígitos.');
      notifyListeners();
      return;
    }

    if (newPassword.isEmpty) {
      _resetState = ResetPasswordError('Por favor, informe a nova senha.');
      notifyListeners();
      return;
    }

    if (newPassword.length < 8) {
      _resetState = ResetPasswordError('A senha deve ter pelo menos 8 caracteres.');
      notifyListeners();
      return;
    }

    if (newPassword != confirmPassword) {
      _resetState = ResetPasswordError('As senhas não coincidem.');
      notifyListeners();
      return;
    }

    _resetState = ResetPasswordLoading();
    notifyListeners();

    try {
      await _authRepository.resetPassword(
        email: _email,
        code: code,
        newPassword: newPassword,
      );
      _resetState = ResetPasswordSuccess();
      notifyListeners();
    } catch (e) {
      _resetState = ResetPasswordError(e.toString().replaceAll('Exception: ', ''));
      notifyListeners();
    }
  }

  /// Define o email manualmente (caso navegue direto para reset)
  void setEmail(String email) {
    _email = email;
  }

  void resetForgotState() {
    _forgotState = ForgotPasswordInitial();
    notifyListeners();
  }

  void resetResetState() {
    _resetState = ResetPasswordInitial();
    notifyListeners();
  }

  void reset() {
    _forgotState = ForgotPasswordInitial();
    _resetState = ResetPasswordInitial();
    _email = '';
    _isPasswordVisible = false;
    _isConfirmPasswordVisible = false;
    notifyListeners();
  }
}
