enum RecommendationType { insight, savings, warning, opportunity, trend }

class Recommendation {
  final String id;
  final RecommendationType type;
  final String title;
  final String description;
  final String? actionText;
  final DateTime createdAt;

  Recommendation({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.actionText,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get typeLabel {
    switch (type) {
      case RecommendationType.insight:
        return 'Insight';
      case RecommendationType.savings:
        return 'Savings Opportunity';
      case RecommendationType.warning:
        return 'Warning';
      case RecommendationType.opportunity:
        return 'Growth Opportunity';
      case RecommendationType.trend:
        return 'Trend Alert';
    }
  }

  String get emoji {
    switch (type) {
      case RecommendationType.insight:
        return '💡';
      case RecommendationType.savings:
        return '💰';
      case RecommendationType.warning:
        return '⚠️';
      case RecommendationType.opportunity:
        return '📈';
      case RecommendationType.trend:
        return '📊';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'actionText': actionText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['id'],
      type: RecommendationType.values[map['type']],
      title: map['title'],
      description: map['description'],
      actionText: map['actionText'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
