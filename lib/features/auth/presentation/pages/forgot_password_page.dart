import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../notifiers/password_recovery_notifier.dart';
import '../states/password_recovery_state.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PasswordRecoveryNotifier(ServiceLocator().authRepository),
      child: const _ForgotPasswordForm(),
    );
  }
}

class _ForgotPasswordForm extends StatefulWidget {
  const _ForgotPasswordForm();

  @override
  State<_ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<_ForgotPasswordForm> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Senha'),
        centerTitle: true,
      ),
      body: Consumer<PasswordRecoveryNotifier>(
        builder: (context, notifier, child) {
          // Listener para mudanças de estado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (notifier.forgotState) {
              case ForgotPasswordError(message: final msg):
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                notifier.resetForgotState();
              case ForgotPasswordSuccess(email: final email):
                // Navega para tela de reset com o email
                context.push('/reset-password', extra: email);
              default:
                break;
            }
          });

          final isLoading = notifier.forgotState is ForgotPasswordLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Ícone
                Icon(
                  Icons.lock_reset_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                
                const SizedBox(height: 32),
                
                // Título
                Text(
                  'Esqueceu sua senha?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Descrição
                Text(
                  'Não se preocupe! Informe seu email e enviaremos um código de verificação para redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Campo de email
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Digite seu email cadastrado',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !isLoading,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _sendCode(notifier),
                ),
                
                const SizedBox(height: 24),
                
                // Botão enviar
                ElevatedButton(
                  onPressed: isLoading ? null : () => _sendCode(notifier),
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
                      : const Text(
                          'ENVIAR CÓDIGO',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Voltar para login
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Voltar para o login'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _sendCode(PasswordRecoveryNotifier notifier) {
    FocusScope.of(context).unfocus();
    notifier.sendRecoveryCode(_emailController.text.trim());
  }
}
