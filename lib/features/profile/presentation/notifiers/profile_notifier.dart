import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/core/services/session_service.dart';
import 'package:mobile_flutter/features/profile/data/repositories/profile_repository.dart';

import '../../data/models/profile_models.dart';
import '../states/profile_state.dart';

final _log = logger(ProfileNotifier);

class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository _repository;
  final SessionService _sessionService;

  ProfileNotifier(this._repository, this._sessionService);

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  /// Carrega os dados do perfil do cliente
  Future<void> loadProfile() async {
    _log.i('Iniciando carregamento do perfil...');
    _state = ProfileLoading();
    notifyListeners();

    try {
      // Busca o clienteId da sessão
      var clienteId = _sessionService.clienteId;

      // Se não tem clienteId na sessão, tenta buscar da API
      if (clienteId == null) {
        _log.w('ClienteId não encontrado na sessão, buscando da API...');
        final authRepo = ServiceLocator().authRepository;
        final profile = await authRepo.getProfile();

        if (profile?.clienteId != null) {
          clienteId = profile!.clienteId;
          // Atualiza a sessão com o clienteId
          await _sessionService.updateProfile(
            clienteId: profile.clienteId,
            estabelecimentoId: profile.estabelecimentoId,
          );
          _log.i('ClienteId obtido da API e salvo: $clienteId');
        } else {
          // Não conseguiu obter clienteId - sessão inválida, fazer logout
          _log.e('Não foi possível obter clienteId - forçando logout');
          await _sessionService.logout();
          _state = ProfileLoggedOut();
          notifyListeners();
          return;
        }
      }

      final cliente = await _repository.getCliente(clienteId!);
      _log.d('Perfil carregado: ${cliente.nome}');
      _state = ProfileLoaded(cliente);
    } catch (e) {
      _log.e('Erro ao carregar perfil', error: e);

      // Se já tem clienteId, mostra dados da sessão com erro
      if (_sessionService.clienteId != null) {
        _state = ProfileLoaded(_createClienteFromSession(), error: e);
      } else {
        // Sem clienteId e sem conseguir da API - força logout
        _log.e('Sem clienteId e erro na API - forçando logout');
        await _sessionService.logout();
        _state = ProfileLoggedOut();
      }
    }

    notifyListeners();
  }

  /// Cria um ClienteModel básico com dados da sessão
  ClienteModel _createClienteFromSession() {
    return ClienteModel(
      id: _sessionService.clienteId ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      active: true,
      nome: _sessionService.email?.split('@').first ?? 'Usuário',
      cpf: '',
      email: _sessionService.email ?? '',
      userId: _sessionService.userId,
      fotoUrl: null,
    );
  }

  /// Atualiza os dados do perfil do cliente
  Future<void> updateProfile({
    String? nome,
    String? email,
    String? fotoUrl,
  }) async {
    final clienteId = _sessionService.clienteId;
    if (clienteId == null) {
      _log.w('Tentativa de atualizar perfil sem clienteId');
      return;
    }

    final currentState = _state;
    final currentCliente = currentState is ProfileLoaded
        ? currentState.cliente
        : _createClienteFromSession();

    _log.i('Atualizando perfil do cliente: $clienteId');
    _state = ProfileLoading();
    notifyListeners();

    try {
      final cliente = await _repository.updateCliente(
        clienteId,
        nome: nome,
        email: email,
        fotoUrl: fotoUrl,
      );
      _log.i('Perfil atualizado com sucesso');
      _state = ProfileLoaded(cliente);
    } catch (e) {
      _log.e('Erro ao atualizar perfil', error: e);
      // Mantém os dados anteriores mas mostra erro
      _state = ProfileLoaded(currentCliente, error: e);
    }

    notifyListeners();
  }

  /// Realiza o logout do usuário
  Future<void> logout() async {
    _log.i('Iniciando logout...');
    // Não mostra loading para logout - deve ser instantâneo
    try {
      await _repository.logout();
      _log.i('Logout realizado com sucesso');
    } catch (e) {
      // Ignora erros - o importante é limpar localmente
      _log.w('Erro ao fazer logout (ignorando)', error: e);
    }

    _state = ProfileLoggedOut();
    notifyListeners();
  }

  /// Atualiza a foto de perfil do cliente
  Future<void> updateProfileImage(File imageFile) async {
    final currentState = _state;
    if (currentState is! ProfileLoaded) {
      _log.w('Tentativa de atualizar foto sem perfil carregado');
      return;
    }

    final cliente = currentState.cliente;
    _log.i('Atualizando foto de perfil do cliente: ${cliente.id}');
    _state = ProfileLoading();
    notifyListeners();

    try {
      final storage = ServiceLocator().storageService;

      // Salva a imagem localmente primeiro para feedback imediato
      final savedPath = await storage.saveImage(
        imageFile,
        'profile_${cliente.id}.jpg',
      );
      _log.d('Imagem salva em: $savedPath');

      // Salva a URL local no SharedPreferences
      await storage.saveImageUrl('profile_${cliente.id}', savedPath);

      // Atualiza o perfil com a nova URL da imagem
      final updatedCliente = cliente.copyWith(fotoUrl: savedPath);
      _log.i('Foto de perfil atualizada');
      _state = ProfileLoaded(updatedCliente);
    } catch (e) {
      _log.e('Erro ao atualizar foto de perfil', error: e);
      // Mantém os dados anteriores mas mostra erro
      _state = ProfileLoaded(cliente, error: e);
    }

    notifyListeners();
  }

  /// Atualiza os dados do perfil (força refresh)
  Future<void> refresh() async {
    _log.d('Atualizando dados do perfil');
    await loadProfile();
  }

  /// Reseta o estado para inicial
  void reset() {
    _log.t('Reset do estado de perfil');
    _state = ProfileInitial();
    notifyListeners();
  }
}
