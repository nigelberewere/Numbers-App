# Data Models Documentation

This document describes all the data models used in the NUMBERS app for financial record-keeping and analytics.

## 📊 Core Models

### 1. Transaction Model
**File:** `lib/models/transaction.dart`

Represents financial income and expense transactions.

**Enums:**
- `TransactionType`: income, expense
- `TransactionCategory`: sales, trading, harvest, livestock, feed, fertilizer, seeds, labor, equipment, transport, utilities, other
- `PaymentMethod`: cash, bank, mobileMoney, card, check

**Fields:**
- `id` (String): Unique identifier
- `title` (String): Transaction title/description
- `amount` (double): Transaction amount
- `type` (TransactionType): Income or expense
- `category` (TransactionCategory): Transaction category
- `date` (DateTime): Transaction date
- `description` (String?): Optional detailed description
- `reference` (String?): Optional reference number
- `paymentMethod` (PaymentMethod?): Payment method used
- `attachmentPath` (String?): Path to receipt/document
- `createdAt` (DateTime): Record creation timestamp
- `updatedAt` (DateTime?): Last update timestamp
- `isRecurring` (bool): Whether transaction repeats
- `recurringFrequency` (String?): daily, weekly, monthly, yearly

**Methods:**
- `isIncome` / `isExpense`: Boolean getters
- `categoryName`: Human-readable category name
- `paymentMethodName`: Human-readable payment method
- `toMap()`: Convert to Map for database storage
- `fromMap()`: Create from Map
- `copyWith()`: Create modified copy

**Use Cases:**
- Recording daily income/expenses
- Tracking sales and purchases
- Managing recurring transactions
- Categorizing business expenses

---

### 2. Financial Summary Model
**File:** `lib/models/financial_summary.dart`

Aggregates financial data for dashboard display.

**Fields:**
- `totalIncome` (double): Sum of all income
- `totalExpenses` (double): Sum of all expenses
- `netProfit` (double): Income - Expenses
- `balance` (double): Current account balance

**Use Cases:**
- Dashboard summary cards
- Financial reports
- Quick financial overview

---

### 3. Agriculture Record Model
**File:** `lib/models/agriculture_record.dart`

Tracks agricultural activities including crops and livestock.

**Enums:**
- `AgricultureType`: animalHusbandry, cropProduction, horticulture
- `AnimalType`: cattle, goats, sheep, poultry, pigs, rabbits, fish, other
- `CropType`: maize, wheat, rice, beans, cassava, potato, vegetables, other

#### 3.1 AgricultureRecord Class
**Fields:**
- `id` (String): Unique identifier
- `type` (AgricultureType): Agriculture type
- `name` (String): Project name
- `startDate` (DateTime): Start date
- `harvestDate` (DateTime?): Harvest/completion date
- `area` (double): Land area (acres/hectares)
- `location` (String?): Farm location
- `investmentCost` (double): Total investment
- `revenue` (double?): Generated revenue
- `notes` (String?): Additional notes
- `isActive` (bool): Whether project is active

**Computed Properties:**
- `profit`: revenue - investmentCost
- `roi`: Return on Investment percentage
- `typeName`: Human-readable type

**Use Cases:**
- Tracking farm projects
- Calculating agricultural ROI
- Managing multiple crops/livestock

#### 3.2 LivestockRecord Class
**Fields:**
- `id`, `animalType`, `quantity`, `unitPrice`
- `purchaseDate`, `saleDate`, `salePrice`
- `healthStatus`, `notes`

**Computed Properties:**
- `totalInvestment`: quantity × unitPrice
- `totalRevenue`: salePrice
- `profit`: revenue - investment

#### 3.3 CropRecord Class
**Fields:**
- `id`, `cropType`, `cropName`, `area`
- `plantingDate`, `harvestDate`
- `expectedYield`, `actualYield`, `yieldUnit`
- `seedCost`, `fertilizerCost`, `laborCost`
- `sellingPrice`, `notes`

