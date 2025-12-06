enum ReportType { weekly, monthly }

class FinancialReport {
  final String id;
  final ReportType type;
  final DateTime date;
  final String summary;
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  final List<String> keyTrends;
  final String aiAnalysis;

  FinancialReport({
    required this.id,
    required this.type,
    required this.date,
    required this.summary,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.keyTrends,
    required this.aiAnalysis,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'date': date.toIso8601String(),
      'summary': summary,
      'totalIncome': totalIncome,
      'totalExpenses': totalExpenses,
      'netSavings': netSavings,
      'keyTrends': keyTrends,
      'aiAnalysis': aiAnalysis,
    };
  }

  factory FinancialReport.fromMap(Map<String, dynamic> map) {
    return FinancialReport(
      id: map['id'],
      type: ReportType.values[map['type']],
      date: DateTime.parse(map['date']),
      summary: map['summary'],
      totalIncome: map['totalIncome'],
      totalExpenses: map['totalExpenses'],
      netSavings: map['netSavings'],
      keyTrends: List<String>.from(map['keyTrends']),
      aiAnalysis: map['aiAnalysis'],
    );
  }
}
