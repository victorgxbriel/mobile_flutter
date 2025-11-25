/*
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_flutter/features/auth/data/models/auth_models.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  // TODO: Inject Repository
  // final AuthRepository _authRepository;

  RegisterType _currentType = RegisterType.client;

  RegisterCubit() : super(RegisterInitial());

  void toggleType(RegisterType type) {
    _currentType = type;
    emit(RegisterTypeChanged(_currentType));
  }

  Future<void> registerClient(RegisterClientDto dto) async {
    emit(RegisterLoading());
    try {
      // await _authRepository.registerClient(dto);
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }

  Future<void> registerEstablishment(RegisterEstablishmentDto dto) async {
    emit(RegisterLoading());
    try {
      // await _authRepository.registerEstablishment(dto);
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }
}

*/