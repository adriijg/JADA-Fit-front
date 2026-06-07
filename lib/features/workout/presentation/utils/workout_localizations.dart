import 'package:flutter/material.dart';
import '../../data/models/routine_goal.dart';
import '../../data/models/routine_split.dart';
import '../../data/models/exercise_catalog.dart';
import '../../../../l10n/app_localizations.dart';

extension LocalizedRoutineGoal on RoutineGoal {
  String localizedDisplayName(AppLocalizations l10n) {
    switch (this) {
      case RoutineGoal.fuerza:
        return l10n.workoutStrength;
      case RoutineGoal.volumen:
        return l10n.workoutVolume;
      case RoutineGoal.resistencia:
        return l10n.workoutEndurance;
      case RoutineGoal.definicion:
        return l10n.workoutDefinition;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case RoutineGoal.fuerza:
        return l10n.workoutStrengthDesc;
      case RoutineGoal.volumen:
        return l10n.workoutVolumeDesc;
      case RoutineGoal.resistencia:
        return l10n.workoutEnduranceDesc;
      case RoutineGoal.definicion:
        return l10n.workoutDefinitionDesc;
    }
  }
}

extension LocalizedRoutineSplit on RoutineSplit {
  String localizedDisplayName(AppLocalizations l10n) {
    switch (this) {
      case RoutineSplit.fullBody:
        return l10n.workoutFullBody;
      case RoutineSplit.push:
        return l10n.workoutPush;
      case RoutineSplit.pull:
        return l10n.workoutPull;
      case RoutineSplit.legs:
        return l10n.workoutLegs;
      case RoutineSplit.upper:
        return l10n.workoutTorso;
      case RoutineSplit.lower:
        return l10n.workoutLowerBody;
    }
  }

  String localizedDescription(AppLocalizations l10n) {
    switch (this) {
      case RoutineSplit.fullBody:
        return l10n.workoutFullBodyDesc;
      case RoutineSplit.push:
        return l10n.workoutPushDesc;
      case RoutineSplit.pull:
        return l10n.workoutPullDesc;
      case RoutineSplit.legs:
        return l10n.workoutLegsDesc;
      case RoutineSplit.upper:
        return l10n.workoutTorsoDesc;
      case RoutineSplit.lower:
        return l10n.workoutLowerBodyDesc;
    }
  }
}

String localizedCatalogExerciseName(CatalogExercise exercise, BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return localizedEnglishExerciseName(exercise.name);
  }
  return exercise.name;
}

String localizedCatalogExerciseMuscleGroup(CatalogExercise exercise, BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return localizedMuscleGroupEn(exercise.muscleGroup) ?? exercise.muscleGroup;
  }
  return exercise.muscleGroup;
}

String localizedSuggestionName(ExerciseSuggestion suggestion, BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return localizedEnglishExerciseName(suggestion.name);
  }
  return suggestion.name;
}

String localizedEnglishExerciseName(String spanishName) {
  return _englishExerciseNames[spanishName] ?? spanishName;
}

String localizedCatalogExerciseDescription(CatalogExercise exercise, BuildContext context) {
  if (Localizations.localeOf(context).languageCode == 'en') {
    return localizedEnglishExerciseDescription(exercise.description) ?? exercise.description;
  }
  return exercise.description;
}

String? localizedEnglishExerciseDescription(String spanishDescription) {
  return _englishExerciseDescriptions[spanishDescription];
}

String? localizedMuscleGroupName(String spanishGroup, BuildContext context) {
  if (Localizations.localeOf(context).languageCode != 'en') return spanishGroup;
  return localizedMuscleGroupEn(spanishGroup) ?? spanishGroup;
}

String? localizedMuscleGroupEn(String spanishGroup) {
  const muscleGroupMap = <String, String>{
    'Pecho': 'Chest',
    'Espalda': 'Back',
    'Hombros': 'Shoulders',
    'Bíceps': 'Biceps',
    'Tríceps': 'Triceps',
    'Cuádriceps': 'Quadriceps',
    'Glúteos': 'Glutes',
    'Abdomen': 'Abs',
    'Cardio': 'Cardio',
    'Antebrazos': 'Forearms',
  };
  return muscleGroupMap[spanishGroup];
}

