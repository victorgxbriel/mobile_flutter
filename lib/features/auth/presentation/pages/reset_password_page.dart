import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../notifiers/password_recovery_notifier.dart';
import '../states/password_recovery_state.dart';

class ResetPasswordPage extends StatelessWidget {
  final String? email;
  
  const ResetPasswordPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final notifier = PasswordRecoveryNotifier(ServiceLocator().authRepository);
        if (email != null) {
          notifier.setEmail(email!);
        }
        return notifier;
      },
      child: const _ResetPasswordForm(),
    );
  }
}

class _ResetPasswordForm extends StatefulWidget {
  const _ResetPasswordForm();

  @override
  State<_ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<_ResetPasswordForm> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
        centerTitle: true,
      ),
      body: Consumer<PasswordRecoveryNotifier>(
        builder: (context, notifier, child) {
          // Listener para mudanças de estado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (notifier.resetState) {
              case ResetPasswordError(message: final msg):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                notifier.resetResetState();
              case ResetPasswordSuccess():
                _showSuccessDialog(context);
              default:
                break;
            }
          });

          final isLoading = notifier.resetState is ResetPasswordLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                
                // Ícone
                Icon(
                  Icons.verified_user_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                const SizedBox(height: 24),
                
                // Título
                Text( 'Criar nova senha',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Descrição
                Text( 'Digite o código de 6 dígitos enviado para ${notifier.email.isNotEmpty ? notifier.email : "seu email"} e crie uma nova senha.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campo de código
                TextField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: 'Código de verificação',
                    hintText: '000000',
                    prefixIcon: const Icon(Icons.pin_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !isLoading,
                    counterText: '',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    letterSpacing: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de nova senha
                TextField(
                  controller: _passwordController,
                  obscureText: !notifier.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Nova senha',
                    hintText: 'Mínimo 8 caracteres',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        notifier.isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: notifier.togglePasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !isLoading,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Campo de confirmação de senha
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: !notifier.isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmar senha',
                    hintText: 'Digite a senha novamente',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        notifier.isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: notifier.toggleConfirmPasswordVisibility,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !isLoading,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _resetPassword(notifier),
                ),
                
                const SizedBox(height: 24),
                
                // Botão redefinir
                ElevatedButton(
                  onPressed: isLoading ? null : () => _resetPassword(notifier),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text( 'REDEFINIR SENHA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Reenviar código
                TextButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => _resendCode(context, notifier),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reenviar código'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _resetPassword(PasswordRecoveryNotifier notifier) {
    FocusScope.of(context).unfocus();
    notifier.resetPassword(
      code: _codeController.text.trim(),
      newPassword: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  void _resendCode(BuildContext context, PasswordRecoveryNotifier notifier) async {
    if (notifier.email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Volte para a tela anterior e informe seu email.'),
        ),
      );
      return;
    }
    
    await notifier.sendRecoveryCode(notifier.email);
    
    if (notifier.forgotState is ForgotPasswordSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Código reenviado com sucesso!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      notifier.resetForgotState();
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          Icons.check_circle_rounded,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Senha alterada!'),
        content: const Text( 'Sua senha foi redefinida com sucesso. Agora você pode fazer login com sua nova senha.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Fecha o dialog
              context.go('/login'); // Volta para login
            },
            child: const Text('IR PARA LOGIN'),
          ),
        ],
      ),
    );
  }
}
