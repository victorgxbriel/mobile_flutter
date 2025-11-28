import 'package:flutter/material.dart';
import 'package:mobile_flutter/features/appointments/presentation/pages/appointments_page.dart';
import 'package:mobile_flutter/features/notifications/presentation/pages/notifications_page.dart';
import 'package:mobile_flutter/features/profile/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Lista de páginas sem const
  final List<Widget> _pages = [
    // Página inicial
    Scaffold(
      body: Center(
        child: Text(
          'Deu certo!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
    // Página de agendamentos
    AppointmentsPage(),
    // Página de notificações
    NotificationsPage(),
    // Página de perfil
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Agendamentos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Notificações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}