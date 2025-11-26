import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/recommendation.dart';
import '../services/gemini_service.dart';
import '../services/transaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class SmartRecommendationsPage extends ConsumerStatefulWidget {
  const SmartRecommendationsPage({super.key});

  @override
  ConsumerState<SmartRecommendationsPage> createState() =>
      _SmartRecommendationsPageState();
}

class _SmartRecommendationsPageState
    extends ConsumerState<SmartRecommendationsPage> {
  late final GeminiService _geminiService;
  late final TransactionRepository _repository;

  List<Recommendation> _recommendations = [];
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  double _totalIncome = 0;
  double _totalExpenses = 0;
  double _netProfit = 0;

  @override
  void initState() {
    super.initState();
    _geminiService = ref.read(geminiServiceProvider);
    _repository = ref.read(transactionRepositoryProvider);
    _loadTransactionSummary();
  }

  Future<void> _loadTransactionSummary() async {
    try {
      final transactions = await _repository.getAllTransactions();
      final summary = await _repository.getFinancialSummary();

      setState(() {
        _transactions = transactions;
        _totalIncome = summary.totalIncome;
        _totalExpenses = summary.totalExpenses;
        _netProfit = summary.netProfit;
      });
    } catch (e) {
      // Handle error silently for summary
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_transactions.isEmpty) {
      setState(() {
        _error =
            'No transaction data available to analyze. Add some transactions first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _recommendations = [];
    });

    try {
      final recommendations = await _geminiService.analyzeTransactions(
        _transactions,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Recommendations'),
        actions: [
          if (_recommendations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _analyzeWithAI,
              tooltip: 'Refresh recommendations',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadTransactionSummary();
          if (_recommendations.isNotEmpty) {
            await _analyzeWithAI();
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI-Powered Insights',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Get personalized financial recommendations',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Financial Summary
                    Text(
                      'Financial Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryChip(
                            label: 'Income',
                            value: '\$${_totalIncome.toStringAsFixed(2)}',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryChip(
                            label: 'Expenses',
                            value: '\$${_totalExpenses.toStringAsFixed(2)}',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SummaryChip(
                      label: 'Net Profit',
                      value: '\$${_netProfit.toStringAsFixed(2)}',
                      color: _netProfit >= 0 ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_transactions.length} transactions',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Analyze Button
            if (_recommendations.isEmpty && !_isLoading)
              FilledButton.icon(
                onPressed: _analyzeWithAI,
                icon: const Icon(Icons.psychology),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Analyze with AI'),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),

            const SizedBox(height: 16),

            // Loading State
            if (_isLoading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing your financial data...',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),

            // Error State
            if (_error != null)
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Analysis Failed',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _analyzeWithAI,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_error!.contains('API') || _error!.contains('key'))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Tip: Make sure you have added a valid Gemini API key in lib/utils/constants.dart',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.red[600],
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // Recommendations List
            if (_recommendations.isNotEmpty) ...[
              Text(
                'Recommendations',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...(_recommendations.map(
                (rec) => _RecommendationCard(recommendation: rec),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  Color _getCardColor(RecommendationType type) {
    switch (type) {
      case RecommendationType.insight:
        return Colors.blue;
      case RecommendationType.savings:
        return Colors.green;
      case RecommendationType.warning:
        return Colors.orange;
      case RecommendationType.opportunity:
        return Colors.purple;
    }
  }

  IconData _getIcon(RecommendationType type) {
    switch (type) {
      case RecommendationType.insight:
        return Icons.lightbulb;
      case RecommendationType.savings:
        return Icons.savings;
      case RecommendationType.warning:
        return Icons.warning_amber;
      case RecommendationType.opportunity:
        return Icons.trending_up;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCardColor(recommendation.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(recommendation.type),
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.typeLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recommendation.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            if (recommendation.actionText != null) ...[
              const SizedBox(height: 12),
              Text(
                '💡 ${recommendation.actionText}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
