import 'package:flutter/foundation.dart';
import 'package:mobile_flutter/app/utils/app_logger.dart';

import '../pages/notifications_page.dart';

final _log = logger(NotificationsNotifier);

class NotificationsNotifier extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void addNotification({
    required String title,
    required String message,
    DateTime? dateTime,
  }) {
    _log.i('Nova notificacao: $title');
    final notification = NotificationItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      dateTime: dateTime ?? DateTime.now(),
    );
    _notifications.insert(0, notification);
    _log.t('Total de notificações: ${_notifications.length}');
    notifyListeners();
  }

  void markAllAsRead() {
    _log.d('Marcando todas as notificações como lidas');
    for (var i = 0; i < _notifications.length; i++) {
      final n = _notifications[i];
      if (!n.isRead) {
        _notifications[i] = NotificationItem(
          id: n.id,
          title: n.title,
          message: n.message,
          dateTime: n.dateTime,
          isRead: true,
        );
      }
    }
    notifyListeners();
  }

  void clearNotifications() {
    if (_notifications.isEmpty) return;
    _log.d('Limpando todas as notificações (${_notifications.length})');
    _notifications.clear();
    notifyListeners();
  }
}
