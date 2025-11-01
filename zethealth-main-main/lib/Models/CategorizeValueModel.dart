class CategorizeValueResponse {
  final Map<String, dynamic>? cohorts;
  final Map<String, dynamic>? counts;
  final int? latestCompositeScore;
  final String? status;
  final String? userId;
  final String? healthSummary;
  final List<String>? personalizedRecommendations;

  CategorizeValueResponse({
    this.cohorts,
    this.counts,
    this.latestCompositeScore,
    this.status,
    this.userId,
    this.healthSummary,
    this.personalizedRecommendations,
  });

  factory CategorizeValueResponse.fromJson(Map<String, dynamic> json) {
    return CategorizeValueResponse(
      cohorts: json['cohorts'] != null
          ? Map<String, dynamic>.from(json['cohorts'])
          : null,
      counts: json['counts'] != null
          ? Map<String, dynamic>.from(json['counts'])
          : null,
      latestCompositeScore: json['latest_composite_score'],
      status: json['status'],
      userId: json['user_id'],
      healthSummary: json['health_summary'],
       personalizedRecommendations: json['personalized_recommendations'] != null
        ? List<String>.from(json['personalized_recommendations'])
        : null,
    );
  }
}

class Report {
  final int? id;
  final DateTime? createdAt;
  final Map<String, dynamic>? cohorts;
  final int? compositeScore;
  final String? healthSummary;
  final Map<String, dynamic>? patient;
  final int? score;
  final String? reportType;
  final String? reportStatus;
  final DateTime? updatedAt;

  Report({
    this.id,
    this.createdAt,
    this.cohorts,
    this.compositeScore,
    this.healthSummary,
    this.patient,
    this.score,
    this.reportType,
    this.reportStatus,
    this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      cohorts: json['cohorts'] != null
          ? Map<String, dynamic>.from(json['cohorts'])
          : null,
      compositeScore: json['composite_score'],
      healthSummary: json['health_summary'],
      patient: json['patient'] != null
          ? Map<String, dynamic>.from(json['patient'])
          : null,
      score: json['score'],
      reportType: json['report_type'],
      reportStatus: json['report_status'],
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}