**Computed Properties:**
- `totalCost`: sum of all costs
- `totalRevenue`: actualYield × sellingPrice
- `profit`: revenue - costs

---

### 4. Forex Trade Model
**File:** `lib/models/forex_trade.dart`

Manages foreign exchange trading records and analytics.

**Enums:**
- `TradeType`: buy, sell
- `TradeStatus`: open, closed, pending
- `OrderType`: market, limit, stop, stopLimit

#### 4.1 ForexTrade Class
**Fields:**
- `id` (String): Unique identifier
- `currencyPair` (String): e.g., "EUR/USD"
- `type` (TradeType): Buy or sell
- `status` (TradeStatus): Trade status
- `orderType` (OrderType): Order type
- `lotSize` (double): Trade size
- `entryPrice` (double): Entry price
- `exitPrice` (double?): Exit price
- `entryTime`, `exitTime` (DateTime): Trade times
- `stopLoss`, `takeProfit` (double?): Risk management
- `commission`, `swap` (double): Trading costs

**Computed Properties:**
- `pips`: Profit/loss in pips
- `profitLoss`: Net profit/loss in currency
- `roi`: Return on investment percentage
- `tradeDuration`: How long trade lasted
- `isWinning` / `isLosing` / `isBreakEven`: Trade outcome

**Methods:**
- Advanced pip calculation for different currency pairs
- Automatic profit/loss calculation
- Duration tracking

#### 4.2 TradingAccount Class
**Fields:**
- `id`, `accountName`
- `initialBalance`, `currentBalance`, `currency`
- `isActive`

**Computed Properties:**
- `totalProfitLoss`: Current - initial balance
- `roi`: Overall account performance

#### 4.3 TradingStatistics Class
**Fields:**
- `totalTrades`, `winningTrades`, `losingTrades`
- `totalProfit`, `totalLoss`, `netProfitLoss`
- `winRate`, `averageWin`, `averageLoss`
- `profitFactor`, `largestWin`, `largestLoss`

**Factory Constructor:**
- `fromTrades(List<ForexTrade>)`: Calculate stats from trade list

**Use Cases:**
- Trading performance analysis
- Win rate tracking
- Risk management
- Trade journaling

---

### 5. Budget Model
**File:** `lib/models/budget.dart`

Manages spending budgets and tracking.

**Enums:**
- `BudgetPeriod`: daily, weekly, monthly, quarterly, yearly

#### 5.1 Budget Class
**Fields:**
- `id` (String): Unique identifier
- `name` (String): Budget name
- `category` (TransactionCategory): Expense category
- `amount` (double): Budget amount
- `period` (BudgetPeriod): Budget period
- `startDate`, `endDate` (DateTime): Budget duration
- `isActive` (bool): Whether budget is active
- `notes` (String?): Additional information

**Computed Properties:**
- `periodName`: Human-readable period
- `isExpired`: Whether budget period ended
- `daysRemaining`: Days left in period
- `totalDuration`: Total budget duration

#### 5.2 BudgetProgress Class
**Fields:**
- `budget` (Budget): Associated budget
- `spent` (double): Amount spent so far
- `transactionCount` (int): Number of transactions

**Computed Properties:**
- `remaining`: Budget - spent
- `percentageUsed`: Spending percentage
- `percentageRemaining`: Remaining percentage
- `isOverBudget`: Whether exceeded limit
- `isNearLimit`: 80%+ spent warning
- `status`: On Track / Near Limit / Over Budget / Expired
- `averageDailySpending`: Average daily spending rate
- `projectedTotalSpending`: Projected end spending
- `willExceedBudget`: Forecast if will exceed

**Use Cases:**
- Budget planning
- Spending alerts
- Financial discipline
- Expense forecasting

---

## 🔗 Model Relationships

