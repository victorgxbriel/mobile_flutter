import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifiers/notifications_notifier.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    this.isRead = false,
  });
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<NotificationsNotifier>();
    final notifications = notifier.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              notifier.markAllAsRead();
            },
            child: const Text(
              'Marcar todas como lidas',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: notification.isRead ? Colors.white : Colors.blue[50],
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(notification.message),
                  const SizedBox(height: 4),
                  Text(
                    '${notification.dateTime.day}/${notification.dateTime.month}/${notification.dateTime.year} ${notification.dateTime.hour}:${notification.dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              onTap: () {
                // Navegar para detalhes da notificação
              },
            ),
          );
        },
      ),
    );
  }
}