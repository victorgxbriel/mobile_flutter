
sealed class LoginState {}

class Initial implements LoginState {}

class Loading implements LoginState {}

class Success implements LoginState {}

class Error implements LoginState {
  final String message;

  Error(this.message);
}