```
Transaction
├── Links to Budget (by category)
└── Can be AgricultureRecord or ForexTrade related

AgricultureRecord
├── Has many LivestockRecords
├── Has many CropRecords
└── Links to Transactions (by reference)

ForexTrade
├── Belongs to TradingAccount
└── Contributes to TradingStatistics

Budget
├── Tracks Transaction spending (by category)
└── Generates BudgetProgress reports

FinancialSummary
└── Aggregates all Transactions
```

---

## 🗄️ Database Schema

All models implement:
- `toMap()`: Serialize to Map<String, dynamic>
- `fromMap()`: Deserialize from Map<String, dynamic>
- `copyWith()`: Immutable updates
- `toString()`: Debug representation
- `operator ==` and `hashCode`: Equality comparison

**Ready for:**
- SQLite (sqflite package)
- Hive (hive package)
- Shared Preferences (simple storage)
- Firebase Firestore
- Any key-value or SQL database

---

## 📝 Usage Examples

### Creating a Transaction
```dart
final transaction = Transaction(
  id: 'tx_001',
  title: 'Sale of Maize',
  amount: 5000.0,
  type: TransactionType.income,
  category: TransactionCategory.sales,
  date: DateTime.now(),
  paymentMethod: PaymentMethod.mobileMoney,
  description: 'Sold 10 bags of maize',
);
```

### Creating an Agriculture Record
```dart
final cropRecord = AgricultureRecord(
  id: 'ag_001',
  type: AgricultureType.cropProduction,
  name: 'Maize Season 2024',
  startDate: DateTime(2024, 3, 1),
  area: 5.0,
  investmentCost: 15000.0,
  revenue: 25000.0,
);

print('Profit: \$${cropRecord.profit}');
print('ROI: ${cropRecord.roi}%');
```

### Creating a Forex Trade
```dart
final trade = ForexTrade(
  id: 'fx_001',
  currencyPair: 'EUR/USD',
  type: TradeType.buy,
  status: TradeStatus.closed,
  orderType: OrderType.market,
  lotSize: 0.1,
  entryPrice: 1.0850,
  exitPrice: 1.0920,
  entryTime: DateTime(2024, 1, 10, 9, 30),
  exitTime: DateTime(2024, 1, 10, 15, 45),
  commission: 5.0,
);

print('Profit: \$${trade.profitLoss}');
print('Pips: ${trade.pips}');
```

### Creating a Budget
```dart
final budget = Budget(
  id: 'bg_001',
  name: 'Monthly Food Budget',
  category: TransactionCategory.other,
  amount: 30000.0,
  period: BudgetPeriod.monthly,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
);

final progress = BudgetProgress(
  budget: budget,
  spent: 24000.0,
  transactionCount: 45,
);

print('Status: ${progress.status}');
print('Remaining: \$${progress.remaining}');
```

---

## 🚀 Next Steps

1. **Database Integration**: Implement repositories for each model
2. **State Management**: Use Provider/Riverpod to manage model state
3. **Validation**: Add input validation rules
4. **Migration**: Create database migration scripts
5. **Testing**: Write unit tests for all models
6. **API Integration**: Add backend sync capabilities

---

## 📦 Model Summary

| Model | Purpose | Records |
|-------|---------|---------|
| Transaction | Financial transactions | Income & expenses |
| FinancialSummary | Dashboard aggregates | Summary statistics |
| AgricultureRecord | Farm projects | Crops & livestock |
| LivestockRecord | Animal tracking | Animal inventory |
| CropRecord | Crop tracking | Planting & harvest |
| ForexTrade | Trading records | Buy/sell trades |
| TradingAccount | Trading accounts | Account balance |
| TradingStatistics | Trading analytics | Performance metrics |
| Budget | Spending budgets | Budget limits |
| BudgetProgress | Budget tracking | Spending progress |

**Total: 10 comprehensive data models ready for implementation!**
