enum RoutineGoal {
  fuerza,
  volumen,
  resistencia,
  definicion;

  String get displayName {
    switch (this) {
      case RoutineGoal.fuerza:
        return 'FUERZA';
      case RoutineGoal.volumen:
        return 'VOLUMEN';
      case RoutineGoal.resistencia:
        return 'RESISTENCIA';
      case RoutineGoal.definicion:
        return 'DEFINICIÓN';
    }
  }

  String get description {
    switch (this) {
      case RoutineGoal.fuerza:
        return 'Maximizar tu fuerza con cargas altas y bajas repeticiones';
      case RoutineGoal.volumen:
        return 'Aumentar masa muscular con volumen de entrenamiento';
      case RoutineGoal.resistencia:
        return 'Mejorar tu resistencia y condición física';
      case RoutineGoal.definicion:
        return 'Definir y tonificar, quemar grasa manteniendo músculo';
    }
  }

  String get repRange {
    switch (this) {
      case RoutineGoal.fuerza:
        return '1-6 reps';
      case RoutineGoal.volumen:
        return '8-12 reps';
      case RoutineGoal.resistencia:
        return '15-20 reps';
      case RoutineGoal.definicion:
        return '12-15 reps';
    }
  }

  String get suggestedSets {
    switch (this) {
      case RoutineGoal.fuerza:
        return '4-6';
      case RoutineGoal.volumen:
        return '3-4';
      case RoutineGoal.resistencia:
        return '3-4';
      case RoutineGoal.definicion:
        return '3-4';
    }
  }

  String get iconPath {
    switch (this) {
      case RoutineGoal.fuerza:
        return 'assets/icons/fuerza.png';
      case RoutineGoal.volumen:
        return 'assets/icons/volumen.png';
      case RoutineGoal.resistencia:
        return 'assets/icons/resistencia.png';
      case RoutineGoal.definicion:
        return 'assets/icons/definicion.png';
    }
  }

  static RoutineGoal? fromString(String? value) {
    if (value == null) return null;
    for (final goal in RoutineGoal.values) {
      if (goal.displayName == value.toUpperCase()) return goal;
    }
    return null;
  }
}
