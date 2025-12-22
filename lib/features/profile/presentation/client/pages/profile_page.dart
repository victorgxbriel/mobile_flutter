import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/core/errors/exceptions.dart';
import 'package:mobile_flutter/features/profile/data/models/profile_models.dart';
import 'package:mobile_flutter/features/profile/presentation/client/notifiers/profile_notifier.dart';
import 'package:mobile_flutter/features/profile/presentation/client/states/profile_state.dart';
import 'package:provider/provider.dart';
import 'package:mobile_flutter/features/profile/presentation/widgets/profile_image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileNotifier(
        ServiceLocator().profileRepository,
        ServiceLocator().sessionService,
      ),
      child: const _ProfilePage(),
    );
  }
}

class _ProfilePage extends StatefulWidget {
  const _ProfilePage();

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  Object? _lastShownError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileNotifier>().loadProfile();
    });
  }

  Future<void> _handleImageSelected(String imagePath) async {
    final notifier = context.read<ProfileNotifier>();
    await notifier.updateProfileImage(File(imagePath));
  }

  void _showErrorSnackBar(BuildContext context, Object error) {
    // Evita mostrar o mesmo erro múltiplas vezes
    if (_lastShownError == error) return;
    _lastShownError = error;

    final isConnectionError = _isConnectionError(error);
    final message = isConnectionError
        ? 'Sem conexão. Alguns dados podem estar desatualizados.'
        : 'Não foi possível carregar todos os dados.';
    final icon = isConnectionError ? Icons.wifi_off : Icons.warning_amber;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tentar novamente',
          textColor: Colors.white,
          onPressed: () {
            _lastShownError = null; // Permite mostrar erro novamente após retry
            context.read<ProfileNotifier>().refresh();
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  bool _isConnectionError(Object error) {
    if (error is NoInternetException) return true;
    if (error is DioException) {
      if (error.error is NoInternetException) return true;
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileNotifier>(
        builder: (context, notifier, _) {
          final state = notifier.state;

          // Estado de loading ou inicial - mostra skeleton
          final isLoading = state is ProfileInitial || state is ProfileLoading;

          // Reset do erro quando está carregando
          if (isLoading) {
            _lastShownError = null;
          }

          // Obtém cliente do estado ou usa skeleton
          final cliente = state is ProfileLoaded
              ? state.cliente
              : ClienteModel.skeleton();

          // Verifica se há erro no estado loaded e mostra SnackBar
          if (state is ProfileLoaded && state.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showErrorSnackBar(context, state.error!);
              }
            });
          }

          // Estado de logout - redireciona para login
          if (state is ProfileLoggedOut) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/login');
              }
            });
            return const Center(child: CircularProgressIndicator());
          }

          return Skeletonizer(
            enabled: isLoading,
            child: _buildContent(context, notifier, cliente),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProfileNotifier notifier,
    ClienteModel cliente,
  ) {
    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: ProfileImagePicker(
                userId: cliente.id.toString(),
                imageUrl: cliente.fotoUrl,
                onImageSelected: _handleImageSelected,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cliente.nome,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              cliente.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildProfileItem(
              context,
              icon: Icons.person_outline,
              title: 'Dados Pessoais',
              onTap: () {
                _showEditProfileBottomSheet(context, notifier, cliente);
              },
            ),
            _buildDivider(),
            _buildProfileItem(
              context,
              icon: Icons.car_repair,
              title: 'Meus Veículos',
              onTap: () {
                context.push('/profile/vehicles');
              },
            ),
            _buildDivider(),
            _buildProfileItem(
              context,
              icon: Icons.settings,
              title: 'Configurações',
              onTap: () {
                context.push('/profile/settings');
              },
            ),
            _buildDivider(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: ElevatedButton(
                onPressed: () async {
                  await notifier.logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Sair',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }

  void _showEditProfileBottomSheet(
    BuildContext context,
    ProfileNotifier notifier,
    ClienteModel cliente,
  ) {
    final formKey = GlobalKey<FormState>();
    final nomeController = TextEditingController(text: cliente.nome);
    final cpfController = TextEditingController(text: cliente.cpf);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Editar Dados',
                        style: Theme.of(modalContext).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.store),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nome é obrigatório';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                    helperText: 'Formato: 00.000.000-00',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'CPF é obrigatório';
                    }
                    // Remove caracteres não numéricos para validação
                    final cleanCpf = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (cleanCpf.length != 11) {
                      return 'CPF deve ter 11 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Capture the navigator before async gap
                      final navigator = Navigator.of(modalContext);
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // Get values before disposing
                      final nome = nomeController.text.trim();
                      final cpf = cpfController.text.trim();

                      // Close modal first
                      navigator.pop();

                      // Update profile
                      await notifier.updateProfile(nome: nome, cpf: cpf);

                      // Show feedback using captured messenger
                      final state = notifier.state;
                      if (state is ProfileLoaded && !state.hasError) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Dados atualizados com sucesso!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (state is ProfileLoaded && state.hasError) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Erro ao atualizar dados'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
