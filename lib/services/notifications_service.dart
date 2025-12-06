import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_item.dart';
import '../models/financial_report.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../services/gemini_service.dart';

/// Simple in-memory notifications service using ValueNotifier so UI
/// can listen for changes. Now supports local persistence.
class NotificationsService {
  NotificationsService._internal() {
    _loadNotifications();
  }

  static final NotificationsService instance = NotificationsService._internal();

  final ValueNotifier<List<NotificationItem>> _notifications = ValueNotifier(
    [],
  );

  ValueListenable<List<NotificationItem>> get notifications => _notifications;

  List<NotificationItem> get current => List.unmodifiable(_notifications.value);

  Future<void> _loadNotifications() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notifications.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _notifications.value = jsonList
            .map((j) => NotificationItem.fromJson(j))
            .toList();
      } else {
        // Seed with sample notifications only if file doesn't exist
        _notifications.value = [
          NotificationItem(
            id: '1',
            title: 'Welcome to NUMBERS',
            body:
                'Thanks for installing the app — start by adding a transaction.',
          ),
          NotificationItem(
            id: '2',
            title: 'Backup Reminder',
            body: 'Remember to backup your data regularly.',
          ),
        ];
        _saveNotifications();
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/notifications.json');
      final jsonList = _notifications.value.map((n) => n.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving notifications: $e');
    }
  }

  void add(NotificationItem item) {
    final updated = List<NotificationItem>.from(_notifications.value)
      ..insert(0, item);
    _notifications.value = updated;
    _saveNotifications();
  }

  void markRead(String id) {
    final list = _notifications.value.map((n) {
      if (n.id == id) {
        n.read = true;
      }
      return n;
    }).toList();
    _notifications.value = list;
    _saveNotifications();
  }

  void markUnread(String id) {
    final list = _notifications.value.map((n) {
      if (n.id == id) {
        n.read = false;
      }
      return n;
    }).toList();
    _notifications.value = list;
    _saveNotifications();
  }

  void markAllRead() {
    final list = _notifications.value.map((n) {
      n.read = true;
      return n;
    }).toList();
    _notifications.value = list;
    _saveNotifications();
  }

  void clearAll() {
    _notifications.value = [];
    _saveNotifications();
  }

  Future<void> checkAndGenerateScheduledReports({
    required GeminiService geminiService,
    required List<Transaction> transactions,
    required List<Budget> budgets,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // Check Weekly Report (every Monday)
    final lastWeekly = prefs.getInt('last_weekly_report_date');
    final lastWeeklyDate = lastWeekly != null
        ? DateTime.fromMillisecondsSinceEpoch(lastWeekly)
        : null;

    if (now.weekday == DateTime.monday &&
        (lastWeeklyDate == null ||
            now.difference(lastWeeklyDate).inDays >= 7)) {
      try {
        final report = await geminiService.generateReport(
          transactions,
          budgets,
          ReportType.weekly,
        );

        add(
          NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Weekly Financial Report Ready',
            body: report.summary,
            read: false,
            timestamp: DateTime.now(),
          ),
        );

        await prefs.setInt(
          'last_weekly_report_date',
          now.millisecondsSinceEpoch,
        );
      } catch (e) {
        debugPrint('Failed to generate weekly report: $e');
      }
    }

    // Check Monthly Report (1st of every month)
    final lastMonthly = prefs.getInt('last_monthly_report_date');
    final lastMonthlyDate = lastMonthly != null
        ? DateTime.fromMillisecondsSinceEpoch(lastMonthly)
        : null;

    if (now.day == 1 &&
        (lastMonthlyDate == null || now.month != lastMonthlyDate.month)) {
      try {
        final report = await geminiService.generateReport(
          transactions,
          budgets,
          ReportType.monthly,
        );

        add(
          NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Monthly Financial Report Ready',
            body: report.summary,
            read: false,
            timestamp: DateTime.now(),
          ),
        );

        await prefs.setInt(
          'last_monthly_report_date',
          now.millisecondsSinceEpoch,
        );
      } catch (e) {
        debugPrint('Failed to generate monthly report: $e');
      }
    }
  }
}
