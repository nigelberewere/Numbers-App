import '../models/models.dart';

/// Abstract repository interface for Forex Trading data
/// Backend developer should implement this with Firebase
abstract class ForexRepository {
  // Trade management
  
  /// Get all trades
  Future<List<ForexTrade>> getAllTrades();

  /// Get trades by status (open, closed, pending)
  Future<List<ForexTrade>> getTradesByStatus(TradeStatus status);

  /// Get trades by currency pair
  Future<List<ForexTrade>> getTradesByCurrencyPair(String currencyPair);

  /// Get trades by date range
  Future<List<ForexTrade>> getTradesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get a single trade by ID
  Future<ForexTrade?> getTradeById(String id);

  /// Add a new trade
  Future<void> addTrade(ForexTrade trade);

  /// Update an existing trade
  Future<void> updateTrade(ForexTrade trade);

  /// Delete a trade
  Future<void> deleteTrade(String id);

  /// Close an open trade
  Future<void> closeTrade(String id, double exitPrice, DateTime exitTime);

  // Trading account management
  
  /// Get all trading accounts
  Future<List<TradingAccount>> getAllAccounts();

  /// Get active accounts
  Future<List<TradingAccount>> getActiveAccounts();

  /// Get account by ID
  Future<TradingAccount?> getAccountById(String id);

  /// Add a new trading account
  Future<void> addAccount(TradingAccount account);

  /// Update an account
  Future<void> updateAccount(TradingAccount account);

  /// Update account balance
  Future<void> updateAccountBalance(String id, double newBalance);

  /// Delete an account
  Future<void> deleteAccount(String id);

  // Analytics
  
  /// Get trading statistics for all trades
  Future<TradingStatistics> getTradingStatistics();

  /// Get trading statistics by date range
  Future<TradingStatistics> getTradingStatisticsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get trading statistics by currency pair
  Future<TradingStatistics> getTradingStatisticsByCurrencyPair(
    String currencyPair,
  );

  /// Get total profit/loss
  Future<double> getTotalProfitLoss();

  /// Get win rate percentage
  Future<double> getWinRate();

  /// Get best performing currency pair
  Future<String?> getBestPerformingPair();
}
