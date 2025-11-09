import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';

/// Simple in-memory notifications service using ValueNotifier so UI
/// can listen for changes. This is intentionally lightweight for demo.
class NotificationsService {
  NotificationsService._internal() {
    // seed with a couple of sample notifications
    _notifications.value = [
      NotificationItem(
        id: '1',
        title: 'Welcome to NUMBERS',
        body: 'Thanks for installing the app — start by adding a transaction.',
      ),
      NotificationItem(
        id: '2',
        title: 'Backup Reminder',
        body: 'Remember to backup your data regularly.',
      ),
    ];
  }

  static final NotificationsService instance = NotificationsService._internal();

  final ValueNotifier<List<NotificationItem>> _notifications = ValueNotifier([]);

  ValueListenable<List<NotificationItem>> get notifications => _notifications;

  List<NotificationItem> get current => List.unmodifiable(_notifications.value);

  void add(NotificationItem item) {
    final updated = List<NotificationItem>.from(_notifications.value)..insert(0, item);
    _notifications.value = updated;
  }

  void markRead(String id) {
    final list = _notifications.value.map((n) {
      if (n.id == id) {
        n.read = true;
      }
      return n;
    }).toList();
    _notifications.value = list;
  }

  void markUnread(String id) {
    final list = _notifications.value.map((n) {
      if (n.id == id) {
        n.read = false;
      }
      return n;
    }).toList();
    _notifications.value = list;
  }

  void markAllRead() {
    final list = _notifications.value.map((n) {
      n.read = true;
      return n;
    }).toList();
    _notifications.value = list;
  }

  void clearAll() {
    _notifications.value = [];
  }
}
