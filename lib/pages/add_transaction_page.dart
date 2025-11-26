import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class AddTransactionPage extends ConsumerStatefulWidget {
  final bool isIncome;
  final Transaction? existingTransaction; // For editing

  const AddTransactionPage({
    super.key,
    required this.isIncome,
    this.existingTransaction,
  });

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TransactionCategory? _selectedCategory;
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isRecurring = false;
  String? _recurringFrequency;
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Income categories
  final List<TransactionCategory> _incomeCategories = [
    TransactionCategory.sales,
    TransactionCategory.trading,
    TransactionCategory.harvest,
    TransactionCategory.livestock,
  ];

  // Expense categories
  final List<TransactionCategory> _expenseCategories = [
    TransactionCategory.feed,
    TransactionCategory.fertilizer,
    TransactionCategory.seeds,
    TransactionCategory.labor,
    TransactionCategory.equipment,
    TransactionCategory.transport,
    TransactionCategory.utilities,
    TransactionCategory.other,
  ];

  final List<String> _recurringOptions = [
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingTransaction != null) {
      _loadExistingTransaction();
    } else {
      // Set default category
      _selectedCategory = widget.isIncome
          ? _incomeCategories.first
          : _expenseCategories.first;
    }
  }

  void _loadExistingTransaction() {
    final transaction = widget.existingTransaction!;
    _titleController.text = transaction.title;
    _amountController.text = transaction.amount.toString();
    _descriptionController.text = transaction.description ?? '';
    _referenceController.text = transaction.reference ?? '';
    _selectedDate = transaction.date;
    _selectedCategory = transaction.category;
    _selectedPaymentMethod = transaction.paymentMethod ?? PaymentMethod.cash;
    _isRecurring = transaction.isRecurring;
    _recurringFrequency = transaction.recurringFrequency;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.sales:
        return 'Sales';
      case TransactionCategory.trading:
        return 'Trading';
      case TransactionCategory.harvest:
        return 'Harvest';
      case TransactionCategory.livestock:
        return 'Livestock';
      case TransactionCategory.feed:
        return 'Feed';
      case TransactionCategory.fertilizer:
        return 'Fertilizer';
      case TransactionCategory.seeds:
        return 'Seeds';
      case TransactionCategory.labor:
        return 'Labor';
      case TransactionCategory.equipment:
        return 'Equipment';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.utilities:
        return 'Utilities';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bank:
        return 'Bank Transfer';
      case PaymentMethod.mobileMoney:
        return 'Mobile Money';
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.check:
        return 'Check';
    }
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.sales:
        return Icons.shopping_cart;
      case TransactionCategory.trading:
        return Icons.trending_up;
      case TransactionCategory.harvest:
        return Icons.agriculture;
      case TransactionCategory.livestock:
        return Icons.pets;
      case TransactionCategory.feed:
        return Icons.restaurant;
      case TransactionCategory.fertilizer:
        return Icons.grass;
      case TransactionCategory.seeds:
        return Icons.spa;
      case TransactionCategory.labor:
        return Icons.work;
      case TransactionCategory.equipment:
        return Icons.build;
      case TransactionCategory.transport:
        return Icons.local_shipping;
      case TransactionCategory.utilities:
        return Icons.power;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.bank:
        return Icons.account_balance;
      case PaymentMethod.mobileMoney:
        return Icons.phone_android;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.check:
        return Icons.receipt_long;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Create transaction object
      final transaction = Transaction(
        id:
            widget.existingTransaction?.id ??
            'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: widget.isIncome
            ? TransactionType.income
            : TransactionType.expense,
        category: _selectedCategory!,
        date: dateTime,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        reference: _referenceController.text.trim().isNotEmpty
            ? _referenceController.text.trim()
            : null,
        paymentMethod: _selectedPaymentMethod,
        isRecurring: _isRecurring,
        recurringFrequency: _isRecurring ? _recurringFrequency : null,
        createdAt: widget.existingTransaction?.createdAt ?? DateTime.now(),
        updatedAt: widget.existingTransaction != null ? DateTime.now() : null,
      );

      try {
        final repo = ref.read(transactionRepositoryProvider);
        if (widget.existingTransaction != null) {
          await repo.updateTransaction(transaction);
        } else {
          await repo.addTransaction(transaction);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.existingTransaction != null
                    ? 'Transaction updated successfully!'
                    : '${widget.isIncome ? "Income" : "Expense"} added successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, transaction);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving transaction: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.isIncome ? _incomeCategories : _expenseCategories;
    final isEditing = widget.existingTransaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Edit Transaction'
              : 'Add ${widget.isIncome ? "Income" : "Expense"}',
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text(
                      'Are you sure you want to delete this transaction?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  try {
                    await ref
                        .read(transactionRepositoryProvider)
                        .deleteTransaction(widget.existingTransaction!.id);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting transaction: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: widget.isIncome
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isIncome ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: widget.isIncome ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.isIncome
                        ? 'Income Transaction'
                        : 'Expense Transaction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Crop Sale, Feed Purchase',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount *',
                hintText: '0.00',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                helperText: 'Enter amount without currency symbol',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid number';
                }
                if (amount <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Dropdown with Icons
            DropdownButtonFormField<TransactionCategory>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category *',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(
                  _selectedCategory != null
                      ? _getCategoryIcon(_selectedCategory!)
                      : Icons.category,
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
              ),
              items: categories.map((TransactionCategory category) {
                return DropdownMenuItem<TransactionCategory>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(_getCategoryIcon(category), size: 20),
                      const SizedBox(width: 8),
                      Text(_getCategoryName(category)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (TransactionCategory? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Method Dropdown
            DropdownButtonFormField<PaymentMethod>(
              initialValue: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(_getPaymentMethodIcon(_selectedPaymentMethod)),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
              ),
              items: PaymentMethod.values.map((PaymentMethod method) {
                return DropdownMenuItem<PaymentMethod>(
                  value: method,
                  child: Row(
                    children: [
                      Icon(_getPaymentMethodIcon(method), size: 20),
                      const SizedBox(width: 8),
                      Text(_getPaymentMethodName(method)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (PaymentMethod? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue ?? PaymentMethod.cash;
                });
              },
            ),
            const SizedBox(height: 16),

            // Date and Time Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date *',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.access_time),
                        filled: true,
                        fillColor: Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Reference Field
            TextFormField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Reference Number',
                hintText: 'Receipt/Invoice number',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.receipt_long),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                helperText: 'Optional',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Additional notes or details',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notes),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.1),
                helperText: 'Optional',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Recurring Transaction Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.repeat, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Recurring Transaction',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isRecurring,
                          onChanged: (value) {
                            setState(() {
                              _isRecurring = value;
                              if (!value) {
                                _recurringFrequency = null;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _recurringFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.schedule),
                        ),
                        items: _recurringOptions.map((String frequency) {
                          return DropdownMenuItem<String>(
                            value: frequency,
                            child: Text(frequency),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _recurringFrequency = newValue;
                          });
                        },
                        validator: (value) {
                          if (_isRecurring && value == null) {
                            return 'Please select a frequency';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This transaction will repeat ${_recurringFrequency?.toLowerCase() ?? "periodically"}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveTransaction,
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update' : 'Save Transaction'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: widget.isIncome
                          ? Colors.green
                          : Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Required fields note
            Text(
              '* Required fields',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
