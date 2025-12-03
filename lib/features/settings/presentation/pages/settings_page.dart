import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../notifiers/theme_notifier.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Aparência'),
          _ThemeSelector(),
          
          const Divider(height: 32),
          
          const _SectionHeader(title: 'Sobre'),
          _AboutTile(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return Column(
          children: [
            ListTile(
              leading: Icon(themeNotifier.themeModeIcon),
              title: const Text('Tema'),
              subtitle: Text(themeNotifier.themeModeName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, themeNotifier),
            ),
          ],
        );
      },
    );
  }

  void _showThemeDialog(BuildContext context, ThemeNotifier notifier) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escolha o tema'),
        contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.brightness_auto_rounded,
              title: 'Sistema',
              subtitle: 'Seguir configuração do dispositivo',
              isSelected: notifier.themeMode == ThemeMode.system,
              onTap: () {
                notifier.setThemeMode(ThemeMode.system);
                Navigator.of(ctx).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.light_mode_rounded,
              title: 'Claro',
              subtitle: 'Tema claro',
              isSelected: notifier.themeMode == ThemeMode.light,
              onTap: () {
                notifier.setThemeMode(ThemeMode.light);
                Navigator.of(ctx).pop();
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode_rounded,
              title: 'Escuro',
              subtitle: 'Tema escuro',
              isSelected: notifier.themeMode == ThemeMode.dark,
              onTap: () {
                notifier.setThemeMode(ThemeMode.dark);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _AboutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info_outline_rounded),
      title: const Text('Versão do app'),
      subtitle: const Text('1.0.0'),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'Abluo Car',
          applicationVersion: '1.0.0',
          applicationIcon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.local_car_wash_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          children: [
            const Text('Aplicativo para gerenciamento de lava jato.'),
          ],
        );
      },
    );
  }
}
