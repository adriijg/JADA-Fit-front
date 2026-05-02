class ProfileModel {
  const ProfileModel({
    required this.name,
    required this.email,
    this.weight,
    this.height,
    this.age,
    this.gender,
    this.goal,
    this.bodyFat,
    this.muscleMass,
  });

  final String name;
  final String email;
  final double? weight;
  final int? height;
  final int? age;
  final String? gender;
  final String? goal;
  final double? bodyFat;
  final double? muscleMass;

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: json['username'] as String,
      email: json['email'] as String,
    );
  }
}
