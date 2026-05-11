import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_profile_model.dart';
import '../../data/services/fitness_profile_service.dart';

class EditFitnessProfileScreen extends StatefulWidget {
  const EditFitnessProfileScreen({
    super.key,
    required this.currentProfile,
  });

  final FitnessProfileModel currentProfile;

  @override
  State<EditFitnessProfileScreen> createState() =>
      _EditFitnessProfileScreenState();
}

class _EditFitnessProfileScreenState extends State<EditFitnessProfileScreen> {
  final FitnessProfileService _fitnessProfileService = FitnessProfileService();

  final TextEditingController heightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? selectedGender;
  String? selectedGoal;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    heightController.text = widget.currentProfile.height?.toString() ?? '';
    ageController.text = widget.currentProfile.age?.toString() ?? '';

    selectedGender = _normalizeGender(widget.currentProfile.gender);
    selectedGoal = _normalizeGoal(widget.currentProfile.goal);
  }

  @override
  void dispose() {
    heightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  String? _normalizeGender(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.trim().toUpperCase();

    if (normalized == 'HOMBRE') return 'HOMBRE';
    if (normalized == 'MUJER') return 'MUJER';

    return null;
  }

  String? _normalizeGoal(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.trim().toUpperCase();

    if (normalized == 'GANAR_MUSCULO') return 'GANAR_MUSCULO';
    if (normalized == 'PERDER_GRASA') return 'PERDER_GRASA';
    if (normalized == 'MANTENERSE_ATLETICO') return 'MANTENERSE_ATLETICO';

    return null;
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return int.tryParse(trimmed);
  }

  Future<void> _saveProfile() async {
    final height = _parseInt(heightController.text);
    final age = _parseInt(ageController.text);

    setState(() {
      errorMessage = null;
    });

    if (height == null) {
      setState(() {
        errorMessage = 'Introduce tu altura';
      });
      return;
    }

    if (height <= 0) {
      setState(() {
        errorMessage = 'La altura debe ser mayor que 0';
      });
      return;
    }

    if (age == null) {
      setState(() {
        errorMessage = 'Introduce tu edad';
      });
      return;
    }

    if (age <= 0) {
      setState(() {
        errorMessage = 'La edad debe ser mayor que 0';
      });
      return;
    }

    if (selectedGender == null) {
      setState(() {
        errorMessage = 'Selecciona tu género';
      });
      return;
    }

    if (selectedGoal == null) {
      setState(() {
        errorMessage = 'Selecciona tu objetivo';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _fitnessProfileService.updateMyFitnessProfile(
        weight: widget.currentProfile.weight,
        height: height,
        age: age,
        gender: selectedGender,
        goal: selectedGoal,
        bodyFat: widget.currentProfile.bodyFat,
        muscleMass: widget.currentProfile.muscleMass,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos físicos actualizados correctamente'),
          backgroundColor: AppColors.surface,
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudieron actualizar los datos físicos';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _genderLabel(String value) {
    switch (value) {
      case 'HOMBRE':
        return 'Hombre';
      case 'MUJER':
        return 'Mujer';
      default:
        return value;
    }
  }

  String _goalLabel(String value) {
    switch (value) {
      case 'GANAR_MUSCULO':
        return 'Ganar músculo';
      case 'PERDER_GRASA':
        return 'Perder grasa';
      case 'MANTENERSE_ATLETICO':
        return 'Mantenerse atlético/a';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Editar datos físicos',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IntroCard(),
              const SizedBox(height: 24),
              _FormCard(
                heightController: heightController,
                ageController: ageController,
              ),
              const SizedBox(height: 18),
              _SelectorCard(
                title: 'Género',
                subtitle: 'Selecciona una opción',
                selectedValue: selectedGender,
                values: const ['HOMBRE', 'MUJER'],
                labelBuilder: _genderLabel,
                onSelected: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 18),
              _SelectorCard(
                title: 'Objetivo',
                subtitle: 'Esto ayudará a personalizar la app',
                selectedValue: selectedGoal,
                values: const [
                  'GANAR_MUSCULO',
                  'PERDER_GRASA',
                  'MANTENERSE_ATLETICO',
                ],
                labelBuilder: _goalLabel,
                onSelected: (value) {
                  setState(() {
                    selectedGoal = value;
                  });
                },
              ),
              const SizedBox(height: 18),
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
                  onPressed: isLoading ? null : _saveProfile,
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
                            strokeWidth: 2.4,
                            color: AppColors.background,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GUARDAR CAMBIOS',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.save_outlined, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tune,
            color: AppColors.primary,
            size: 42,
          ),
          SizedBox(height: 18),
          Text(
            'Configura tu perfil físico',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Estos datos sirven para personalizar tus objetivos, recomendaciones y futuros análisis.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.heightController,
    required this.ageController,
  });

  final TextEditingController heightController;
  final TextEditingController ageController;

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
      ),
      child: Column(
        children: [
          _FitnessTextField(
            controller: heightController,
            label: 'Altura',
            hintText: 'Ej: 180',
            suffix: 'cm',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _FitnessTextField(
            controller: ageController,
            label: 'Edad',
            hintText: 'Ej: 25',
            suffix: 'años',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class _FitnessTextField extends StatelessWidget {
  const _FitnessTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.suffix,
    required this.icon,
    required this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String suffix;
  final IconData icon;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 15,
      ),
      decoration: InputDecoration(
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
      ),
    );
  }
}

class _SelectorCard extends StatelessWidget {
  const _SelectorCard({
    required this.title,
    required this.subtitle,
    required this.selectedValue,
    required this.values,
    required this.labelBuilder,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final String? selectedValue;
  final List<String> values;
  final String Function(String value) labelBuilder;
  final ValueChanged<String> onSelected;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...values.map(
            (value) {
              final isSelected = value == selectedValue;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onSelected(value),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.inputBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppColors.background
                              : AppColors.secondary,
                          size: 21,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labelBuilder(value),
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.textMain,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
