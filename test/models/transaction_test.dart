import 'package:flutter_test/flutter_test.dart';
import 'package:numbers/models/transaction.dart';

void main() {
  group('Transaction', () {
    test('fromMap handles int amount correctly', () {
      final map = {
        'id': '1',
        'title': 'Test Transaction',
        'amount': 100, // int
        'type': 0, // income
        'category': 0, // sales
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'isRecurring': 0,
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.amount, 100.0);
      expect(transaction.amount, isA<double>());
    });

    test('fromMap handles double amount correctly', () {
      final map = {
        'id': '2',
        'title': 'Test Transaction',
        'amount': 100.50, // double
        'type': 1, // expense
        'category': 8, // equipment
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'isRecurring': 0,
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.amount, 100.50);
      expect(transaction.amount, isA<double>());
    });
  });
}
