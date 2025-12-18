import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/core/services/session_service.dart';
import 'package:mobile_flutter/features/profile/data/repositories/profile_repository.dart';

import '../../../data/models/profile_models.dart';
import '../states/profile_state.dart';

final _log = logger(ProfileNotifier);

class ProfileNotifier extends ChangeNotifier {
  final ProfileRepository _repository;
  final SessionService _sessionService;

  ProfileNotifier(this._repository, this._sessionService);

  ProfileState _state = ProfileInitial();
  ProfileState get state => _state;

  bool get isProprietario => _sessionService.isProprietario;
  bool get isGerente => _sessionService.isGerente;
  bool get isFuncionario => _sessionService.isFuncionario;

  /// Carrega os dados do perfil
  Future<void> loadProfile() async {
    _log.i('Iniciando carregamento do perfil...');
    _state = ProfileLoading();
    notifyListeners();

    try {
      // Busca o estabelecimentoId da sessão
      var estabelecimentoId = _sessionService.estabelecimentoId;

      // Se não tem estabelecimentoId na sessão, tenta buscar da API
      if (estabelecimentoId == null) {
        _log.w('estabelecimentoId não encontrado na sessão, buscando da API...');
        final authRepo = ServiceLocator().authRepository;
        final profile = await authRepo.getProfile();

        if (profile?.estabelecimentoId != null) {
          estabelecimentoId = profile!.estabelecimentoId;
          // Atualiza a sessão com o estabelecimentoId
          await _sessionService.updateProfile(
            clienteId: profile.clienteId,
            estabelecimentoId: profile.estabelecimentoId,
          );
          _log.i('estabelecimentoId obtido da API e salvo: $estabelecimentoId');
        } else {
          // Não conseguiu obter estabelecimentoId - sessão inválida, fazer logout
          _log.e('Não foi possível obter estabelecimentoId - forçando logout');
          await _sessionService.logout();
          _state = ProfileLoggedOut();
          notifyListeners();
          return;
        }
      }

      final estabelecimento = await _repository.getEstabelecimento(estabelecimentoId!);
      _log.d('Perfil carregado: ${estabelecimento.nomeFantasia}');
      _state = ProfileLoaded(estabelecimento);
    } catch (e) {
      _log.e('Erro ao carregar perfil', error: e);

      // Se já tem estabelecimentoId, mostra dados da sessão com erro
      if (_sessionService.estabelecimentoId != null) {
        _state = ProfileLoaded(_createEstabelecimentoFromSession(), error: e);
      } else {
        // Sem estabelecimentoId e sem conseguir da API - força logout
        _log.e('Sem estabelecimentoId e erro na API - forçando logout');
        await _sessionService.logout();
        _state = ProfileLoggedOut();
      }
    }

    notifyListeners();
  }

  /// Cria um EstabelecimentoModel básico com dados da sessão
  EstabelecimentoModel _createEstabelecimentoFromSession() {
    return EstabelecimentoModel(
      id: _sessionService.clienteId ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      active: true,
      nomeFantasia: _sessionService.email?.split('@').first ?? 'Usuário',
      cnpj: '',
      avaliacaoMedia: '4.5'
    );
  }

  /// Atualiza os dados do perfil do cliente
  Future<void> updateProfile({
    String? nomeFantasia,
    String? cnpj,
  }) async {
    final estabelecimentoId = _sessionService.estabelecimentoId;
    if (estabelecimentoId == null) {
      _log.w('Tentativa de atualizar perfil sem estabelecimentoId');
      return;
    }

    final currentState = _state;
    final currentCliente = currentState is ProfileLoaded
        ? currentState.estabelecimento
        : _createEstabelecimentoFromSession();

    _log.i('Atualizando perfil do estabelecimento: $estabelecimentoId');
    _state = ProfileLoading();
    notifyListeners();

    try {
      final estabelecimento = await _repository.updateEstabelecimento(
        estabelecimentoId,
        nomeFantasia: nomeFantasia,
        cnpj: cnpj,
      );
      _log.i('Perfil atualizado com sucesso');
      _state = ProfileLoaded(estabelecimento);
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
