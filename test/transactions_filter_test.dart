import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:numbers/providers.dart';
import 'package:numbers/models/transaction.dart';
import 'package:numbers/models/models.dart';

void main() {
  test('TransactionFilterNotifier updates state correctly', () {
    final container = ProviderContainer();
    final notifier = container.read(transactionFilterProvider.notifier);

    expect(container.read(transactionFilterProvider).query, null);

    notifier.setQuery('test');
    expect(container.read(transactionFilterProvider).query, 'test');

    notifier.setType(TransactionType.income);
    expect(
      container.read(transactionFilterProvider).type,
      TransactionType.income,
    );

    notifier.reset();
    expect(container.read(transactionFilterProvider).query, null);
    expect(container.read(transactionFilterProvider).type, null);
  });

  test('filteredTransactionListProvider filters transactions', () async {
    final container = ProviderContainer(
      overrides: [
        transactionListProvider.overrideWith(
          (ref) => Stream.value([
            Transaction(
              id: '1',
              title: 'Salary',
              amount: 1000,
              type: TransactionType.income,
              category: TransactionCategory.sales,
              date: DateTime.now(),
            ),
            Transaction(
              id: '2',
              title: 'Groceries',
              amount: 50,
              type: TransactionType.expense,
              category: TransactionCategory.other,
              date: DateTime.now(),
            ),
          ]),
        ),
      ],
    );

    // Initial state (all transactions)
    await Future.delayed(Duration.zero);
    var transactionsAsync = container.read(filteredTransactionListProvider);
    expect(transactionsAsync.hasValue, true);
    var transactions = transactionsAsync.value!;
    expect(transactions.length, 2);

    // Filter by query
    container.read(transactionFilterProvider.notifier).setQuery('Sal');
    await Future.delayed(Duration.zero);
    // Force re-read
    transactionsAsync = container.read(filteredTransactionListProvider);
    transactions = transactionsAsync.value!;
    expect(transactions.length, 1);
    expect(transactions.first.title, 'Salary');

    // Filter by type
    container.read(transactionFilterProvider.notifier).reset();
    container
        .read(transactionFilterProvider.notifier)
        .setType(TransactionType.expense);
    await Future.delayed(Duration.zero);
    transactionsAsync = container.read(filteredTransactionListProvider);
    transactions = transactionsAsync.value!;
    expect(transactions.length, 1);
    expect(transactions.first.title, 'Groceries');
  });
}
