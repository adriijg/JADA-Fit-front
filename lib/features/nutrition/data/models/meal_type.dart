enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

extension MealTypeExtension on MealType {
  String get apiValue {
    switch (this) {
      case MealType.breakfast:
        return 'DESAYUNO';
      case MealType.lunch:
        return 'COMIDA';
      case MealType.dinner:
        return 'CENA';
      case MealType.snack:
        return 'SNACK';
    }
  }

  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Desayuno';
      case MealType.lunch:
        return 'Comida';
      case MealType.dinner:
        return 'Cena';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get pluralLabel {
    switch (this) {
      case MealType.breakfast:
        return 'Desayunos';
      case MealType.lunch:
        return 'Comidas';
      case MealType.dinner:
        return 'Cenas';
      case MealType.snack:
        return 'Snacks';
    }
  }

  static MealType fromApiValue(String value) {
    switch (value.trim().toUpperCase()) {
      case 'DESAYUNO':
        return MealType.breakfast;
      case 'COMIDA':
        return MealType.lunch;
      case 'CENA':
        return MealType.dinner;
      case 'SNACK':
        return MealType.snack;
      default:
        return MealType.snack;
    }
  }
}
