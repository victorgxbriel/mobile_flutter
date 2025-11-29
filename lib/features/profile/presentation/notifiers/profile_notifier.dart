import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
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
    String? fotoUrl,
  }) async {
    _state = ProfileLoading();
    notifyListeners();

    try {
      final cliente = await _repository.updateCliente(
        clienteId,
        nome: nome,
        email: email,
        fotoUrl: fotoUrl,
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
      _state = ProfileLoggedOut();
    } catch (e) {
      _state = ProfileError('Erro ao fazer logout: $e');
    }

    notifyListeners();
  }

  /// Atualiza a foto de perfil do cliente
  Future<void> updateProfileImage(File imageFile) async {
    if (_cliente == null) return;
    
    _state = ProfileLoading();
    notifyListeners();

    try {
      final storage = ServiceLocator().storageService;
      
      // Salva a imagem localmente primeiro para feedback imediato
      final savedPath = await storage.saveImage(
        imageFile, 
        'profile_${_cliente!.id}.jpg',
      );
      
      // Salva a URL local no SharedPreferences
      await storage.saveImageUrl('profile_${_cliente!.id}', savedPath);
      
      // Atualiza o perfil com a nova URL da imagem
      // Se você tiver um endpoint para upload de imagem no servidor, use-o aqui
      // Por enquanto, estamos apenas atualizando localmente
      _cliente = _cliente!.copyWith(fotoUrl: savedPath);
      _state = ProfileLoaded(_cliente!);
      
    } catch (e) {
      _state = ProfileError('Erro ao atualizar a foto de perfil: $e');
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
