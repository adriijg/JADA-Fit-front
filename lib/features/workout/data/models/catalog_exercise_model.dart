class CatalogExerciseModel {
  final int id;
  final String name;
  final String description;
  final String benefits;
  final String? videoUrl;

  CatalogExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.benefits,
    this.videoUrl,
  });

  factory CatalogExerciseModel.fromJson(Map<String, dynamic> json) {
    return CatalogExerciseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'benefits': benefits,
      'videoUrl': videoUrl,
    };
  }
}