const Map<String, String> _englishExerciseDescriptions = {
  'Acostado en banco plano, baja la barra al pecho y empuja hacia arriba': 'Lie flat on a bench, lower the bar to your chest and push up',
  'En banco a 30-45°, enfatiza la parte superior del pecho': 'On a 30-45° incline bench, emphasizes the upper chest',
  'En banco declinado, enfatiza la parte inferior del pecho': 'On a decline bench, emphasizes the lower chest',
  'Similar al press con barra pero con mayor rango de movimiento': 'Similar to barbell press but with greater range of motion',
  'En banco inclinado, excelente para desarrollar la parte superior del pecho': 'On an incline bench, excellent for developing the upper chest',
  'Brazos abiertos en cruz, baja las mancuernas sintiendo el estiramiento': 'Arms open wide, lower the dumbbells feeling the stretch',
  'Sentado, junta los brazos frente al pecho': 'Seated, bring your arms together in front of your chest',
  'De pie, cruza los cables hacia abajo y al frente': 'Standing, cross the cables downward and forward',
  'De pie, cruza los cables hacia arriba y al frente': 'Standing, cross the cables upward and forward',
  'Ejercicio clásico de peso corporal para pecho, hombros y tríceps': 'Classic bodyweight exercise for chest, shoulders, and triceps',
  'Con manos elevadas en un banco, menor dificultad que flexiones normales': 'With hands elevated on a bench, easier than standard push-ups',
  'Con pies elevados, mayor énfasis en la parte superior del pecho': 'With feet elevated, more emphasis on the upper chest',
  'Manos juntas formando un diamante, enfatiza tríceps y pecho interno': 'Hands together forming a diamond, emphasizes triceps and inner chest',
  'Sujétate en las paralelas y baja el cuerpo, excelente para pecho inferior': 'Grab the parallel bars and lower your body, great for lower chest',
  'Press de pecho sentado en máquina guiada, ideal para principiantes': 'Seated chest press on a guided machine, ideal for beginners',
  'Acostado en banco, lleva la mancuerna desde detrás de la cabeza hasta arriba del pecho': 'Lying on a bench, bring the dumbbell from behind your head to above your chest',
  'Flexión explosiva dando una palmada en el aire, ejercicio pliométrico': 'Explosive push-up with a clap in the air, plyometric exercise',
  'Cuelga de una barra y sube hasta que la barbilla la sobrepase': 'Hang from a bar and pull up until your chin clears it',
  'Como dominadas pero con agarre supino (palmas hacia ti), más énfasis en bíceps': 'Like pull-ups but with palms facing you, more emphasis on biceps',
  'Inclinado con barra, lleva el peso al abdomen': 'Bent over with a barbell, pull the weight to your abdomen',
  'Apoyado en un banco, rema la mancuerna hacia la cadera': 'Supported on a bench, row the dumbbell toward your hip',
  'Sentado en la máquina, baja la barra al pecho': 'Seated at the machine, pull the bar down to your chest',
  'Con agarre estrecho en V, enfatiza la espalda media': 'With a narrow V-grip, emphasizes the mid back',
  'Sentado en la máquina de remo, tira del peso hacia el pecho': 'Seated at the row machine, pull the weight toward your chest',
  'Sentado, tira del agarre hacia el abdomen manteniendo la espalda recta': 'Seated, pull the handle toward your abdomen keeping your back straight',
  'Desde el suelo, levanta la barra extendiendo caderas y rodillas': 'From the floor, lift the bar by extending your hips and knees',
  'Con piernas casi rectas, baja la barra deslizándola por las piernas': 'With nearly straight legs, lower the bar sliding it along your legs',
  'En banco romano, baja el torso y sube contrayendo la espalda baja': 'On a Roman chair, lower your torso and raise it contracting your lower back',
  'De pie con barra, encoge los hombros hacia arriba': 'Standing with a barbell, shrug your shoulders upward',
  'Como los shrugs con barra pero con mancuernas a los lados': 'Like barbell shrugs but with dumbbells at your sides',
  'Bajo una barra a la altura de la cadera, rema el cuerpo hacia arriba': 'Under a bar at hip height, row your body upward',
  'Acostado boca abajo, eleva brazos y piernas simultáneamente': 'Lying face down, raise your arms and legs simultaneously',
  'Dominadas con palmas enfrentadas, menor tensión en hombros': 'Pull-ups with palms facing each other, less shoulder strain',
  'De pie, tira de la polea hacia la cara, excelente para postura': 'Standing, pull the cable toward your face, excellent for posture',
  'Apoyado en la máquina de barra T, rema el peso hacia el pecho': 'Supported on a T-bar machine, row the weight toward your chest',
  'De pie o sentado, presiona la barra desde los hombros hacia arriba': 'Standing or seated, press the bar from your shoulders upward',
  'Sentado, presiona las mancuernas hacia arriba desde los hombros': 'Seated, press the dumbbells upward from your shoulders',
  'De pie, eleva las mancuernas a los lados hasta la altura de los hombros': 'Standing, raise the dumbbells to your sides to shoulder height',
  'De pie, eleva las mancuernas al frente hasta la altura de los hombros': 'Standing, raise the dumbbells in front to shoulder height',
  'De pie junto a la polea, eleva el brazo hacia el lado': 'Standing next to the cable, raise your arm to the side',
  'Inclinado hacia adelante, eleva los brazos en cruz, trabaja el deltoides posterior': 'Bent forward, raise your arms out to the sides, works rear deltoids',
  'Con mancuernas, rota las palmas mientras presionas hacia arriba': 'With dumbbells, rotate your palms while pressing upward',
  'De pie, eleva la barra al frente hasta la altura de los hombros': 'Standing, raise the bar in front to shoulder height',
  'Movimiento explosivo: lleva la barra al pecho y presiona arriba': 'Explosive movement: bring the bar to your chest and press overhead',
  'Press de hombros sentado en máquina guiada': 'Seated shoulder press on a guided machine',
  'De pie, haz círculos amplios con los brazos, ideal para calentamiento': 'Standing, make wide circles with your arms, ideal for warming up',
  'En posición de perro boca abajo, flexiona los brazos hacia el suelo': 'In a downward dog position, bend your arms toward the floor',
  'De pie, curl con barra recta, trabaja el bíceps braquial': 'Standing, curl a straight bar, works the biceps brachii',
  'Como el curl con barra pero con barra Z, menor tensión en muñecas': 'Like a barbell curl but with an EZ bar, less wrist strain',
  'De pie o sentado, curl alternando los brazos': 'Standing or seated, curl alternating arms',
  'Como curl pero con palmas enfrentadas, trabaja también el braquial': 'Like a curl but with palms facing each other, also works the brachialis',
  'Sentado con el codo apoyado en el muslo, curl concentrado': 'Seated with elbow resting on your thigh, concentration curl',
  'De pie frente a la polea, curl con agarre de cuerda o barra': 'Standing facing the cable, curl with a rope or bar attachment',
  'En banco predicador, curl con barra Z, aisla el bíceps': 'On a preacher bench, curl an EZ bar, isolates the biceps',
  'Con agarre prono, curl de barra, trabaja el braquial y antebrazo': 'With an overhand grip, barbell curl, works the brachialis and forearm',
  'De pie junto a la polea, curl a una mano con agarre de D': 'Standing next to the cable, one-arm curl with a D-handle',
  'Manos juntas, enfatiza tríceps y pecho interno': 'Hands together, emphasizes triceps and inner chest',
  'Excelente ejercicio compuesto que trabaja bíceps y espalda': 'Excellent compound exercise that works biceps and back',
  'En paralelas, baja el cuerpo y extiende los brazos, enfatiza tríceps': 'On parallel bars, lower your body and extend your arms, emphasizes triceps',
  'De pie en la polea alta, extiende los brazos hacia abajo': 'Standing at the high cable, extend your arms downward',
  'Como la extensión en polea pero con cuerda, mayor rango de movimiento': 'Like the cable extension but with a rope, greater range of motion',
  'Acostado, extiende la barra desde detrás de la cabeza': 'Lying down, extend the bar from behind your head',
  'Acostado, extiende las mancuernas desde detrás de la cabeza': 'Lying down, extend the dumbbells from behind your head',
  'Inclinado, extiende el brazo hacia atrás con mancuerna': 'Bent over, extend your arm backward with a dumbbell',
  'Con manos en un banco y pies en el suelo, baja el cuerpo': 'With hands on a bench and feet on the floor, lower your body',
  'Sentado, extiende la mancuerna por encima de la cabeza': 'Seated, extend the dumbbell overhead',
  'Manos juntas formando un diamante, excelente para tríceps': 'Hands together forming a diamond, excellent for triceps',
  'Press de banca con manos juntas, enfatiza tríceps': 'Bench press with hands close together, emphasizes triceps',
  'Barra en la espalda, flexiona rodillas y cadera hasta paralela': 'Bar on your back, bend knees and hips until parallel',
  'Barra al frente del pecho, más énfasis en cuádriceps': 'Bar in front of your chest, more emphasis on quadriceps',
  'Con mancuerna o pesa rusa al pecho, ideal para principiantes': 'With a dumbbell or kettlebell at your chest, ideal for beginners',
  'Un pie elevado detrás en un banco, sentadilla a una pierna': 'One foot elevated behind on a bench, single-leg squat',
  'En la máquina de prensa, empuja el peso extendiendo las piernas': 'On the leg press machine, push the weight by extending your legs',
  'Sentado en la máquina, extiende las piernas': 'Seated on the machine, extend your legs',
  'Da un paso al frente y flexiona ambas piernas': 'Take a step forward and bend both legs',
  'Da un paso lateral, flexiona la pierna y mantén la otra extendida': 'Take a lateral step, bend one leg and keep the other straight',
  'Da un paso hacia atrás, menor tensión en la rodilla': 'Take a step backward, less stress on the knee',
  'Sentadilla explosiva saltando al subir, ejercicio pliométrico': 'Explosive squat jumping up, plyometric exercise',
  'Apoyado en la pared, mantén la posición de sentadilla': 'Leaning against a wall, hold the squat position',
  'Sube a un banco con mancuernas, alternando piernas': 'Step onto a bench with dumbbells, alternating legs',
  'Sentadilla normal con pausa de 2-3 segundos en la parte baja': 'Regular squat with a 2-3 second pause at the bottom',
  'Con una mancuerna o kettlebell sostenida contra el pecho': 'With a dumbbell or kettlebell held against your chest',
  'Apoyado en un banco, eleva la cadera con la barra sobre ella': 'Leaning on a bench, raise your hips with the bar across them',
  'Hip thrust con una pierna elevada, mayor activación': 'Hip thrust with one leg raised, greater activation',
  'Acostado boca abajo en la máquina, flexiona las piernas': 'Lying face down on the machine, curl your legs',
  'Sentado en la máquina, flexiona las piernas contra resistencia': 'Seated on the machine, curl your legs against resistance',
  'Acostado boca arriba, eleva la cadera hacia arriba': 'Lying on your back, raise your hips upward',
  'Puente con una pierna elevada, mayor dificultad': 'Bridge with one leg raised, more difficult',
  'De pie frente a la polea, extiende la pierna hacia atrás': 'Standing facing the cable, extend your leg backward',
  'Sentado en la máquina, abre las piernas hacia los lados': 'Seated on the machine, open your legs to the sides',
  'Inclinado hacia adelante con una pierna atrás, mejora el equilibrio': 'Bent forward with one leg back, improves balance',
  'Con piernas abiertas y puntas hacia afuera, énfasis en glúteos': 'With legs wide and toes pointed out, emphasis on glutes',
  'Con barra en la espalda, inclina el torso hacia adelante': 'With a bar on your back, lean your torso forward',
  'Con banda elástica en los tobillos, camina lateralmente': 'With a resistance band around your ankles, walk sideways',
  'Acostado, eleva el torso contrayendo el abdomen': 'Lying down, raise your torso contracting your abs',
  'En posición de plancha, mantén el cuerpo recto el máximo tiempo': 'In a plank position, keep your body straight as long as possible',
  'De lado, mantén el cuerpo recto apoyado en un brazo': 'On your side, keep your body straight supported on one arm',
  'Acostado o colgado, eleva las piernas rectas': 'Lying down or hanging, raise your legs straight',
  'Colgado de una barra, eleva las rodillas al pecho': 'Hanging from a bar, raise your knees to your chest',
  'Sentado con pies elevados, rota el torso de lado a lado': 'Seated with feet elevated, rotate your torso side to side',
  'Acostado, lleva codo a rodilla contraria alternando': 'Lying down, bring elbow to opposite knee alternating',
  'Sentado en la máquina de abdominales, flexiona el torso': 'Seated on the ab machine, crunch your torso forward',
  'En plancha, lleva las rodillas al pecho alternando rápido': 'In a plank, drive your knees to your chest alternating quickly',
  'Acostado, extiende brazo y pierna contrarios alternando': 'Lying down, extend opposite arm and leg alternating',
  'Acostado, eleva brazos y piernas simultáneamente formando una V': 'Lying down, raise arms and legs simultaneously forming a V',
  'En máquina de flexión de cadera, trabaja el abdomen inferior': 'On a hip flexion machine, works the lower abs',
  'En plancha, toca el hombro contrario alternando': 'In a plank, tap the opposite shoulder alternating',
  'De rodillas, extiende el cuerpo con la rueda y vuelve': 'On your knees, roll the ab wheel forward and back',
  'Desde de pie, baja a plancha, salta y repite, ejercicio completo': 'From standing, drop to a plank, jump up and repeat, full-body exercise',
  'Salta abriendo piernas y brazos, vuelve y repite': 'Jump opening your legs and arms, return and repeat',
  'Salta la cuerda a ritmo constante': 'Jump rope at a steady pace',
  'Corre en el sitio elevando las rodillas al pecho': 'Run in place raising your knees to your chest',
  'Salta sobre un cajón o plataforma estable': 'Jump onto a sturdy box or platform',
  'Con pesa rusa, balancea entre las piernas y hacia arriba': 'With a kettlebell, swing between your legs and up',
  'Con cuerdas gruesas, haz ondas continuas en el suelo': 'With heavy ropes, make continuous waves on the floor',
  'Empuja un trineo con peso hacia adelante': 'Push a weighted sled forward',
  'En plancha, lleva las rodillas al pecho controladamente': 'In a plank, drive your knees to your chest in a controlled manner',
  'Sentadilla seguida de un salto vertical explosivo': 'Squat followed by an explosive vertical jump',
  'Antebrazos apoyados, flexiona la muñeca hacia arriba': 'Forearms supported, curl your wrist upward',
  'Antebrazos apoyados, extiende la muñeca hacia arriba': 'Forearms supported, extend your wrist upward',
  'Cuélgate de una barra el máximo tiempo posible': 'Hang from a bar as long as possible',
  'Camina sujetando mancuernas o pesas pesadas a los lados': 'Walk holding heavy dumbbells or weights at your sides',
  'Aprieta una pelota de tenis repetidamente': 'Squeeze a tennis ball repeatedly',
};

