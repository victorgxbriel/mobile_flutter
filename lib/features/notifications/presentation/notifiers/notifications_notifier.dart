import 'package:flutter/foundation.dart';

import '../pages/notifications_page.dart';

class NotificationsNotifier extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  void addNotification({
    required String title,
    required String message,
    DateTime? dateTime,
  }) {
    final notification = NotificationItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      message: message,
      dateTime: dateTime ?? DateTime.now(),
    );
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAllAsRead() {
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
    _notifications.clear();
    notifyListeners();
  }
}
