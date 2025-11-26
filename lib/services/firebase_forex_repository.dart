import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'forex_repository.dart';

class FirebaseForexRepository implements ForexRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseForexRepository({required this.userId});

  // Collection References
  CollectionReference get _tradesCollection =>
      _firestore.collection('users').doc(userId).collection('forex_trades');

  CollectionReference get _accountsCollection =>
      _firestore.collection('users').doc(userId).collection('forex_accounts');

  // --- Trade Management ---

  @override
  Future<List<ForexTrade>> getAllTrades() async {
    final snapshot =
        await _tradesCollection.orderBy('entryTime', descending: true).get();
    return snapshot.docs
        .map((doc) => ForexTrade.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ForexTrade>> getTradesByStatus(TradeStatus status) async {
    final snapshot = await _tradesCollection
        .where('status', isEqualTo: status.index)
        .orderBy('entryTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ForexTrade.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ForexTrade>> getTradesByCurrencyPair(String currencyPair) async {
    final snapshot = await _tradesCollection
        .where('currencyPair', isEqualTo: currencyPair)
        .orderBy('entryTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ForexTrade.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ForexTrade>> getTradesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _tradesCollection
        .where('entryTime', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('entryTime', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('entryTime', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ForexTrade.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ForexTrade?> getTradeById(String id) async {
    final doc = await _tradesCollection.doc(id).get();
    if (!doc.exists) return null;
    return ForexTrade.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addTrade(ForexTrade trade) async {
    await _tradesCollection.doc(trade.id).set(trade.toMap());
  }

  @override
  Future<void> updateTrade(ForexTrade trade) async {
    await _tradesCollection.doc(trade.id).update(
          trade.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  @override
  Future<void> deleteTrade(String id) async {
    await _tradesCollection.doc(id).delete();
  }

  @override
  Future<void> closeTrade(
      String id, double exitPrice, DateTime exitTime) async {
    final trade = await getTradeById(id);
    if (trade != null) {
      final updatedTrade = trade.copyWith(
        status: TradeStatus.closed,
        exitPrice: exitPrice,
        exitTime: exitTime,
        updatedAt: DateTime.now(),
      );
      await updateTrade(updatedTrade);
    }
  }

  // --- Trading Account Management ---

  @override
  Future<List<TradingAccount>> getAllAccounts() async {
    final snapshot =
        await _accountsCollection.orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => TradingAccount.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TradingAccount>> getActiveAccounts() async {
    final snapshot = await _accountsCollection
        .where('isActive', isEqualTo: 1)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => TradingAccount.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TradingAccount?> getAccountById(String id) async {
    final doc = await _accountsCollection.doc(id).get();
    if (!doc.exists) return null;
    return TradingAccount.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<void> addAccount(TradingAccount account) async {
    await _accountsCollection.doc(account.id).set(account.toMap());
  }

  @override
  Future<void> updateAccount(TradingAccount account) async {
    await _accountsCollection.doc(account.id).update(
          account.copyWith(updatedAt: DateTime.now()).toMap(),
        );
  }

  @override
  Future<void> updateAccountBalance(String id, double newBalance) async {
    await _accountsCollection.doc(id).update({
      'currentBalance': newBalance,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _accountsCollection.doc(id).delete();
  }

  // --- Analytics ---

  @override
  Future<TradingStatistics> getTradingStatistics() async {
    final trades = await getAllTrades();
    return TradingStatistics.fromTrades(trades);
  }

  @override
  Future<TradingStatistics> getTradingStatisticsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final trades = await getTradesByDateRange(startDate, endDate);
    return TradingStatistics.fromTrades(trades);
  }

  @override
  Future<TradingStatistics> getTradingStatisticsByCurrencyPair(
    String currencyPair,
  ) async {
    final trades = await getTradesByCurrencyPair(currencyPair);
    return TradingStatistics.fromTrades(trades);
  }

  @override
  Future<double> getTotalProfitLoss() async {
    final stats = await getTradingStatistics();
    return stats.netProfitLoss;
  }

  @override
  Future<double> getWinRate() async {
    final stats = await getTradingStatistics();
    return stats.winRate;
  }

  @override
  Future<String?> getBestPerformingPair() async {
    final trades = await getAllTrades();
    if (trades.isEmpty) return null;

    final Map<String, double> pairProfits = {};
    for (var trade in trades) {
      if (trade.status == TradeStatus.closed) {
        pairProfits[trade.currencyPair] =
            (pairProfits[trade.currencyPair] ?? 0) + trade.profitLoss;
      }
    }

    if (pairProfits.isEmpty) return null;

    var bestPair = '';
    var maxProfit = -double.infinity;

    pairProfits.forEach((pair, profit) {
      if (profit > maxProfit) {
        maxProfit = profit;
        bestPair = pair;
      }
    });

    return bestPair;
  }
}
