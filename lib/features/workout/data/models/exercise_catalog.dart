import 'routine_goal.dart';
import 'routine_split.dart';

class CatalogExercise {
  final String name;
  final String description;
  final String muscleGroup;
  final List<RoutineGoal> goals;
  final bool requiresEquipment;
  final String? equipment;

  const CatalogExercise({
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.goals,
    this.requiresEquipment = true,
    this.equipment,
  });

  bool get isBodyweight => !requiresEquipment;
}

class ExerciseSuggestion {
  final String name;
  final int suggestedSets;
  final int suggestedReps;
  final int? durationSeconds;

  const ExerciseSuggestion({
    required this.name,
    required this.suggestedSets,
    required this.suggestedReps,
    this.durationSeconds,
  });
}

class ExerciseCatalog {
  static const List<CatalogExercise> all = [
    // ─── PECHO ───
    CatalogExercise(
      name: 'Press de banca con barra',
      description: 'Acostado en banco plano, baja la barra al pecho y empuja hacia arriba',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press de banca inclinado con barra',
      description: 'En banco a 30-45°, enfatiza la parte superior del pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press de banca declinado',
      description: 'En banco declinado, enfatiza la parte inferior del pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press con mancuernas en banco plano',
      description: 'Similar al press con barra pero con mayor rango de movimiento',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Press inclinado con mancuernas',
      description: 'En banco inclinado, excelente para desarrollar la parte superior del pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Aperturas con mancuernas en banco plano',
      description: 'Brazos abiertos en cruz, baja las mancuernas sintiendo el estiramiento',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Aperturas en máquina Peck Deck',
      description: 'Sentado, junta los brazos frente al pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Cruce de cables en polea alta',
      description: 'De pie, cruza los cables hacia abajo y al frente',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Cruce de cables en polea baja',
      description: 'De pie, cruza los cables hacia arriba y al frente',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Flexiones de brazos (push-ups)',
      description: 'Ejercicio clásico de peso corporal para pecho, hombros y tríceps',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Flexiones inclinadas',
      description: 'Con manos elevadas en un banco, menor dificultad que flexiones normales',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Flexiones declinadas',
      description: 'Con pies elevados, mayor énfasis en la parte superior del pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion, RoutineGoal.fuerza],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Flexiones diamante',
      description: 'Manos juntas formando un diamante, enfatiza tríceps y pecho interno',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Fondos en paralelas',
      description: 'Sujétate en las paralelas y baja el cuerpo, excelente para pecho inferior',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press en máquina',
      description: 'Press de pecho sentado en máquina guiada, ideal para principiantes',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Pullover con mancuerna',
      description: 'Acostado en banco, lleva la mancuerna desde detrás de la cabeza hasta arriba del pecho',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Flexiones con palmada',
      description: 'Flexión explosiva dando una palmada en el aire, ejercicio pliométrico',
      muscleGroup: 'Pecho',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),

    // ─── ESPALDA ───
    CatalogExercise(
      name: 'Dominadas (pull-ups)',
      description: 'Cuelga de una barra y sube hasta que la barbilla la sobrepase',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Dominadas supinas (chin-ups)',
      description: 'Como dominadas pero con agarre supino (palmas hacia ti), más énfasis en bíceps',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Remo con barra',
      description: 'Inclinado con barra, lleva el peso al abdomen',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Remo con mancuerna a una mano',
      description: 'Apoyado en un banco, rema la mancuerna hacia la cadera',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Jalón al pecho en polea',
      description: 'Sentado en la máquina, baja la barra al pecho',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Jalón al pecho agarre estrecho',
      description: 'Con agarre estrecho en V, enfatiza la espalda media',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Remo en máquina',
      description: 'Sentado en la máquina de remo, tira del peso hacia el pecho',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Remo en polea baja',
      description: 'Sentado, tira del agarre hacia el abdomen manteniendo la espalda recta',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Peso muerto',
      description: 'Desde el suelo, levanta la barra extendiendo caderas y rodillas',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Peso muerto rumano',
      description: 'Con piernas casi rectas, baja la barra deslizándola por las piernas',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Hiperextensiones (lumbares)',
      description: 'En banco romano, baja el torso y sube contrayendo la espalda baja',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Encogimientos con barra (shrugs)',
      description: 'De pie con barra, encoge los hombros hacia arriba',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Encogimientos con mancuernas',
      description: 'Como los shrugs con barra pero con mancuernas a los lados',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Remo invertido (australian pull-ups)',
      description: 'Bajo una barra a la altura de la cadera, rema el cuerpo hacia arriba',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Superman',
      description: 'Acostado boca abajo, eleva brazos y piernas simultáneamente',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Pull-ups con agarre neutro',
      description: 'Dominadas con palmas enfrentadas, menor tensión en hombros',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Face pull en polea',
      description: 'De pie, tira de la polea hacia la cara, excelente para postura',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Remo con barra T',
      description: 'Apoyado en la máquina de barra T, rema el peso hacia el pecho',
      muscleGroup: 'Espalda',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),

    // ─── HOMBROS ───
    CatalogExercise(
      name: 'Press militar con barra',
      description: 'De pie o sentado, presiona la barra desde los hombros hacia arriba',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press con mancuernas sentado',
      description: 'Sentado, presiona las mancuernas hacia arriba desde los hombros',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Elevaciones laterales con mancuernas',
      description: 'De pie, eleva las mancuernas a los lados hasta la altura de los hombros',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Elevaciones frontales con mancuernas',
      description: 'De pie, eleva las mancuernas al frente hasta la altura de los hombros',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Elevaciones laterales en polea',
      description: 'De pie junto a la polea, eleva el brazo hacia el lado',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Pájaro (face down fly)',
      description: 'Inclinado hacia adelante, eleva los brazos en cruz, trabaja el deltoides posterior',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Press Arnold',
      description: 'Con mancuernas, rota las palmas mientras presionas hacia arriba',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Paseos frontales con barra (frontal raises)',
      description: 'De pie, eleva la barra al frente hasta la altura de los hombros',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Clean and press',
      description: 'Movimiento explosivo: lleva la barra al pecho y presiona arriba',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Press en máquina de hombros',
      description: 'Press de hombros sentado en máquina guiada',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Círculos con los brazos',
      description: 'De pie, haz círculos amplios con los brazos, ideal para calentamiento',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Pike push-ups',
      description: 'En posición de perro boca abajo, flexiona los brazos hacia el suelo',
      muscleGroup: 'Hombros',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),

    // ─── BRAZOS - BÍCEPS ───
    CatalogExercise(
      name: 'Curl con barra recta',
      description: 'De pie, curl con barra recta, trabaja el bíceps braquial',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Curl con barra Z',
      description: 'Como el curl con barra pero con barra Z, menor tensión en muñecas',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Curl con mancuernas alternado',
      description: 'De pie o sentado, curl alternando los brazos',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Curl martillo con mancuernas',
      description: 'Como curl pero con palmas enfrentadas, trabaja también el braquial',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Curl concentrado',
      description: 'Sentado con el codo apoyado en el muslo, curl concentrado',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Curl en polea baja',
      description: 'De pie frente a la polea, curl con agarre de cuerda o barra',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Curl en banco predicador',
      description: 'En banco predicador, curl con barra Z, aisla el bíceps',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Curl invertido con barra',
      description: 'Con agarre prono, curl de barra, trabaja el braquial y antebrazo',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Curl con cable a una mano',
      description: 'De pie junto a la polea, curl a una mano con agarre de D',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Flexiones de brazos estrechas',
      description: 'Manos juntas, enfatiza tríceps y pecho interno',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Dominadas supinas (chin-ups)',
      description: 'Excelente ejercicio compuesto que trabaja bíceps y espalda',
      muscleGroup: 'Bíceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),

    // ─── BRAZOS - TRÍCEPS ───
    CatalogExercise(
      name: 'Fondos en paralelas',
      description: 'En paralelas, baja el cuerpo y extiende los brazos, enfatiza tríceps',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Extensión de tríceps en polea',
      description: 'De pie en la polea alta, extiende los brazos hacia abajo',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Extensión de tríceps con cuerda',
      description: 'Como la extensión en polea pero con cuerda, mayor rango de movimiento',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.definicion, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Press francés con barra Z',
      description: 'Acostado, extiende la barra desde detrás de la cabeza',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.volumen, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Press francés con mancuernas',
      description: 'Acostado, extiende las mancuernas desde detrás de la cabeza',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Patada de tríceps con mancuerna',
      description: 'Inclinado, extiende el brazo hacia atrás con mancuerna',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.definicion, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Fondos en banco (tríceps)',
      description: 'Con manos en un banco y pies en el suelo, baja el cuerpo',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion, RoutineGoal.volumen],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Extensión de tríceps por encima de la cabeza',
      description: 'Sentado, extiende la mancuerna por encima de la cabeza',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Flexiones diamante',
      description: 'Manos juntas formando un diamante, excelente para tríceps',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Press de banca agarre cerrado',
      description: 'Press de banca con manos juntas, enfatiza tríceps',
      muscleGroup: 'Tríceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),

    // ─── PIERNAS - CUÁDRICEPS ───
    CatalogExercise(
      name: 'Sentadilla con barra (back squat)',
      description: 'Barra en la espalda, flexiona rodillas y cadera hasta paralela',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Sentadilla frontal (front squat)',
      description: 'Barra al frente del pecho, más énfasis en cuádriceps',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Sentadilla goblet',
      description: 'Con mancuerna o pesa rusa al pecho, ideal para principiantes',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Sentadilla búlgara',
      description: 'Un pie elevado detrás en un banco, sentadilla a una pierna',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Prensa de piernas (leg press)',
      description: 'En la máquina de prensa, empuja el peso extendiendo las piernas',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Extensión de cuádriceps en máquina',
      description: 'Sentado en la máquina, extiende las piernas',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Zancadas con mancuernas',
      description: 'Da un paso al frente y flexiona ambas piernas',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Zancadas laterales',
      description: 'Da un paso lateral, flexiona la pierna y mantén la otra extendida',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Zancadas inversas',
      description: 'Da un paso hacia atrás, menor tensión en la rodilla',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Sentadilla con salto',
      description: 'Sentadilla explosiva saltando al subir, ejercicio pliométrico',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Sentadilla isométrica (wall sit)',
      description: 'Apoyado en la pared, mantén la posición de sentadilla',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Step-ups con mancuernas',
      description: 'Sube a un banco con mancuernas, alternando piernas',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Sentadilla con pausa',
      description: 'Sentadilla normal con pausa de 2-3 segundos en la parte baja',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Sentadilla copa (goblet squat)',
      description: 'Con una mancuerna o kettlebell sostenida contra el pecho',
      muscleGroup: 'Cuádriceps',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.resistencia],
    ),

    // ─── PIERNAS - ISQUIOTIBIALES / GLÚTEOS ───
    CatalogExercise(
      name: 'Peso muerto',
      description: 'Desde el suelo, levanta la barra extendiendo caderas y rodillas',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Peso muerto rumano',
      description: 'Con piernas casi rectas, baja la barra deslizándola por las piernas',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Hip thrust con barra',
      description: 'Apoyado en un banco, eleva la cadera con la barra sobre ella',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Hip thrust a una pierna',
      description: 'Hip thrust con una pierna elevada, mayor activación',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Curl de piernas en máquina (leg curl)',
      description: 'Acostado boca abajo en la máquina, flexiona las piernas',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Curl de piernas sentado',
      description: 'Sentado en la máquina, flexiona las piernas contra resistencia',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Puente de glúteos',
      description: 'Acostado boca arriba, eleva la cadera hacia arriba',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Puente de glúteos a una pierna',
      description: 'Puente con una pierna elevada, mayor dificultad',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Patada de glúteo en polea',
      description: 'De pie frente a la polea, extiende la pierna hacia atrás',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Abducción de cadera en máquina',
      description: 'Sentado en la máquina, abre las piernas hacia los lados',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Peso muerto a una pierna con mancuerna',
      description: 'Inclinado hacia adelante con una pierna atrás, mejora el equilibrio',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.definicion, RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Sentadilla sumo',
      description: 'Con piernas abiertas y puntas hacia afuera, énfasis en glúteos',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Good mornings',
      description: 'Con barra en la espalda, inclina el torso hacia adelante',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.fuerza],
    ),
    CatalogExercise(
      name: 'Caminata lateral con banda',
      description: 'Con banda elástica en los tobillos, camina lateralmente',
      muscleGroup: 'Glúteos',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
    ),

