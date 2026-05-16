class WaterLogModel {
  const WaterLogModel({
    required this.id,
    required this.amountMl,
    required this.loggedAt,
  });

  final String id;
  final double amountMl;
  final DateTime loggedAt;

  factory WaterLogModel.fromJson(Map<String, dynamic> json) {
    return WaterLogModel(
      id: json['id'] as String,
      amountMl: _toDouble(json['amountMl']),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class WaterDaySummaryModel {
  const WaterDaySummaryModel({
    required this.totalMl,
    required this.logs,
  });

  final double totalMl;
  final List<WaterLogModel> logs;

  factory WaterDaySummaryModel.fromJson(Map<String, dynamic> json) {
    return WaterDaySummaryModel(
      totalMl: _toDouble(json['totalMl']),
      logs: (json['logs'] as List<dynamic>)
          .map((e) => WaterLogModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
