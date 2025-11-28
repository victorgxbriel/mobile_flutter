import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'João da Silva',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'joao@email.com',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildProfileItem(
              icon: Icons.person_outline,
              title: 'Dados Pessoais',
              onTap: () {
                // Navegar para edição de perfil
              },
            ),
            _buildDivider(),
            _buildProfileItem(
              icon: Icons.car_repair,
              title: 'Meus Veículos',
              onTap: () {
                // Navegar para lista de veículos
              },
            ),
            _buildDivider(),
            _buildProfileItem(
              icon: Icons.credit_card,
              title: 'Formas de Pagamento',
              onTap: () {
                // Navegar para formas de pagamento
              },
            ),
            _buildDivider(),
            _buildProfileItem(
              icon: Icons.history,
              title: 'Histórico de Agendamentos',
              onTap: () {
                // Navegar para histórico
              },
            ),
            _buildDivider(),
            _buildProfileItem(
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
                  // Sair do aplicativo
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

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16);
  }
}
