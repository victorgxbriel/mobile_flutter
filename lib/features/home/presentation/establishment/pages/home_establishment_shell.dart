
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeEstablishmentShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeEstablishmentShell({
    super.key,
    required this.navigationShell,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (value) => _onTap(context, value),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimary,
              ),
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'Atendimentos',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_rounded),
            selectedIcon: Icon(Icons.store),
            label: 'Menu',
          ),
        ],
      )
      
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}