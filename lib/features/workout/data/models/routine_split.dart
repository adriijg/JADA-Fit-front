enum RoutineSplit {
  fullBody,
  push,
  pull,
  legs,
  upper,
  lower;

  String get displayName {
    switch (this) {
      case RoutineSplit.fullBody:
        return 'Full Body';
      case RoutineSplit.push:
        return 'Empuje (Push)';
      case RoutineSplit.pull:
        return 'Tirón (Pull)';
      case RoutineSplit.legs:
        return 'Piernas';
      case RoutineSplit.upper:
        return 'Torso';
      case RoutineSplit.lower:
        return 'Lower Body';
    }
  }

  String get description {
    switch (this) {
      case RoutineSplit.fullBody:
        return 'Todo el cuerpo en una sesión';
      case RoutineSplit.push:
        return 'Pecho, hombros y tríceps';
      case RoutineSplit.pull:
        return 'Espalda, bíceps y antebrazos';
      case RoutineSplit.legs:
        return 'Cuádriceps, glúteos, isquiotibiales y gemelos';
      case RoutineSplit.upper:
        return 'Pecho, espalda, hombros y brazos';
      case RoutineSplit.lower:
        return 'Piernas y glúteos';
    }
  }

  List<String> get muscleGroups {
    switch (this) {
      case RoutineSplit.fullBody:
        return ['Pecho', 'Espalda', 'Hombros', 'Bíceps', 'Tríceps', 'Cuádriceps', 'Glúteos', 'Abdomen'];
      case RoutineSplit.push:
        return ['Pecho', 'Hombros', 'Tríceps'];
      case RoutineSplit.pull:
        return ['Espalda', 'Bíceps', 'Antebrazos'];
      case RoutineSplit.legs:
        return ['Cuádriceps', 'Glúteos', 'Abdomen'];
      case RoutineSplit.upper:
        return ['Pecho', 'Espalda', 'Hombros', 'Bíceps', 'Tríceps', 'Antebrazos'];
      case RoutineSplit.lower:
        return ['Cuádriceps', 'Glúteos', 'Abdomen'];
    }
  }

  static RoutineSplit? fromString(String? value) {
    if (value == null) return null;
    for (final split in RoutineSplit.values) {
      if (split.displayName == value) return split;
    }
    return null;
  }
}
