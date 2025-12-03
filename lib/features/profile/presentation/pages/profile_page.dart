import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/di/service_locator.dart';
import 'package:mobile_flutter/features/profile/presentation/notifiers/profile_notifier.dart';
import 'package:provider/provider.dart';
import 'package:mobile_flutter/features/profile/presentation/widgets/profile_image_picker.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileNotifier(ServiceLocator().profileRepository),
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ServiceLocator().authRepository;
      final notifier = context.read<ProfileNotifier>();
      
      final token = await authRepo.getToken();
      if (token != null) {
        final user = await authRepo.getCurrentUser();
        if (user != null) {
          await notifier.loadProfile(user.userId);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar perfil: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleImageSelected(String imagePath) async {
    final notifier = context.read<ProfileNotifier>();
    await notifier.updateProfileImage(File(imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileNotifier>(
        builder: (context, notifier, _) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUserProfile,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final cliente = notifier.cliente;
          if (cliente == null) {
            return const Center(child: Text('Nenhum dado de perfil encontrado'));
          }

          return SingleChildScrollView(
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
                    // Navegar para edição de perfil
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
                  icon: Icons.credit_card,
                  title: 'Formas de Pagamento',
                  onTap: () {
                    // Navegar para formas de pagamento
                  },
                ),
                _buildDivider(),
                _buildProfileItem(
                  context,
                  icon: Icons.history,
                  title: 'Histórico de Agendamentos',
                  onTap: () {
                    // Navegar para histórico
                  },
                ),
                _buildDivider(),
                _buildProfileItem(
                  context,
                  icon: Icons.settings,
                  title: 'Configurações',
                  onTap: () {
                    // Navegar para configurações
                  },
                ),
                _buildDivider(),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final notifier = context.read<ProfileNotifier>();
                      notifier.logout();
                      if (mounted) {
                        context.go('/login');
                      }
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
          );
        },
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
}
