
sealed class RegisterState {}

class Cliente implements RegisterState {}

class Estabelecimento implements RegisterState {}

class Loading implements RegisterState {}

class Success implements RegisterState {}

class Error implements RegisterState {
  final String message;

  Error(this.message);
}