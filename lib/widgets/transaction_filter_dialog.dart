import 'package:flutter/material.dart';
import '../models/models.dart';

class TransactionFilters {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<TransactionCategory> categories;
  final TransactionType? transactionType;
  final double? minAmount;
  final double? maxAmount;

  TransactionFilters({
    this.startDate,
    this.endDate,
    this.categories = const [],
    this.transactionType,
    this.minAmount,
    this.maxAmount,
  });

  TransactionFilters copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<TransactionCategory>? categories,
    TransactionType? transactionType,
    double? minAmount,
    double? maxAmount,
  }) {
    return TransactionFilters(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categories: categories ?? this.categories,
      transactionType: transactionType ?? this.transactionType,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }

  bool get hasActiveFilters =>
      startDate != null ||
      endDate != null ||
      categories.isNotEmpty ||
      transactionType != null ||
      minAmount != null ||
      maxAmount != null;
}

class TransactionFilterDialog extends StatefulWidget {
  final TransactionFilters initialFilters;

  const TransactionFilterDialog({
    super.key,
    required this.initialFilters,
  });

  @override
  State<TransactionFilterDialog> createState() =>
      _TransactionFilterDialogState();
}

class _TransactionFilterDialogState extends State<TransactionFilterDialog> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late Set<TransactionCategory> _selectedCategories;
  late TransactionType? _transactionType;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialFilters.startDate;
    _endDate = widget.initialFilters.endDate;
    _selectedCategories = Set.from(widget.initialFilters.categories);
    _transactionType = widget.initialFilters.transactionType;
    _minAmountController = TextEditingController(
      text: widget.initialFilters.minAmount?.toString() ?? '',
    );
    _maxAmountController = TextEditingController(
      text: widget.initialFilters.maxAmount?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedCategories.clear();
      _transactionType = null;
      _minAmountController.clear();
      _maxAmountController.clear();
    });
  }

  void _applyFilters() {
    final filters = TransactionFilters(
      startDate: _startDate,
      endDate: _endDate,
      categories: _selectedCategories.toList(),
      transactionType: _transactionType,
      minAmount: _minAmountController.text.isNotEmpty
          ? double.tryParse(_minAmountController.text)
          : null,
      maxAmount: _maxAmountController.text.isNotEmpty
          ? double.tryParse(_maxAmountController.text)
          : null,
    );
    Navigator.of(context).pop(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filter Transactions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range
                    Text(
                      'Date Range',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(_startDate != null && _endDate != null
                            ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                            : 'Select date range'),
                        trailing: _startDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _startDate = null;
                                    _endDate = null;
                                  });
                                },
                              )
                            : const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: _selectDateRange,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Transaction Type
                    Text(
                      'Transaction Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TransactionType?>(
                      segments: const [
                        ButtonSegment(
                          value: null,
                          label: Text('All'),
                          icon: Icon(Icons.all_inclusive),
                        ),
                        ButtonSegment(
                          value: TransactionType.income,
                          label: Text('Income'),
                          icon: Icon(Icons.trending_up),
                        ),
                        ButtonSegment(
                          value: TransactionType.expense,
                          label: Text('Expense'),
                          icon: Icon(Icons.trending_down),
                        ),
                      ],
                      selected: {_transactionType},
                      onSelectionChanged: (Set<TransactionType?> selected) {
                        setState(() {
                          _transactionType = selected.first;
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // Amount Range
                    Text(
                      'Amount Range',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Min Amount',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _maxAmountController,
                            decoration: const InputDecoration(
                              labelText: 'Max Amount',
                              prefixText: '\$ ',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_selectedCategories.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategories.clear();
                              });
                            },
                            child: const Text('Clear all'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          TransactionCategory.values.map((category) {
                        final isSelected =
                            _selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(_getCategoryName(category)),
                          avatar: Icon(
                            _getCategoryIcon(category),
                            size: 18,
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.add(category);
                              } else {
                                _selectedCategories.remove(category);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                  ),
                  FilledButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.check),
                    label: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getCategoryName(TransactionCategory category) {
    return category.toString().split('.').last.toUpperCase();
  }

  IconData _getCategoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.seeds:
        return Icons.grass;
      case TransactionCategory.fertilizer:
        return Icons.science;
      case TransactionCategory.feed:
        return Icons.restaurant;
      case TransactionCategory.labor:
        return Icons.people;
      case TransactionCategory.equipment:
        return Icons.build;
      case TransactionCategory.transport:
        return Icons.local_shipping;
      case TransactionCategory.utilities:
        return Icons.power;
      case TransactionCategory.sales:
        return Icons.point_of_sale;
      case TransactionCategory.trading:
        return Icons.trending_up;
      case TransactionCategory.livestock:
        return Icons.pets;
      case TransactionCategory.harvest:
        return Icons.agriculture;
      case TransactionCategory.other:
        return Icons.more_horiz;
    }
  }
}
