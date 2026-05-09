class Routine {
  final int? id;
  final String name;
  final String description;
  final String targetGoal;

  Routine({
    this.id,
    required this.name,
    required this.description,
    required this.targetGoal,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      targetGoal: json['targetGoal'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'targetGoal': targetGoal,
  };
}
