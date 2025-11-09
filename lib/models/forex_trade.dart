enum TradeType {
  buy,
  sell,
}

enum TradeStatus {
  open,
  closed,
  pending,
}

enum OrderType {
  market,
  limit,
  stop,
  stopLimit,
}

class ForexTrade {
  final String id;
  final String currencyPair; // e.g., "EUR/USD"
  final TradeType type;
  final TradeStatus status;
  final OrderType orderType;
  final double lotSize;
  final double entryPrice;
  final double? exitPrice;
  final DateTime entryTime;
  final DateTime? exitTime;
  final double? stopLoss;
  final double? takeProfit;
  final double commission;
  final double swap;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ForexTrade({
    required this.id,
    required this.currencyPair,
    required this.type,
    required this.status,
    required this.orderType,
    required this.lotSize,
    required this.entryPrice,
    this.exitPrice,
    required this.entryTime,
    this.exitTime,
    this.stopLoss,
    this.takeProfit,
    this.commission = 0,
    this.swap = 0,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Calculate profit/loss
  double get pips {
    if (exitPrice == null) return 0;
    final difference = type == TradeType.buy
        ? exitPrice! - entryPrice
        : entryPrice - exitPrice!;
    
    // For JPY pairs, pip is 0.01, for others 0.0001
    final pipValue = currencyPair.contains('JPY') ? 0.01 : 0.0001;
    return difference / pipValue;
  }

  double get profitLoss {
    if (exitPrice == null) return 0;
    
    // Standard lot is 100,000 units
    final standardLotSize = 100000;
    final pipValue = currencyPair.contains('JPY') ? 0.01 : 0.0001;
    final pipValueInCurrency = pipValue * lotSize * standardLotSize;
    
    final grossPL = pips * pipValueInCurrency;
    return grossPL - commission - swap;
  }

  double get roi {
    if (entryPrice == 0) return 0;
    final investment = entryPrice * lotSize * 100000;
    return (profitLoss / investment) * 100;
  }

  Duration? get tradeDuration {
    if (exitTime == null) return DateTime.now().difference(entryTime);
    return exitTime!.difference(entryTime);
  }

  String get statusName {
    switch (status) {
      case TradeStatus.open:
        return 'Open';
      case TradeStatus.closed:
        return 'Closed';
      case TradeStatus.pending:
        return 'Pending';
    }
  }

  String get orderTypeName {
    switch (orderType) {
      case OrderType.market:
        return 'Market';
      case OrderType.limit:
        return 'Limit';
      case OrderType.stop:
        return 'Stop';
      case OrderType.stopLimit:
        return 'Stop Limit';
    }
  }

  bool get isWinning => profitLoss > 0;
  bool get isLosing => profitLoss < 0;
  bool get isBreakEven => profitLoss == 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'currencyPair': currencyPair,
      'type': type.index,
      'status': status.index,
      'orderType': orderType.index,
      'lotSize': lotSize,
      'entryPrice': entryPrice,
      'exitPrice': exitPrice,
      'entryTime': entryTime.toIso8601String(),
      'exitTime': exitTime?.toIso8601String(),
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'commission': commission,
      'swap': swap,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ForexTrade.fromMap(Map<String, dynamic> map) {
    return ForexTrade(
      id: map['id'],
      currencyPair: map['currencyPair'],
      type: TradeType.values[map['type']],
      status: TradeStatus.values[map['status']],
      orderType: OrderType.values[map['orderType']],
      lotSize: map['lotSize'],
      entryPrice: map['entryPrice'],
      exitPrice: map['exitPrice'],
      entryTime: DateTime.parse(map['entryTime']),
      exitTime: map['exitTime'] != null 
          ? DateTime.parse(map['exitTime']) 
          : null,
      stopLoss: map['stopLoss'],
      takeProfit: map['takeProfit'],
      commission: map['commission'] ?? 0,
      swap: map['swap'] ?? 0,
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
    );
  }

  ForexTrade copyWith({
    String? id,
    String? currencyPair,
    TradeType? type,
    TradeStatus? status,
    OrderType? orderType,
    double? lotSize,
    double? entryPrice,
    double? exitPrice,
    DateTime? entryTime,
    DateTime? exitTime,
    double? stopLoss,
    double? takeProfit,
    double? commission,
    double? swap,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ForexTrade(
      id: id ?? this.id,
      currencyPair: currencyPair ?? this.currencyPair,
      type: type ?? this.type,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      lotSize: lotSize ?? this.lotSize,
      entryPrice: entryPrice ?? this.entryPrice,
      exitPrice: exitPrice ?? this.exitPrice,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      stopLoss: stopLoss ?? this.stopLoss,
      takeProfit: takeProfit ?? this.takeProfit,
      commission: commission ?? this.commission,
      swap: swap ?? this.swap,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ForexTrade{id: $id, pair: $currencyPair, type: $type, P/L: $profitLoss}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForexTrade && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Trading account summary
class TradingAccount {
  final String id;
  final String accountName;
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  TradingAccount({
    required this.id,
    required this.accountName,
    required this.initialBalance,
    required this.currentBalance,
    this.currency = 'USD',
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalProfitLoss => currentBalance - initialBalance;
  double get roi => initialBalance > 0 
      ? ((totalProfitLoss / initialBalance) * 100) 
      : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accountName': accountName,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  factory TradingAccount.fromMap(Map<String, dynamic> map) {
    return TradingAccount(
      id: map['id'],
      accountName: map['accountName'],
      initialBalance: map['initialBalance'],
      currentBalance: map['currentBalance'],
      currency: map['currency'] ?? 'USD',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt']) 
          : null,
      isActive: map['isActive'] == 1,
    );
  }

  TradingAccount copyWith({
    String? id,
    String? accountName,
    double? initialBalance,
    double? currentBalance,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return TradingAccount(
      id: id ?? this.id,
      accountName: accountName ?? this.accountName,
      initialBalance: initialBalance ?? this.initialBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Trading statistics
class TradingStatistics {
  final int totalTrades;
  final int winningTrades;
  final int losingTrades;
  final double totalProfit;
  final double totalLoss;
  final double netProfitLoss;
  final double winRate;
  final double averageWin;
  final double averageLoss;
  final double profitFactor;
  final double largestWin;
  final double largestLoss;

  TradingStatistics({
    required this.totalTrades,
    required this.winningTrades,
    required this.losingTrades,
    required this.totalProfit,
    required this.totalLoss,
    required this.netProfitLoss,
    required this.winRate,
    required this.averageWin,
    required this.averageLoss,
    required this.profitFactor,
    required this.largestWin,
    required this.largestLoss,
  });

  factory TradingStatistics.fromTrades(List<ForexTrade> trades) {
    if (trades.isEmpty) {
      return TradingStatistics(
        totalTrades: 0,
        winningTrades: 0,
        losingTrades: 0,
        totalProfit: 0,
        totalLoss: 0,
        netProfitLoss: 0,
        winRate: 0,
        averageWin: 0,
        averageLoss: 0,
        profitFactor: 0,
        largestWin: 0,
        largestLoss: 0,
      );
    }

    final closedTrades = trades.where((t) => t.status == TradeStatus.closed).toList();
    final winningTrades = closedTrades.where((t) => t.profitLoss > 0).toList();
    final losingTrades = closedTrades.where((t) => t.profitLoss < 0).toList();

    final totalProfit = winningTrades.fold<double>(
      0, (sum, trade) => sum + trade.profitLoss);
    final totalLoss = losingTrades.fold<double>(
      0, (sum, trade) => sum + trade.profitLoss.abs());
    final netPL = totalProfit - totalLoss;

    final winRate = closedTrades.isNotEmpty
        ? (winningTrades.length / closedTrades.length) * 100
        : 0;

    final avgWin = winningTrades.isNotEmpty
        ? totalProfit / winningTrades.length
        : 0;
    final avgLoss = losingTrades.isNotEmpty
        ? totalLoss / losingTrades.length
        : 0;

    final profitFactor = totalLoss > 0 ? totalProfit / totalLoss : 0;

    final largestWin = winningTrades.isNotEmpty
        ? winningTrades.map((t) => t.profitLoss).reduce((a, b) => a > b ? a : b)
        : 0;
    final largestLoss = losingTrades.isNotEmpty
        ? losingTrades.map((t) => t.profitLoss.abs()).reduce((a, b) => a > b ? a : b)
        : 0;

    return TradingStatistics(
      totalTrades: closedTrades.length,
      winningTrades: winningTrades.length,
      losingTrades: losingTrades.length,
      totalProfit: totalProfit,
      totalLoss: totalLoss,
      netProfitLoss: netPL,
      winRate: winRate.toDouble(),
      averageWin: avgWin.toDouble(),
      averageLoss: avgLoss.toDouble(),
      profitFactor: profitFactor.toDouble(),
      largestWin: largestWin.toDouble(),
      largestLoss: largestLoss.toDouble(),
    );
  }
}
