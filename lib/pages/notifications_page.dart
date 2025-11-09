import 'package:flutter/material.dart';
import '../models/notification_item.dart';
import '../services/notifications_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all_outlined),
            onPressed: () {
              NotificationsService.instance.markAllRead();
            },
          ),
          IconButton(
            tooltip: 'Clear all',
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear all notifications?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        NotificationsService.instance.clearAll();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<List<NotificationItem>>(
        valueListenable: NotificationsService.instance.notifications,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No notifications'),
                ],
              ),
            );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final n = list[idx];
              return ListTile(
                leading: Icon(n.read ? Icons.notifications_none : Icons.notifications_active, color: n.read ? Colors.grey : Theme.of(context).colorScheme.primary),
                title: Text(n.title),
                subtitle: Text(n.body),
                trailing: IconButton(
                  icon: Icon(n.read ? Icons.mark_email_unread_outlined : Icons.mark_email_read_outlined),
                  onPressed: () {
                    if (n.read) {
                      NotificationsService.instance.markUnread(n.id);
                    } else {
                      NotificationsService.instance.markRead(n.id);
                    }
                  },
                ),
                onTap: () {
                  // tapping marks as read and could navigate to related content
                  NotificationsService.instance.markRead(n.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opened: ${n.title}')),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