    // ─── ABDOMEN ───
    CatalogExercise(
      name: 'Crunch abdominal',
      description: 'Acostado, eleva el torso contrayendo el abdomen',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Plancha abdominal',
      description: 'En posición de plancha, mantén el cuerpo recto el máximo tiempo',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Plancha lateral',
      description: 'De lado, mantén el cuerpo recto apoyado en un brazo',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Elevación de piernas',
      description: 'Acostado o colgado, eleva las piernas rectas',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Elevación de rodillas colgado',
      description: 'Colgado de una barra, eleva las rodillas al pecho',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Russian twists',
      description: 'Sentado con pies elevados, rota el torso de lado a lado',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Bicicleta abdominal',
      description: 'Acostado, lleva codo a rodilla contraria alternando',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Crunch en máquina',
      description: 'Sentado en la máquina de abdominales, flexiona el torso',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.volumen, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Mountain climbers',
      description: 'En plancha, lleva las rodillas al pecho alternando rápido',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Dead bug',
      description: 'Acostado, extiende brazo y pierna contrarios alternando',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'V-ups',
      description: 'Acostado, eleva brazos y piernas simultáneamente formando una V',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.definicion, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Flexiones de cadera en máquina',
      description: 'En máquina de flexión de cadera, trabaja el abdomen inferior',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.volumen, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Plancha con toque de hombro',
      description: 'En plancha, toca el hombro contrario alternando',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Ab wheel (rueda abdominal)',
      description: 'De rodillas, extiende el cuerpo con la rueda y vuelve',
      muscleGroup: 'Abdomen',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),

