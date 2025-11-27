import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';
import '../models/recommendation.dart';
import '../utils/constants.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: AppConstants.geminiApiKey,
    );
  }

  /// Analyze transactions and generate AI-powered recommendations
  Future<List<Recommendation>> analyzeTransactions(
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) {
      throw Exception('No transaction data available to analyze');
    }

    // Build analysis prompt
    final prompt = _buildPrompt(transactions);

    try {
      // Generate content using Gemini
      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Received empty response from AI');
      }

      // Parse the response into recommendations
      return _parseRecommendations(response.text!);
    } catch (e) {
      throw Exception('Failed to generate recommendations: ${e.toString()}');
    }
  }

  String _buildPrompt(List<Transaction> transactions) {
    // Calculate summary statistics
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final netProfit = totalIncome - totalExpenses;

    // Group expenses by category
    final Map<String, double> expensesByCategory = {};
    for (var transaction in transactions.where((t) => t.isExpense)) {
      final category = transaction.categoryName;
      expensesByCategory[category] =
          (expensesByCategory[category] ?? 0) + transaction.amount;
    }

    // Get top spending categories
    final topCategories = expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return '''
You are a financial advisor AI assistant analyzing financial records. Based on the following transaction data, provide 4-6 specific, actionable recommendations.

Financial Summary:
- Total Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
- Net Profit/Loss: \$${netProfit.toStringAsFixed(2)}
- Number of Transactions: ${transactions.length}

Top Spending Categories:
${topCategories.take(5).map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)}').join('\n')}

Please provide recommendations in the following format. Each recommendation should be on a new line with this exact structure:
[TYPE]|Title|Description

Where TYPE can be:
- INSIGHT: General observations about financial patterns
- SAVINGS: Specific opportunities to reduce expenses
- WARNING: Concerns or risks to address
- OPPORTUNITY: Ideas for increasing income or growth

Example:
INSIGHT|Strong Income Performance|Your income has been consistent, showing financial stability.
SAVINGS|Reduce Equipment Costs|Equipment expenses are 25% of total spending. Consider buying second-hand or renting.

Requirements:
- Provide 4-6 recommendations total
- Mix different types (at least one of each type if applicable)
- Be specific with numbers and percentages
- Make recommendations actionable
- Keep titles under 50 characters
- Keep descriptions under 150 characters
''';
  }

  List<Recommendation> _parseRecommendations(String responseText) {
    final recommendations = <Recommendation>[];
    final lines = responseText
        .split('\n')
        .where((line) => line.trim().isNotEmpty);

    int id = 1;
    for (var line in lines) {
      // Look for lines with the pattern: TYPE|Title|Description
      if (line.contains('|')) {
        final parts = line.split('|');
        if (parts.length >= 3) {
          final typeStr = parts[0].trim().toUpperCase();
          final title = parts[1].trim();
          final description = parts[2].trim();

          RecommendationType? type;
          switch (typeStr) {
            case 'INSIGHT':
              type = RecommendationType.insight;
              break;
            case 'SAVINGS':
              type = RecommendationType.savings;
              break;
            case 'WARNING':
              type = RecommendationType.warning;
              break;
            case 'OPPORTUNITY':
              type = RecommendationType.opportunity;
              break;
          }

          if (type != null && title.isNotEmpty && description.isNotEmpty) {
            recommendations.add(
              Recommendation(
                id: 'rec_$id',
                type: type,
                title: title,
                description: description,
              ),
            );
            id++;
          }
        }
      }
    }

    // If parsing failed, provide a fallback
    if (recommendations.isEmpty) {
      recommendations.add(
        Recommendation(
          id: 'rec_fallback',
          type: RecommendationType.insight,
          title: 'Analysis Complete',
          description:
              'AI analysis completed. Please try generating recommendations again.',
        ),
      );
    }

    return recommendations;
  }
}
