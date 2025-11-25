/*

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Por favor, preencha todos os campos.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      if (email == 'test@test.com' && password == '123456') {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: 'Credenciais inválidas',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}

*/