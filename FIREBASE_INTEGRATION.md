# Firebase Backend Integration Guide

## 📋 Overview

This document provides guidance for implementing Firebase backend integration for the NUMBERS app. All repository interfaces are defined and ready for Firebase implementation.

## 🏗️ Architecture

```
Frontend (Flutter)
    ↓
Repository Interfaces (Abstract Classes)
    ↓
Firebase Implementation (To be implemented)
    ↓
Firebase Services (Firestore, Auth, Storage)
```

## 📁 Repository Interfaces

### Location: `lib/services/`

1. **transaction_repository.dart** - Financial transactions
2. **agriculture_repository.dart** - Agriculture records
3. **forex_repository.dart** - Forex trading
4. **budget_repository.dart** - Budget management

All interfaces are abstract classes with method signatures ready for implementation.

## 🔥 Firebase Setup Requirements

### 1. Firebase Services Needed

- **Firebase Auth**: User authentication
- **Cloud Firestore**: Data storage
- **Firebase Storage**: Receipt/document attachments
- **Cloud Functions**: Backend logic (optional)
- **Firebase Analytics**: Usage tracking (optional)

### 2. Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: ^3.0.0
  firebase_auth: ^5.0.0
  cloud_firestore: ^5.0.0
  firebase_storage: ^12.0.0
  firebase_analytics: ^11.0.0  # optional
```

### 3. Platform Configuration

Run Flutter Firebase CLI:
```bash
flutter pub add firebase_core
flutter pub add firebase_auth
flutter pub add cloud_firestore
flutter pub add firebase_storage
flutterfire configure
```

## 🗄️ Firestore Database Structure

### Recommended Collections

```
users/
  {userId}/
    profile: {...}
    settings: {...}
    
    transactions/
      {transactionId}: {
        id, title, amount, type, category,
        date, description, paymentMethod,
        createdAt, updatedAt, ...
      }
    
    agriculture/
      {recordId}: {
        id, type, name, startDate, area,
        investmentCost, revenue, ...
      }
      
      livestock/
        {livestockId}: {...}
      
      crops/
        {cropId}: {...}
    
    forex/
      trades/
        {tradeId}: {
          id, currencyPair, type, status,
          lotSize, entryPrice, exitPrice, ...
        }
      
      accounts/
        {accountId}: {
          id, accountName, initialBalance,
          currentBalance, ...
        }
    
    budgets/
      {budgetId}: {
        id, name, category, amount,
        period, startDate, endDate, ...
      }
```

### Security Rules Example

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User data is private
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Nested collections inherit parent rules
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 💻 Implementation Example

### Step 1: Create Firebase Transaction Repository

Create: `lib/services/firebase_transaction_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'transaction_repository.dart';

