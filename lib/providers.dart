import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/models.dart';
import 'models/auth_user.dart';
import 'services/auth_service.dart';
import 'services/transaction_repository.dart';
import 'services/firebase_transaction_repository.dart';
import 'services/agriculture_repository.dart';
import 'services/firebase_agriculture_repository.dart';
import 'services/forex_repository.dart';
import 'services/firebase_forex_repository.dart';
import 'services/budget_repository.dart';
import 'services/firebase_budget_repository.dart';
import 'services/storage_service.dart';
import 'services/user_repository.dart';
import 'services/firebase_user_repository.dart';

import 'services/gemini_service.dart';

// --- Auth Provider ---

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authStateProvider).value;
});

// --- Repository Providers ---

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return FirebaseTransactionRepository(userId: user.uid);
  } else {
    throw Exception('User must be logged in to access transaction repository');
  }
});

final agricultureRepositoryProvider = Provider<AgricultureRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return FirebaseAgricultureRepository(userId: user.uid);
  } else {
    throw Exception('User must be logged in to access agriculture repository');
  }
});

final forexRepositoryProvider = Provider<ForexRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return FirebaseForexRepository(userId: user.uid);
  } else {
    throw Exception('User must be logged in to access forex repository');
  }
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return FirebaseBudgetRepository(userId: user.uid);
  } else {
    throw Exception('User must be logged in to access budget repository');
  }
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    return FirebaseUserRepository(userId: user.uid);
  } else {
    throw Exception('User must be logged in to access user repository');
  }
});

final userProfileProvider = StreamProvider<UserProfile>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.userProfileStream();
});

// --- Data Providers ---

final transactionListProvider = StreamProvider<List<Transaction>>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  if (repo is FirebaseTransactionRepository) {
    return repo.transactionsStream();
  } else {
    // Fallback for mock repo
    return Stream.fromFuture(repo.getAllTransactions());
  }
});

class TransactionFilter {
  final String? query;
  final TransactionType? type;
  final TransactionCategory? category;

  const TransactionFilter({this.query, this.type, this.category});

  TransactionFilter copyWith({
    String? query,
    TransactionType? type,
    TransactionCategory? category,
  }) {
    return TransactionFilter(
      query: query ?? this.query,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }
}

class TransactionFilterNotifier extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() {
    return const TransactionFilter();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setType(TransactionType? type) {
    state = state.copyWith(type: type);
  }

  void setCategory(TransactionCategory? category) {
    state = state.copyWith(category: category);
  }

  void reset() {
    state = const TransactionFilter();
  }
}

final transactionFilterProvider =
    NotifierProvider<TransactionFilterNotifier, TransactionFilter>(
      TransactionFilterNotifier.new,
    );

final filteredTransactionListProvider = Provider<AsyncValue<List<Transaction>>>(
  (ref) {
    final transactionsAsync = ref.watch(transactionListProvider);
    final filter = ref.watch(transactionFilterProvider);

    return transactionsAsync.whenData((transactions) {
      return transactions.where((t) {
        if (filter.query != null && filter.query!.isNotEmpty) {
          if (!t.title.toLowerCase().contains(filter.query!.toLowerCase())) {
            return false;
          }
        }
        if (filter.type != null) {
          if (t.type != filter.type) {
            return false;
          }
        }
        if (filter.category != null) {
          if (t.category != filter.category) {
            return false;
          }
        }
        return true;
      }).toList();
    });
  },
);

final agricultureListProvider = FutureProvider<List<AgricultureRecord>>((
  ref,
) async {
  final repo = ref.watch(agricultureRepositoryProvider);
  return repo.getAllRecords();
});

final livestockListProvider = FutureProvider<List<LivestockRecord>>((
  ref,
) async {
  final repo = ref.watch(agricultureRepositoryProvider);
  return repo.getAllLivestockRecords();
});

final cropListProvider = FutureProvider<List<CropRecord>>((ref) async {
  final repo = ref.watch(agricultureRepositoryProvider);
  return repo.getAllCropRecords();
});

final forexTradeListProvider = FutureProvider<List<ForexTrade>>((ref) async {
  final repo = ref.watch(forexRepositoryProvider);
  return repo.getAllTrades();
});

final forexAccountListProvider = FutureProvider<List<TradingAccount>>((
  ref,
) async {
  final repo = ref.watch(forexRepositoryProvider);
  return repo.getAllAccounts();
});

final budgetListProvider = FutureProvider<List<Budget>>((ref) async {
  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getAllBudgets();
});

final budgetProgressListProvider = FutureProvider<List<BudgetProgress>>((
  ref,
) async {
  // Invalidate when transactions change so progress updates
  ref.watch(transactionListProvider);

  final repo = ref.watch(budgetRepositoryProvider);
  return repo.getAllBudgetProgress();
});

final financialSummaryProvider = Provider<AsyncValue<FinancialSummary>>((ref) {
  final transactionsAsync = ref.watch(transactionListProvider);

  return transactionsAsync.whenData((transactions) {
    double income = 0;
    double expenses = 0;

    for (var t in transactions) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expenses += t.amount;
      }
    }

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netProfit: income - expenses,
      balance: income - expenses,
      periodStart: DateTime.now(), // Placeholder
      periodEnd: DateTime.now(), // Placeholder
    );
  });
});

// --- Service Providers ---

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.light;
  }

  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
