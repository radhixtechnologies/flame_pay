class CibilFactorModel {
  final String title;
  final String status; // 'Excellent', 'Good', 'Average', 'Poor'
  final String value;
  final String impact; // 'High', 'Medium', 'Low'
  final double scorePercent; // 0.0 - 1.0

  const CibilFactorModel({
    required this.title,
    required this.status,
    required this.value,
    required this.impact,
    required this.scorePercent,
  });

  factory CibilFactorModel.fromJson(Map<String, dynamic> json) {
    return CibilFactorModel(
      title: json['title'] ?? '',
      status: json['status'] ?? 'Good',
      value: json['value'] ?? '',
      impact: json['impact'] ?? 'Medium',
      scorePercent: (json['score_percent'] as num?)?.toDouble() ?? 0.8,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'status': status,
    'value': value,
    'impact': impact,
    'score_percent': scorePercent,
  };
}

class CibilScoreModel {
  final int score;
  final String rating; // 'Excellent', 'Good', 'Fair', 'Poor'
  final String lastUpdated;
  final String nextRefreshDate;
  final String reportId;
  final List<CibilFactorModel> factors;
  final List<String> tips;

  const CibilScoreModel({
    required this.score,
    required this.rating,
    required this.lastUpdated,
    required this.nextRefreshDate,
    required this.reportId,
    required this.factors,
    required this.tips,
  });

  factory CibilScoreModel.fromJson(Map<String, dynamic> json) {
    return CibilScoreModel(
      score: json['score'] ?? 750,
      rating: json['rating'] ?? 'Excellent',
      lastUpdated: json['last_updated'] ?? '',
      nextRefreshDate: json['next_refresh_date'] ?? '',
      reportId: json['report_id'] ?? 'CIBIL-2026-9982',
      factors: (json['factors'] as List<dynamic>?)
              ?.map((e) => CibilFactorModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tips: (json['tips'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'score': score,
    'rating': rating,
    'last_updated': lastUpdated,
    'next_refresh_date': nextRefreshDate,
    'report_id': reportId,
    'factors': factors.map((e) => e.toJson()).toList(),
    'tips': tips,
  };
}
