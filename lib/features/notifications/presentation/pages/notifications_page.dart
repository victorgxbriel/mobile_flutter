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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                notifier.markAllAsRead();
              },
              child: Text(
                'Marcar todas como lidas',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
            IconButton(
              tooltip: 'Limpar notificações',
              onPressed: () {
                notifier.clearNotifications();
              },
              icon: Icon(
                Icons.delete_sweep_outlined,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          // Cores com bom contraste para tema claro/escuro
          final bool isUnread = !notification.isRead;
          final Color cardColor = isUnread
              ? colorScheme.brightness == Brightness.dark
                  // No tema escuro, use um container mais claro porém ainda escuro
                  ? colorScheme.surfaceVariant
                  // No tema claro, use um destaque suave
                  : colorScheme.primaryContainer.withOpacity(0.35)
              : colorScheme.surface;
          final Color titleColor = isUnread
              ? colorScheme.onSurface
              : colorScheme.onSurface.withOpacity(0.9);
          final Color subtitleColor = colorScheme.onSurface.withOpacity(0.78);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: cardColor,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: colorScheme.primary,
                child: Icon(
                  Icons.notifications,
                  color: colorScheme.onPrimary,
                ),
              ),
              title: Text(
                notification.title,
                style: TextStyle(
                  fontWeight:
                      notification.isRead ? FontWeight.w500 : FontWeight.w700,
                  color: titleColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: subtitleColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${notification.dateTime.day}/${notification.dateTime.month}/${notification.dateTime.year} ${notification.dateTime.hour}:${notification.dateTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
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