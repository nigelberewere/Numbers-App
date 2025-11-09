class NotificationItem {
  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool read;
}
