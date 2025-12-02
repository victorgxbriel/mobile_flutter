import 'dart:convert';

/// Utilitário para decodificar e validar JWT tokens
class JwtUtils {
  /// Decodifica o payload de um JWT token
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Adiciona padding se necessário
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Verifica se o token está expirado
  /// Retorna true se expirado ou inválido
  static bool isExpired(String token) {
    final payload = decodePayload(token);
    if (payload == null) return true;

    final exp = payload['exp'] as int?;
    if (exp == null) return true;

    // exp é em segundos desde epoch
    final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    
    // Considera expirado se faltar menos de 30 segundos (margem de segurança)
    return DateTime.now().isAfter(expirationDate.subtract(const Duration(seconds: 30)));
  }

  /// Retorna a data de expiração do token
  static DateTime? getExpirationDate(String token) {
    final payload = decodePayload(token);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Extrai o userId do token
  static int? getUserId(String token) {
    final payload = decodePayload(token);
    return payload?['sub'] as int?;
  }

  /// Extrai o email do token
  static String? getEmail(String token) {
    final payload = decodePayload(token);
    return payload?['email'] as String?;
  }

  /// Extrai as roles do token
  static List<String>? getRoles(String token) {
    final payload = decodePayload(token);
    final roles = payload?['roles'];
    if (roles is List) {
      return roles.cast<String>();
    }
    return null;
  }
}
