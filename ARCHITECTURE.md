# NUMBERS App Architecture

## File Structure Overview

```
numbers/
│
├── lib/
│   ├── main.dart                      # Entry point, navigation setup
│   │
│   ├── models/                        # Data models
│   │   ├── transaction.dart           # Transaction data structure
│   │   └── financial_summary.dart     # Financial summary data
│   │
│   ├── pages/                         # Screen pages
│   │   ├── dashboard_page.dart        # Home dashboard
│   │   ├── transactions_page.dart     # Transactions list
│   │   ├── reports_page.dart          # Financial reports
│   │   ├── settings_page.dart         # App settings
│   │   ├── add_transaction_page.dart  # Add income/expense
│   │   ├── agriculture_page.dart      # Agriculture module
│   │   └── forex_page.dart            # Forex trading module
│   │
│   ├── widgets/                       # Reusable UI components
│   │   ├── summary_card.dart          # Financial summary cards
│   │   ├── quick_action_card.dart     # Quick action buttons
│   │   └── report_card.dart           # Report list items
│   │
│   ├── services/                      # Business logic (future)
│   │   └── [To be implemented]
│   │
│   └── utils/                         # Constants and utilities
│       ├── constants.dart             # Colors, app constants
│       └── strings.dart               # Text strings
│
├── test/                              # Unit tests
├── android/                           # Android config
├── ios/                               # iOS config
├── web/                               # Web config
├── windows/                           # Windows config
├── pubspec.yaml                       # Dependencies
└── README.md                          # Documentation
```

## Navigation Flow

```
App Launch
    ↓
main.dart (NumbersApp)
    ↓
HomePage (Bottom Navigation)
    ├── [0] DashboardPage
    │   ├── Quick Actions
    │   │   ├── → AddTransactionPage (Income)
    │   │   ├── → AddTransactionPage (Expense)
    │   │   ├── → AgriculturePage
    │   │   └── → ForexPage
    │   └── Recent Transactions
    │
    ├── [1] TransactionsPage
    │   └── → AddTransactionPage
    │
    ├── [2] ReportsPage
    │   ├── Income Statement
    │   ├── Balance Sheet
    │   ├── Cash Flow
    │   ├── Expense Analysis
    │   ├── Performance Trends
    │   └── Smart Recommendations
    │
    └── [3] SettingsPage
        ├── Business Type
        │   ├── Forex Trading
        │   └── Agriculture
        └── General Settings
```

## Component Relationships

```
DashboardPage
├── Uses: SummaryCard (x4)
├── Uses: QuickActionCard (x4)
└── Navigates to: AddTransactionPage, AgriculturePage, ForexPage

TransactionsPage
└── Navigates to: AddTransactionPage

ReportsPage
└── Uses: ReportCard (x6)

AddTransactionPage
├── Input: isIncome (bool)
└── Form validation and submission

AgriculturePage
├── Animal Husbandry module
├── Crop Production module
└── Horticulture module

ForexPage
├── Trading summary
└── Trade management
```

## Future Architecture

```
App
├── Authentication Layer (Future)
├── Database Layer (SQLite/Hive)
├── API Layer (Backend integration)
├── State Management (Provider/Riverpod)
└── Analytics/ML (Smart recommendations)
```

## Key Design Patterns

1. **Separation of Concerns**
   - Pages: UI screens
   - Widgets: Reusable components
   - Models: Data structures
   - Services: Business logic
   - Utils: Constants and helpers

2. **Widget Composition**
   - Small, focused widgets
   - Reusable components
   - Clear prop passing

3. **Navigation**
   - Bottom navigation for main sections
   - Push navigation for sub-pages
   - Named routes (future enhancement)

## Next Development Steps

1. **Database Integration**
   - Add SQLite/Hive
   - Create DAO/Repository layer
   - Implement CRUD operations

2. **State Management**
   - Add Provider/Riverpod
   - Separate business logic
   - Reactive data updates

3. **Services Layer**
   - TransactionService
   - ReportService
   - SyncService
   - AuthService

4. **Testing**
   - Unit tests for models
   - Widget tests for UI
   - Integration tests
