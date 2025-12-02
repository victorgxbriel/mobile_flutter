import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/jwt_utils.dart';
import 'token_service.dart';

/// Serviço para gerenciar a sessão do usuário
class SessionService extends ChangeNotifier {
  final FlutterSecureStorage _storage;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _token;
  int? _userId;
  String? _email;
  List<String>? _roles;

  int? get userId => _userId;
  String? get email => _email;
  List<String>? get roles => _roles;

  /// Callback para navegação quando a sessão expira
  VoidCallback? onSessionExpired;

  SessionService(this._storage);

  /// Inicializa a sessão verificando se há um token válido
  Future<void> init() async {
    final token = await _storage.read(key: TokenService.accessTokenKey);
    final refreshToken = await _storage.read(key: TokenService.refreshTokenKey);

    if (token != null && token.isNotEmpty && !JwtUtils.isExpired(token)) {
      // Access token válido
      _token = token;
      _isAuthenticated = true;
      _extractUserInfo(token);
    } else if (refreshToken != null && !JwtUtils.isExpired(refreshToken)) {
      // Access token expirado mas refresh token válido
      // O AuthInterceptor vai renovar automaticamente na próxima requisição
      _isAuthenticated = true;
      if (token != null) {
        _extractUserInfo(token);
      }
    } else {
      // Ambos tokens expirados ou inexistentes - limpar
      await _clearStoredTokens();
      _isAuthenticated = false;
    }

    notifyListeners();
  }

  /// Atualiza a sessão com um novo token
  Future<void> setToken(String token, {String? refreshToken}) async {
    await _storage.write(key: TokenService.accessTokenKey, value: token);
    if (refreshToken != null) {
      await _storage.write(key: TokenService.refreshTokenKey, value: refreshToken);
    }
    _token = token;
    _isAuthenticated = true;
    _extractUserInfo(token);
    notifyListeners();
  }

  /// Extrai informações do usuário do token
  void _extractUserInfo(String token) {
    _userId = JwtUtils.getUserId(token);
    _email = JwtUtils.getEmail(token);
    _roles = JwtUtils.getRoles(token);
  }

  /// Verifica se a sessão ainda é válida
  bool checkSession() {
    if (_token == null) return false;
    
    if (JwtUtils.isExpired(_token!)) {
      handleSessionExpired();
      return false;
    }
    
    return true;
  }

  /// Chamado quando a sessão expira (e refresh falhou)
  void handleSessionExpired() {
    _clearSession();
    _clearStoredTokens();
    onSessionExpired?.call();
    notifyListeners();
  }

  /// Faz logout
  Future<void> logout() async {
    await _clearStoredTokens();
    _clearSession();
    notifyListeners();
  }

  Future<void> _clearStoredTokens() async {
    await _storage.delete(key: TokenService.accessTokenKey);
    await _storage.delete(key: TokenService.refreshTokenKey);
  }

  void _clearSession() {
    _token = null;
    _isAuthenticated = false;
    _userId = null;
    _email = null;
    _roles = null;
  }

  /// Retorna a data de expiração do token atual
  DateTime? get tokenExpiration {
    if (_token == null) return null;
    return JwtUtils.getExpirationDate(_token!);
  }

  /// Retorna quanto tempo falta para o token expirar
  Duration? get timeUntilExpiration {
    final expiration = tokenExpiration;
    if (expiration == null) return null;
    return expiration.difference(DateTime.now());
  }
}
