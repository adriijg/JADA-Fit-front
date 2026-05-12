class CatalogFoodModel {
  const CatalogFoodModel({
    required this.id,
    required this.name,
    required this.source,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.ownerUserId,
    this.externalFoodId,
    this.barcode,
    this.brand,
  });

  final String? id;
  final String? ownerUserId;
  final String? externalFoodId;
  final String? barcode;
  final String name;
  final String? brand;
  final String source;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;

  factory CatalogFoodModel.fromJson(Map<String, dynamic> json) {
    return CatalogFoodModel(
      id: json['id'] as String?,
      ownerUserId: json['ownerUserId'] as String?,
      externalFoodId: json['externalFoodId'] as String?,
      barcode: json['barcode'] as String?,
      name: json['name'] as String? ?? 'Alimento sin nombre',
      brand: json['brand'] as String?,
      source: json['source'] as String? ?? 'UNKNOWN',
      caloriesPer100g: _toDouble(json['caloriesPer100g']),
      proteinPer100g: _toDouble(json['proteinPer100g']),
      carbsPer100g: _toDouble(json['carbsPer100g']),
      fatsPer100g: _toDouble(json['fatsPer100g']),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value.toDouble();

    if (value is double) return value;

    if (value is num) return value.toDouble();

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