class FirebaseTransactionRepository implements TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseTransactionRepository({required this.userId});

  CollectionReference get _collection =>
      _firestore.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final snapshot = await _collection.orderBy('date', descending: true).get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _collection.doc(transaction.id).set(transaction.toMap());
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _collection.doc(transaction.id).update(
      transaction.copyWith(updatedAt: DateTime.now()).toMap(),
    );
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _collection.doc(id).delete();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return Transaction.fromMap(doc.data() as Map<String, dynamic>);
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final snapshot = await _collection
        .where('type', isEqualTo: type.index)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await _collection
        .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
        .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<double> getTotalIncome() async {
    final transactions = await getTransactionsByType(TransactionType.income);
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpenses() async {
    final transactions = await getTransactionsByType(TransactionType.expense);
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<FinancialSummary> getFinancialSummary() async {
    final income = await getTotalIncome();
    final expenses = await getTotalExpenses();
    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      netProfit: income - expenses,
      balance: income - expenses,
    );
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    // Note: Firestore doesn't support full-text search natively
    // Consider using Algolia or implement client-side filtering
    final all = await getAllTransactions();
    final lowercaseQuery = query.toLowerCase();
    return all.where((t) =>
      t.title.toLowerCase().contains(lowercaseQuery) ||
      (t.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  @override
  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final snapshot = await _collection
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(
    TransactionCategory category,
  ) async {
    final snapshot = await _collection
        .where('category', isEqualTo: category.index)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
```

### Step 2: Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Generated by flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const NumbersApp());
}
```

### Step 3: Use Repository in Pages

```dart
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_transaction_repository.dart';

class DashboardPage extends StatefulWidget {
  // ...
}

class _DashboardPageState extends State<DashboardPage> {
  late final TransactionRepository _transactionRepo;
  FinancialSummary? _summary;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _transactionRepo = FirebaseTransactionRepository(userId: userId);
    _loadData();
  }

  Future<void> _loadData() async {
    final summary = await _transactionRepo.getFinancialSummary();
    setState(() {
      _summary = summary;
    });
  }

  // ... rest of widget
}
```

## 🔐 Authentication Implementation

### Create Auth Service

Create: `lib/services/auth_service.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
```

## 📤 File Upload (Receipts/Attachments)

### Storage Service Example

```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadReceipt(String userId, String transactionId, File file) async {
    try {
      final ref = _storage
          .ref()
          .child('users/$userId/receipts/$transactionId.jpg');
      
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<void> deleteReceipt(String userId, String transactionId) async {
    try {
      final ref = _storage
          .ref()
          .child('users/$userId/receipts/$transactionId.jpg');
      await ref.delete();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
```

## 📊 Real-time Data with Streams

### Stream Example

```dart
class FirebaseTransactionRepository {
  // ... existing code ...

  // Stream of transactions
  Stream<List<Transaction>> transactionsStream() {
    return _collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Transaction.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}

// Usage in widget
class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: _transactionRepo.transactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text(transaction.title),
                subtitle: Text(transaction.date.toString()),
                trailing: Text('\$${transaction.amount}'),
              );
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

## 🧪 Testing

### Mock Repository for Testing

```dart
class MockTransactionRepository implements TransactionRepository {
  final List<Transaction> _transactions = [];

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return List.from(_transactions);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  // ... implement other methods with in-memory data
}
```

## 📝 Implementation Checklist

### Phase 1: Setup (1-2 days)
- [ ] Create Firebase project
- [ ] Configure Firebase for Android/iOS/Web
- [ ] Add Firebase packages to pubspec.yaml
- [ ] Run `flutterfire configure`
- [ ] Set up Firebase Authentication
- [ ] Create Firestore database
- [ ] Configure security rules

### Phase 2: Core Implementation (3-5 days)
- [ ] Implement FirebaseTransactionRepository
- [ ] Implement FirebaseAgricultureRepository
- [ ] Implement FirebaseForexRepository
- [ ] Implement FirebaseBudgetRepository
- [ ] Create AuthService
- [ ] Create StorageService

### Phase 3: Integration (2-3 days)
- [ ] Update all pages to use repositories
- [ ] Implement loading states
- [ ] Add error handling
- [ ] Test CRUD operations
- [ ] Implement real-time updates

### Phase 4: Features (2-3 days)
- [ ] Add user authentication screens
- [ ] Implement file uploads
- [ ] Add offline support
- [ ] Implement data sync
- [ ] Add analytics tracking

### Phase 5: Testing & Polish (2-3 days)
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Test on multiple devices
- [ ] Performance optimization
- [ ] Security audit

## 🚀 Best Practices

1. **Error Handling**: Always wrap Firebase calls in try-catch
2. **Loading States**: Show progress indicators during async operations
3. **Offline Support**: Use Firestore offline persistence
4. **Security**: Implement proper security rules
5. **Indexing**: Create Firestore indexes for complex queries
6. **Pagination**: Use limit() and startAfter() for large datasets
7. **Caching**: Enable Firestore caching for better performance
8. **Transactions**: Use Firestore transactions for critical operations

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)

## 🤝 Collaboration Notes

### Frontend Team Responsibilities:
✅ Data models (completed)
✅ UI pages (completed)
✅ Repository interfaces (completed)
✅ Widget components (completed)

### Backend Team Responsibilities:
⏳ Firebase project setup
⏳ Repository implementations
⏳ Authentication service
⏳ Security rules
⏳ Cloud functions (if needed)
⏳ Data migration (if needed)

### Communication:
- Repository interfaces are frozen - no changes needed
- Data models are stable - use toMap()/fromMap() methods
- All async operations use Future/Stream
- Follow the provided architecture pattern

---

**Total Estimated Time: 10-16 days**

Good luck with the implementation! 🎉