    // ─── CARDIO / CUERPO COMPLETO ───
    CatalogExercise(
      name: 'Burpees',
      description: 'Desde de pie, baja a plancha, salta y repite, ejercicio completo',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Saltos de tijera (jumping jacks)',
      description: 'Salta abriendo piernas y brazos, vuelve y repite',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Cuerda a saltar (skipping)',
      description: 'Salta la cuerda a ritmo constante',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'High knees',
      description: 'Corre en el sitio elevando las rodillas al pecho',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Box jumps',
      description: 'Salta sobre un cajón o plataforma estable',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Kettlebell swings',
      description: 'Con pesa rusa, balancea entre las piernas y hacia arriba',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Battle ropes',
      description: 'Con cuerdas gruesas, haz ondas continuas en el suelo',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia, RoutineGoal.definicion],
    ),
    CatalogExercise(
      name: 'Sled push',
      description: 'Empuja un trineo con peso hacia adelante',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Escalador (versión mountain climber lenta)',
      description: 'En plancha, lleva las rodillas al pecho controladamente',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
    CatalogExercise(
      name: 'Saltos en cuclillas',
      description: 'Sentadilla seguida de un salto vertical explosivo',
      muscleGroup: 'Cardio',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
      requiresEquipment: false,
    ),

    // ─── ANTEBRAZOS ───
    CatalogExercise(
      name: 'Curl de muñeca con barra',
      description: 'Antebrazos apoyados, flexiona la muñeca hacia arriba',
      muscleGroup: 'Antebrazos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Curl de muñeca invertido',
      description: 'Antebrazos apoyados, extiende la muñeca hacia arriba',
      muscleGroup: 'Antebrazos',
      goals: [RoutineGoal.fuerza, RoutineGoal.volumen],
    ),
    CatalogExercise(
      name: 'Colgada en barra (dead hang)',
      description: 'Cuélgate de una barra el máximo tiempo posible',
      muscleGroup: 'Antebrazos',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Caminata del granjero (farmer walk)',
      description: 'Camina sujetando mancuernas o pesas pesadas a los lados',
      muscleGroup: 'Antebrazos',
      goals: [RoutineGoal.fuerza, RoutineGoal.resistencia],
    ),
    CatalogExercise(
      name: 'Apretón con pelota de tenis',
      description: 'Aprieta una pelota de tenis repetidamente',
      muscleGroup: 'Antebrazos',
      goals: [RoutineGoal.resistencia],
      requiresEquipment: false,
    ),
  ];

  static List<CatalogExercise> byGoal(RoutineGoal goal) {
    return all.where((e) => e.goals.contains(goal)).toList();
  }

  static List<CatalogExercise> byMuscleGroup(String muscleGroup) {
    return all.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  static List<String> get muscleGroups {
    return all.map((e) => e.muscleGroup).toSet().toList();
  }

  static List<CatalogExercise> bySplit(RoutineSplit split) {
    final groups = split.muscleGroups;
    return all.where((e) => groups.contains(e.muscleGroup)).toList();
  }

  static List<CatalogExercise> bodyweight() {
    return all.where((e) => !e.requiresEquipment).toList();
  }

  static List<ExerciseSuggestion> suggestionsForGoal(RoutineGoal goal) {
    return suggestionsForGoalAndSplit(goal, null);
  }

  static List<ExerciseSuggestion> suggestionsForGoalAndSplit(RoutineGoal goal, RoutineSplit? split) {
    if (split != null) {
      final matching = bySplit(split).where((e) => e.goals.contains(goal)).toList();
      final reps = _repsForGoal(goal);
      final sets = _setsForGoal(goal);
      return matching.map((e) => ExerciseSuggestion(
        name: e.name,
        suggestedSets: sets,
        suggestedReps: reps,
      )).toList();
    }

    switch (goal) {
      case RoutineGoal.fuerza:
        return [
          const ExerciseSuggestion(name: 'Sentadilla con barra', suggestedSets: 5, suggestedReps: 5),
          const ExerciseSuggestion(name: 'Press de banca con barra', suggestedSets: 5, suggestedReps: 5),
          const ExerciseSuggestion(name: 'Peso muerto', suggestedSets: 5, suggestedReps: 5),
          const ExerciseSuggestion(name: 'Press militar con barra', suggestedSets: 4, suggestedReps: 6),
          const ExerciseSuggestion(name: 'Remo con barra', suggestedSets: 4, suggestedReps: 6),
          const ExerciseSuggestion(name: 'Dominadas', suggestedSets: 4, suggestedReps: 6),
          const ExerciseSuggestion(name: 'Hip thrust con barra', suggestedSets: 4, suggestedReps: 8),
          const ExerciseSuggestion(name: 'Fondos en paralelas', suggestedSets: 4, suggestedReps: 6),
        ];

      case RoutineGoal.volumen:
        return [
          const ExerciseSuggestion(name: 'Press de banca con barra', suggestedSets: 4, suggestedReps: 10),
          const ExerciseSuggestion(name: 'Press inclinado con mancuernas', suggestedSets: 4, suggestedReps: 10),
          const ExerciseSuggestion(name: 'Remo con barra', suggestedSets: 4, suggestedReps: 10),
          const ExerciseSuggestion(name: 'Jalón al pecho en polea', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Sentadilla con barra', suggestedSets: 4, suggestedReps: 10),
          const ExerciseSuggestion(name: 'Prensa de piernas', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Curl con barra Z', suggestedSets: 3, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Extensión de tríceps en polea', suggestedSets: 3, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Elevaciones laterales', suggestedSets: 3, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Hip thrust con barra', suggestedSets: 4, suggestedReps: 12),
        ];

      case RoutineGoal.resistencia:
        return [
          const ExerciseSuggestion(name: 'Sentadilla con salto', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Flexiones de brazos', suggestedSets: 3, suggestedReps: 20),
          const ExerciseSuggestion(name: 'Dominadas', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Zancadas inversas', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Curl de piernas en máquina', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Plancha abdominal', suggestedSets: 3, suggestedReps: 0, durationSeconds: 45),
          const ExerciseSuggestion(name: 'Mountain climbers', suggestedSets: 3, suggestedReps: 20),
          const ExerciseSuggestion(name: 'Burpees', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Saltos de tijera', suggestedSets: 3, suggestedReps: 30),
          const ExerciseSuggestion(name: 'Cuerda a saltar', suggestedSets: 3, suggestedReps: 0, durationSeconds: 60),
        ];

      case RoutineGoal.definicion:
        return [
          const ExerciseSuggestion(name: 'Press con mancuernas', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Aperturas con mancuernas', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Remo con mancuerna a una mano', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Jalón al pecho agarre estrecho', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Sentadilla búlgara', suggestedSets: 3, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Peso muerto rumano', suggestedSets: 4, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Elevaciones laterales', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Curl martillo', suggestedSets: 3, suggestedReps: 12),
          const ExerciseSuggestion(name: 'Extensión de tríceps con cuerda', suggestedSets: 3, suggestedReps: 15),
          const ExerciseSuggestion(name: 'Russian twists', suggestedSets: 3, suggestedReps: 20),
          const ExerciseSuggestion(name: 'Bicicleta abdominal', suggestedSets: 3, suggestedReps: 20),
          const ExerciseSuggestion(name: 'Cruce de cables en polea alta', suggestedSets: 3, suggestedReps: 15),
        ];
    }
  }

  static int _repsForGoal(RoutineGoal goal) {
    switch (goal) {
      case RoutineGoal.fuerza: return 6;
      case RoutineGoal.volumen: return 10;
      case RoutineGoal.resistencia: return 15;
      case RoutineGoal.definicion: return 12;
    }
  }

  static int _setsForGoal(RoutineGoal goal) {
    switch (goal) {
      case RoutineGoal.fuerza: return 4;
      case RoutineGoal.volumen: return 4;
      case RoutineGoal.resistencia: return 3;
      case RoutineGoal.definicion: return 3;
    }
  }
}
