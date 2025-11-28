import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/features/profile/data/repositories/profile_repository.dart';

import '../../data/models/profile_models.dart';
import '../states/profile_state.dart';

class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository);

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  ClienteModel? _cliente;
  ClienteModel? get cliente => _cliente;

  /// Carrega os dados do perfil do cliente
  Future<void> loadProfile(int clienteId) async {
    _state = ProfileLoading();
    notifyListeners();

    try {
      final cliente = await _repository.getCliente(clienteId);
      _cliente = cliente;
      _state = ProfileLoaded(cliente);
    } catch (e) {
      _state = ProfileError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Atualiza os dados do perfil do cliente
  Future<void> updateProfile({
    required int clienteId,
    String? nome,
    String? email,
  }) async {
    _state = ProfileLoading();
    notifyListeners();

    try {
      final cliente = await _repository.updateCliente(
        clienteId,
        nome: nome,
        email: email,
      );
      _cliente = cliente;
      _state = ProfileLoaded(cliente);
    } catch (e) {
      _state = ProfileError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Realiza o logout do usuário
  Future<void> logout() async {
    _state = ProfileLoading();
    notifyListeners();

    try {
      await _repository.logout();
      _cliente = null;
      _state = ProfileLoggedOut();
    } catch (e) {
      _state = ProfileError(e.toString().replaceAll('Exception: ', ''));
    }

    notifyListeners();
  }

  /// Reseta o estado para inicial
  void reset() {
    _state = ProfileInitial();
    _cliente = null;
    notifyListeners();
  }
}
