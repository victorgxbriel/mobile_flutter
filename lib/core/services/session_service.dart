import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../app/utils/app_logger.dart';
import '../utils/jwt_utils.dart';
import 'token_service.dart';

final _log = logger(SessionService);

/// Serviço para gerenciar a sessão do usuário
class SessionService extends ChangeNotifier {
  final FlutterSecureStorage _storage;

  static const String _clienteIdKey = 'cliente_id';
  static const String _estabelecimentoIdKey = 'estabelecimento_id';

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _token;
  int? _userId;
  String? _email;
  List<String>? _roles;
  int? _clienteId;
  int? _estabelecimentoId;

  int? get userId => _userId;
  String? get email => _email;
  List<String>? get roles => _roles;
  int? get clienteId => _clienteId;
  int? get estabelecimentoId => _estabelecimentoId;

  /// Verifica se o usuário é cliente
  bool get isCliente => _roles?.contains('CLIENTE') ?? false;

  /// Verifica se o usuário é do estabelecimento
  bool get isEstabelecimento =>
      (_roles?.contains('GERENTE') ?? false) ||
      (_roles?.contains('PROPRIETARIO') ?? false) ||
      (_roles?.contains('FUNCIONARIO') ?? false);

  /// Callback para navegação quando a sessão expira
  VoidCallback? onSessionExpired;

  SessionService(this._storage);

  Future<void> init() async {
    _log.d('Inicializando sessão...');
    final token = await _storage.read(key: TokenService.accessTokenKey);
    final refreshToken = await _storage.read(key: TokenService.refreshTokenKey);

    if (token != null && token.isNotEmpty && !JwtUtils.isExpired(token)) {
      _token = token;
      _isAuthenticated = true;
      _extractUserInfo(token);
      await _loadProfileFromStorage();
      _log.i(
        'Sessão restaurada - Usuário: $_email (ID: $_userId, clienteId: $_clienteId)',
      );
    } else if (refreshToken != null && refreshToken.isNotEmpty) {
      // Refresh token pode ser opaco (não JWT), então apenas verificamos se existe
      // O interceptor tentará fazer o refresh quando necessário
      _isAuthenticated = true;
      if (token != null) {
        _extractUserInfo(token);
      }
      await _loadProfileFromStorage();
      _log.i('Sessão válida via refresh token (clienteId: $_clienteId)');
    } else {
      // Ambos tokens expirados ou inexistentes - limpar
      _log.w('Tokens expirados ou inexistentes - limpando sessão');
      await _clearStoredData();
      _isAuthenticated = false;
    }

    notifyListeners();
  }

  /// Carrega clienteId e estabelecimentoId do storage
  Future<void> _loadProfileFromStorage() async {
    final clienteIdStr = await _storage.read(key: _clienteIdKey);
    final estabelecimentoIdStr = await _storage.read(
      key: _estabelecimentoIdKey,
    );

    _clienteId = clienteIdStr != null ? int.tryParse(clienteIdStr) : null;
    _estabelecimentoId = estabelecimentoIdStr != null
        ? int.tryParse(estabelecimentoIdStr)
        : null;

    _log.t(
      'Profile carregado do storage - clienteId: $_clienteId, estabelecimentoId: $_estabelecimentoId',
    );
  }

  /// Atualiza a sessão com um novo token
  Future<void> setToken(String token, {String? refreshToken}) async {
    _log.d('Salvando novo token...');
    await _storage.write(key: TokenService.accessTokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(
        key: TokenService.refreshTokenKey,
        value: refreshToken,
      );
    }
    _token = token;
    _isAuthenticated = true;
    _extractUserInfo(token);
    _log.i('Token salvo - Usuário: $_email (ID: $_userId)');
    notifyListeners();
  }

  void _extractUserInfo(String token) {
    _userId = JwtUtils.getUserId(token);
    _email = JwtUtils.getEmail(token);
    _roles = JwtUtils.getRoles(token);
    _log.t(
      'Info extraída do token - userId: $_userId, email: $_email, roles: $_roles',
    );
  }

  bool checkSession() {
    if (_token == null) {
      _log.w('checkSession: Token nulo');
      return false;
    }

    if (JwtUtils.isExpired(_token!)) {
      _log.w('checkSession: Token expirado');
      handleSessionExpired();
      return false;
    }

    _log.t('checkSession: Sessão válida');
    return true;
  }

  /// Chamado quando a sessão expira (e refresh falhou)
  Future<void> handleSessionExpired() async {
    _log.w('Sessao expirada - executando logout');
    _clearSession();
    await _clearStoredData();
    onSessionExpired?.call();
    notifyListeners();
  }

  Future<void> logout() async {
    _log.i('Logout solicitado');
    await _clearStoredData();
    _clearSession();
    _log.i('Logout concluído');
    notifyListeners();
  }

  Future<void> _clearStoredTokens() async {
    await _storage.delete(key: TokenService.accessTokenKey);
    await _storage.delete(key: TokenService.refreshTokenKey);
    _log.d('Tokens removidos do storage');
    ;
  }

  /// Limpa todos os dados armazenados (tokens + profile)
  Future<void> _clearStoredData() async {
    await _storage.delete(key: TokenService.accessTokenKey);
    await _storage.delete(key: TokenService.refreshTokenKey);
    await _storage.delete(key: _clienteIdKey);
    await _storage.delete(key: _estabelecimentoIdKey);
    _log.d('Todos os dados removidos do storage');
  }

  void _clearSession() {
    _token = null;
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _roles = null;
    _clienteId = null;
    _estabelecimentoId = null;
    _log.d('Sessão limpa da memória');
  }

  /// Atualiza os dados do perfil (clienteId e estabelecimentoId) e persiste no storage
  Future<void> updateProfile({
    int? clienteId,
    int? estabelecimentoId,
    String? nome,
  }) async {
    _clienteId = clienteId;
    _estabelecimentoId = estabelecimentoId;

    // Persiste no storage
    if (clienteId != null) {
      await _storage.write(key: _clienteIdKey, value: clienteId.toString());
    }
    if (estabelecimentoId != null) {
      await _storage.write(
        key: _estabelecimentoIdKey,
        value: estabelecimentoId.toString(),
      );
    }

    _log.i(
      'Perfil atualizado e persistido - clienteId: $clienteId, estabelecimentoId: $estabelecimentoId',
    );
    notifyListeners();
  }

  DateTime? get tokenExpiration {
    if (_token == null) return null;
    return JwtUtils.getExpirationDate(_token!);
  }

  Duration? get timeUntilExpiration {
    final expiration = tokenExpiration;
    if (expiration == null) return null;
    return expiration.difference(DateTime.now());
  }
}
