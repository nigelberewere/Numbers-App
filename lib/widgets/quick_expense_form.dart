import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';

/// Quick expense entry form with minimal fields
class QuickExpenseForm extends StatefulWidget {
  const QuickExpenseForm({super.key});

  @override
  State<QuickExpenseForm> createState() => _QuickExpenseFormState();
}

class _QuickExpenseFormState extends State<QuickExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  TransactionCategory _selectedCategory = TransactionCategory.other;
  
  // Quick categories for expenses
  final Map<TransactionCategory, Map<String, dynamic>> _quickCategories = {
    TransactionCategory.feed: {
      'name': 'Feed',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    TransactionCategory.fertilizer: {
      'name': 'Fertilizer',
      'icon': Icons.grass,
      'color': Colors.green,
    },
    TransactionCategory.transport: {
      'name': 'Transport',
      'icon': Icons.local_shipping,
      'color': Colors.blue,
    },
    TransactionCategory.labor: {
      'name': 'Labor',
      'icon': Icons.work,
      'color': Colors.purple,
    },
    TransactionCategory.utilities: {
      'name': 'Utilities',
      'icon': Icons.power,
      'color': Colors.amber,
    },
    TransactionCategory.other: {
      'name': 'Other',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
    },
  };

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        title: '${_quickCategories[_selectedCategory]!['name']} Expense',
        amount: double.parse(_amountController.text),
        type: TransactionType.expense,
        category: _selectedCategory,
        date: DateTime.now(),
        description: _noteController.text.trim().isNotEmpty 
            ? _noteController.text.trim() 
            : null,
        paymentMethod: PaymentMethod.cash,
      );

      Navigator.pop(context, transaction);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.flash_on, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Quick Expense',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selection
              const Text(
                'Category',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickCategories.entries.map((entry) {
                  final isSelected = _selectedCategory == entry.key;
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          entry.value['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : entry.value['color'] as Color,
                        ),
                        const SizedBox(width: 4),
                        Text(entry.value['name'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = entry.key;
                      });
                    },
                    selectedColor: entry.value['color'] as Color,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Note Field
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add a quick note',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
