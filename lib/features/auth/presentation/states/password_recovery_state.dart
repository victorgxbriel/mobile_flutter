/// Estados para solicitação de código de recuperação (forgot password)
sealed class ForgotPasswordState {}

class ForgotPasswordInitial implements ForgotPasswordState {}

class ForgotPasswordLoading implements ForgotPasswordState {}

class ForgotPasswordSuccess implements ForgotPasswordState {
  final String email;
  
  ForgotPasswordSuccess(this.email);
}

class ForgotPasswordError implements ForgotPasswordState {
  final String message;
  
  ForgotPasswordError(this.message);
}

/// Estados para redefinição de senha (reset password)
sealed class ResetPasswordState {}

class ResetPasswordInitial implements ResetPasswordState {}

class ResetPasswordLoading implements ResetPasswordState {}

class ResetPasswordSuccess implements ResetPasswordState {}

class ResetPasswordError implements ResetPasswordState {
  final String message;
  
  ResetPasswordError(this.message);
}
