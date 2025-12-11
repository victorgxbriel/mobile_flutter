import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:mobile_flutter/core/errors/exceptions.dart';

class ErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ErrorView({
    super.key,
    required this.error,
    required this.onRetry
  });

  bool _isConnectionError(Object? error) {
    if (error is NoInternetException) return true;
    if (error is DioException) {
      // Verifica se o erro interno é NoInternetException
      if (error.error is NoInternetException) return true;
      // Verifica tipos de erro de conexão do Dio
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return true;
      }
    }
    return false;
  }

  String _getErrorMessage(Object? error) {
    if (_isConnectionError(error)) {
      return 'Verifique sua conexão com a internet e tente novamente.';
    }
    if (error is DioException) {
      return error.message ?? 'Erro de conexão';
    }
    if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return error?.toString() ?? 'Erro desconhecido';
  }

  @override
  Widget build(BuildContext context) {
    final isConnectionError = _isConnectionError(error);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isConnectionError ? Symbols.wifi_off : Symbols.error,
              size: 80,
              color: theme.colorScheme.error
            ),
            const SizedBox(height: 16,),

            Text(
              _getErrorMessage(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24,),

            FilledButton.icon(
              onPressed: onRetry, 
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente',)
            ),
          ],
        ),
      ),
    );
  }
}