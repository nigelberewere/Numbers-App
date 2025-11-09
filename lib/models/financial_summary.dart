class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double netProfit;
  final double balance;
  final DateTime periodStart;
  final DateTime periodEnd;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netProfit,
    required this.balance,
    required this.periodStart,
    required this.periodEnd,
  });

  factory FinancialSummary.empty() {
    final now = DateTime.now();
    return FinancialSummary(
      totalIncome: 0.0,
      totalExpenses: 0.0,
      netProfit: 0.0,
      balance: 0.0,
      periodStart: now,
      periodEnd: now,
    );
  }
}
