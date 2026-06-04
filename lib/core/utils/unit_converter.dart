class UnitConverter {
  static double kgToLbs(double kg) => kg * 2.20462;
  static double lbsToKg(double lbs) => lbs / 2.20462;

  static double cmToFeet(double cm) => cm / 30.48;
  static double feetToCm(double feet) => feet * 30.48;

  static String formatWeight(double? kg, bool imperial) {
    if (kg == null) return '—';
    if (imperial) {
      final lbs = kgToLbs(kg);
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  static String formatHeight(int? cm, bool imperial) {
    if (cm == null) return '—';
    if (imperial) {
      final totalFeet = cmToFeet(cm.toDouble());
      final feet = totalFeet.floor();
      final inches = ((totalFeet - feet) * 12).round();
      return "$feet'$inches\"";
    }
    return '$cm cm';
  }

  static String formatMuscleMass(double? kg, bool imperial) {
    if (kg == null) return '—';
    if (imperial) {
      final lbs = kgToLbs(kg);
      return '${lbs.toStringAsFixed(1)} lbs';
    }
    return '${kg.toStringAsFixed(1)} kg';
  }

  static String formatBodyFat(double? percent) {
    if (percent == null) return '—';
    return '${percent.toStringAsFixed(1)}%';
  }

  static String formatWeightOnly(double? kg, bool imperial) {
    if (kg == null) return '—';
    if (imperial) return kgToLbs(kg).toStringAsFixed(1);
    return kg.toStringAsFixed(1);
  }

  static String formatWeightChange(double? kg, bool imperial) {
    if (kg == null) return '—';
    final prefix = kg >= 0 ? '+' : '';
    if (imperial) return '$prefix${kgToLbs(kg).toStringAsFixed(1)} lbs';
    return '$prefix${kg.toStringAsFixed(1)} kg';
  }

  static num inputToMetric(num value, bool isWeight, bool imperial) {
    if (!imperial) return value;
    if (isWeight) return lbsToKg(value.toDouble());
    return feetToCm(value.toDouble());
  }
}
