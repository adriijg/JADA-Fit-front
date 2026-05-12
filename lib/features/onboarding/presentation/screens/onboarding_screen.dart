import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../data/services/onboarding_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingService _onboardingService = OnboardingService();

  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bodyFatController = TextEditingController();
  final TextEditingController muscleMassController = TextEditingController();

  String? selectedGender;
  String? selectedGoal;

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    bodyFatController.dispose();
    muscleMassController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final weight = _parseDouble(weightController.text);
    final height = _parseInt(heightController.text);
    final age = _parseInt(ageController.text);
    final bodyFat = _parseDouble(bodyFatController.text);
    final muscleMass = _parseDouble(muscleMassController.text);

    if (weight == null) {
      _setError('Introduce tu peso');
      return;
    }

    if (height == null) {
      _setError('Introduce tu altura');
      return;
    }

    if (age == null) {
      _setError('Introduce tu edad');
      return;
    }

    if (selectedGender == null) {
      _setError('Selecciona tu género');
      return;
    }

    if (selectedGoal == null) {
      _setError('Selecciona tu objetivo');
      return;
    }

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      await _onboardingService.completeOnboarding(
        weight: weight,
        height: height,
        age: age,
        gender: selectedGender!,
        goal: selectedGoal!,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo completar la configuración inicial';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _setError(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');

    if (trimmed.isEmpty) return null;

    return double.tryParse(trimmed);
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return int.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    Color(0xFF061216),
                    Color(0xFF071A20),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _OnboardingHeader(),
                  const SizedBox(height: 28),
                  _OnboardingCard(
                    weightController: weightController,
                    heightController: heightController,
                    ageController: ageController,
                    bodyFatController: bodyFatController,
                    muscleMassController: muscleMassController,
                    selectedGender: selectedGender,
                    selectedGoal: selectedGoal,
                    onGenderChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    onGoalChanged: (value) {
                      setState(() {
                        selectedGoal = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _completeOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        elevation: 12,
                        shadowColor: AppColors.primary.withOpacity(0.32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: AppColors.background,
                                strokeWidth: 2.4,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'EMPEZAR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Icon(Icons.arrow_forward, size: 20),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.fitness_center,
          size: 58,
          color: AppColors.primary,
        ),
        SizedBox(height: 18),
        Text(
          'Configura tu perfil fitness',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Usaremos estos datos para personalizar tus recomendaciones, objetivos y progreso.',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.bodyFatController,
    required this.muscleMassController,
    required this.selectedGender,
    required this.selectedGoal,
    required this.onGenderChanged,
    required this.onGoalChanged,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;
  final String? selectedGender;
  final String? selectedGoal;
  final ValueChanged<String?> onGenderChanged;
  final ValueChanged<String?> onGoalChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withOpacity(0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _OnboardingTextField(
            controller: weightController,
            label: 'Peso actual',
            hintText: 'Ej: 70',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 16),
          _OnboardingTextField(
            controller: heightController,
            label: 'Altura',
            hintText: 'Ej: 180',
            suffix: 'cm',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _OnboardingTextField(
            controller: ageController,
            label: 'Edad',
            hintText: 'Ej: 25',
            suffix: 'años',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _GenderDropdown(
            value: selectedGender,
            onChanged: onGenderChanged,
          ),
          const SizedBox(height: 16),
          _GoalDropdown(
            value: selectedGoal,
            onChanged: onGoalChanged,
          ),
          const SizedBox(height: 16),
          _OnboardingTextField(
            controller: bodyFatController,
            label: 'Grasa corporal',
            hintText: 'Opcional · Ej: 15',
            suffix: '%',
            icon: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 16),
          _OnboardingTextField(
            controller: muscleMassController,
            label: 'Masa muscular',
            hintText: 'Opcional · Ej: 58',
            suffix: 'kg',
            icon: Icons.fitness_center,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 15,
      ),
      iconEnabledColor: AppColors.secondary,
      decoration: _inputDecoration(
        label: 'Género',
        icon: Icons.wc,
      ),
      items: const [
        DropdownMenuItem(
          value: 'HOMBRE',
          child: Text('Hombre'),
        ),
        DropdownMenuItem(
          value: 'MUJER',
          child: Text('Mujer'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _GoalDropdown extends StatelessWidget {
  const _GoalDropdown({
    required this.value,
    required this.onChanged,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 15,
      ),
      iconEnabledColor: AppColors.secondary,
      decoration: _inputDecoration(
        label: 'Objetivo',
        icon: Icons.flag_outlined,
      ),
      items: const [
        DropdownMenuItem(
          value: 'GANAR_MUSCULO',
          child: Text('Ganar músculo'),
        ),
        DropdownMenuItem(
          value: 'PERDER_GRASA',
          child: Text('Perder grasa'),
        ),
        DropdownMenuItem(
          value: 'MANTENERSE_ATLETICO',
          child: Text('Mantenerse atlético/a'),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _OnboardingTextField extends StatelessWidget {
  const _OnboardingTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.suffix,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final String? suffix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 15,
      ),
      decoration: _inputDecoration(
        label: label,
        hintText: hintText,
        icon: icon,
        suffix: suffix,
      ),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icon,
  String? hintText,
  String? suffix,
}) {
  return InputDecoration(
    filled: true,
    fillColor: AppColors.inputBackground,
    labelText: label,
    labelStyle: const TextStyle(
      color: AppColors.secondary,
      fontWeight: FontWeight.w600,
    ),
    hintText: hintText,
    hintStyle: TextStyle(
      color: AppColors.textMain.withOpacity(0.45),
    ),
    prefixIcon: Icon(
      icon,
      color: AppColors.primary,
    ),
    suffixText: suffix,
    suffixStyle: const TextStyle(
      color: AppColors.secondary,
      fontWeight: FontWeight.w700,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.inputBorder,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 1.4,
      ),
    ),
  );
}