const Map<String, String> _englishExerciseNames = {
  'Press de banca con barra': 'Barbell Bench Press',
  'Press de banca inclinado con barra': 'Incline Barbell Bench Press',
  'Press de banca declinado': 'Decline Barbell Bench Press',
  'Press con mancuernas en banco plano': 'Dumbbell Bench Press',
  'Press inclinado con mancuernas': 'Incline Dumbbell Press',
  'Aperturas con mancuernas en banco plano': 'Dumbbell Chest Flyes',
  'Aperturas en máquina Peck Deck': 'Pec Deck Flyes',
  'Cruce de cables en polea alta': 'High Cable Crossover',
  'Cruce de cables en polea baja': 'Low Cable Crossover',
  'Flexiones de brazos (push-ups)': 'Push-ups',
  'Flexiones inclinadas': 'Incline Push-ups',
  'Flexiones declinadas': 'Decline Push-ups',
  'Flexiones diamante': 'Diamond Push-ups',
  'Fondos en paralelas': 'Parallel Bar Dips',
  'Press en máquina': 'Chest Press Machine',
  'Pullover con mancuerna': 'Dumbbell Pullover',
  'Flexiones con palmada': 'Clap Push-ups',
  'Dominadas (pull-ups)': 'Pull-ups',
  'Dominadas supinas (chin-ups)': 'Chin-ups',
  'Remo con barra': 'Barbell Row',
  'Remo con mancuerna a una mano': 'One-Arm Dumbbell Row',
  'Jalón al pecho en polea': 'Lat Pulldown',
  'Jalón al pecho agarre estrecho': 'Close-Grip Lat Pulldown',
  'Remo en máquina': 'Seated Cable Row',
  'Remo en polea baja': 'Low Cable Row',
  'Peso muerto': 'Deadlift',
  'Peso muerto rumano': 'Romanian Deadlift',
  'Hiperextensiones (lumbares)': 'Back Extensions',
  'Encogimientos con barra (shrugs)': 'Barbell Shrugs',
  'Encogimientos con mancuernas': 'Dumbbell Shrugs',
  'Remo invertido (australian pull-ups)': 'Inverted Row',
  'Superman': 'Superman',
  'Pull-ups con agarre neutro': 'Neutral-Grip Pull-ups',
  'Face pull en polea': 'Cable Face Pull',
  'Remo con barra T': 'T-Bar Row',
  'Press militar con barra': 'Standing Barbell Overhead Press',
  'Press con mancuernas sentado': 'Seated Dumbbell Shoulder Press',
  'Elevaciones laterales con mancuernas': 'Dumbbell Lateral Raises',
  'Elevaciones frontales con mancuernas': 'Dumbbell Front Raises',
  'Elevaciones laterales en polea': 'Cable Lateral Raises',
  'Pájaro (face down fly)': 'Bent-Over Reverse Flyes',
  'Press Arnold': 'Arnold Press',
  'Paseos frontales con barra (frontal raises)': 'Barbell Front Raises',
  'Clean and press': 'Clean and Press',
  'Press en máquina de hombros': 'Shoulder Press Machine',
  'Círculos con los brazos': 'Arm Circles',
  'Pike push-ups': 'Pike Push-ups',
  'Curl con barra recta': 'Barbell Curl',
  'Curl con barra Z': 'EZ Bar Curl',
  'Curl con mancuernas alternado': 'Alternating Dumbbell Curl',
  'Curl martillo con mancuernas': 'Dumbbell Hammer Curl',
  'Curl concentrado': 'Concentration Curl',
  'Curl en polea baja': 'Cable Curl',
  'Curl en banco predicador': 'Preacher Curl',
  'Curl invertido con barra': 'Reverse Barbell Curl',
  'Curl con cable a una mano': 'One-Arm Cable Curl',
  'Flexiones de brazos estrechas': 'Close-Grip Push-ups',
  'Extensión de tríceps en polea': 'Cable Triceps Pushdown',
  'Extensión de tríceps con cuerda': 'Rope Triceps Pushdown',
  'Press francés con barra Z': 'EZ Bar French Press',
  'Press francés con mancuernas': 'Dumbbell French Press',
  'Patada de tríceps con mancuerna': 'Dumbbell Triceps Kickback',
  'Fondos en banco (tríceps)': 'Bench Dips',
  'Extensión de tríceps por encima de la cabeza': 'Overhead Triceps Extension',
  'Press de banca agarre cerrado': 'Close-Grip Bench Press',
  'Sentadilla con barra (back squat)': 'Barbell Back Squat',
  'Sentadilla frontal (front squat)': 'Barbell Front Squat',
  'Sentadilla goblet': 'Goblet Squat',
  'Sentadilla búlgara': 'Bulgarian Split Squat',
  'Prensa de piernas (leg press)': 'Leg Press',
  'Extensión de cuádriceps en máquina': 'Leg Extension',
  'Zancadas con mancuernas': 'Dumbbell Lunges',
  'Zancadas laterales': 'Side Lunges',
  'Zancadas inversas': 'Reverse Lunges',
  'Sentadilla con salto': 'Jump Squats',
  'Sentadilla isométrica (wall sit)': 'Wall Sit',
  'Step-ups con mancuernas': 'Dumbbell Step-ups',
  'Sentadilla con pausa': 'Pause Squat',
  'Sentadilla copa (goblet squat)': 'Goblet Squat',
  'Hip thrust con barra': 'Barbell Hip Thrust',
  'Hip thrust a una pierna': 'Single-Leg Hip Thrust',
  'Curl de piernas en máquina (leg curl)': 'Leg Curl',
  'Curl de piernas sentado': 'Seated Leg Curl',
  'Puente de glúteos': 'Glute Bridge',
  'Puente de glúteos a una pierna': 'Single-Leg Glute Bridge',
  'Patada de glúteo en polea': 'Cable Glute Kickback',
  'Abducción de cadera en máquina': 'Seated Hip Abduction Machine',
  'Peso muerto a una pierna con mancuerna': 'Single-Leg Dumbbell Deadlift',
  'Sentadilla sumo': 'Sumo Squat',
  'Good mornings': 'Good Mornings',
  'Caminata lateral con banda': 'Lateral Band Walk',
  'Crunch abdominal': 'Crunches',
  'Plancha abdominal': 'Plank',
  'Plancha lateral': 'Side Plank',
  'Elevación de piernas': 'Leg Raises',
  'Elevación de rodillas colgado': 'Hanging Knee Raises',
  'Russian twists': 'Russian Twists',
  'Bicicleta abdominal': 'Bicycle Crunches',
  'Crunch en máquina': 'Machine Crunch',
  'Mountain climbers': 'Mountain Climbers',
  'Dead bug': 'Dead Bug',
  'V-ups': 'V-ups',
  'Flexiones de cadera en máquina': 'Machine Hip Flexion',
  'Plancha con toque de hombro': 'Plank Shoulder Taps',
  'Ab wheel (rueda abdominal)': 'Ab Wheel Rollout',
  'Burpees': 'Burpees',
  'Saltos de tijera (jumping jacks)': 'Jumping Jacks',
  'Cuerda a saltar (skipping)': 'Jump Rope',
  'High knees': 'High Knees',
  'Box jumps': 'Box Jumps',
  'Kettlebell swings': 'Kettlebell Swings',
  'Battle ropes': 'Battle Ropes',
  'Sled push': 'Sled Push',
  'Escalador (versión mountain climber lenta)': 'Climber',
  'Saltos en cuclillas': 'Squat Jumps',
  'Curl de muñeca con barra': 'Barbell Wrist Curl',
  'Curl de muñeca invertido': 'Reverse Wrist Curl',
  'Colgada en barra (dead hang)': 'Dead Hang',
  'Caminata del granjero (farmer walk)': 'Farmer\'s Walk',
  'Apretón con pelota de tenis': 'Tennis Ball Squeeze',
};
