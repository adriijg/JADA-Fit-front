import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/profile_model.dart';
import '../../data/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
  });

  final ProfileModel profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();

  late final TextEditingController weightController;
  late final TextEditingController heightController;
  late final TextEditingController ageController;
  late final TextEditingController goalController;
  late final TextEditingController bodyFatController;
  late final TextEditingController muscleMassController;

  String? selectedGender;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    weightController = TextEditingController(
      text: _formatNullableDouble(widget.profile.weight),
    );

    heightController = TextEditingController(
      text: widget.profile.height?.toString() ?? '',
    );

    ageController = TextEditingController(
      text: widget.profile.age?.toString() ?? '',
    );

    selectedGender = _normalizeGender(widget.profile.gender);

    goalController = TextEditingController(
      text: widget.profile.goal ?? '',
    );

    bodyFatController = TextEditingController(
      text: _formatNullableDouble(widget.profile.bodyFat),
    );

    muscleMassController = TextEditingController(
      text: _formatNullableDouble(widget.profile.muscleMass),
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    goalController.dispose();
    bodyFatController.dispose();
    muscleMassController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final weight = _parseDouble(weightController.text);
    final height = _parseInt(heightController.text);
    final age = _parseInt(ageController.text);
    final bodyFat = _parseDouble(bodyFatController.text);
    final muscleMass = _parseDouble(muscleMassController.text);

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final updatedProfile = await _profileService.updateMyProfile(
        weight: weight,
        height: height,
        age: age,
        gender: selectedGender,
        goal: goalController.text,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
      );

      if (!mounted) return;

      Navigator.pop(context, updatedProfile);
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'No se pudo actualizar el perfil';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _normalizeGender(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.trim().toUpperCase();

    if (normalized == 'HOMBRE') return 'HOMBRE';
    if (normalized == 'MUJER') return 'MUJER';

    return null;
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

  String _formatNullableDouble(double? value) {
    if (value == null) return '';

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  void _clearGender() {
    setState(() {
      selectedGender = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textMain),
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _HeaderCard(
                name: widget.profile.name,
                email: widget.profile.email,
              ),
              const SizedBox(height: 24),
              _EditFormCard(
                weightController: weightController,
                heightController: heightController,
                ageController: ageController,
                goalController: goalController,
                bodyFatController: bodyFatController,
                muscleMassController: muscleMassController,
                selectedGender: selectedGender,
                onGenderChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                onClearGender: _clearGender,
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
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
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
                      : const Text(
                          'GUARDAR CAMBIOS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.inputBackground,
              border: Border.all(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditFormCard extends StatelessWidget {
  const _EditFormCard({
    required this.weightController,
    required this.heightController,
    required this.ageController,
    required this.goalController,
    required this.bodyFatController,
    required this.muscleMassController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onClearGender,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController ageController;
  final TextEditingController goalController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onClearGender;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          _EditProfileField(
            controller: weightController,
            label: 'Peso',
            hintText: 'Ej: 78.5',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 16),
          _EditProfileField(
            controller: heightController,
            label: 'Altura',
            hintText: 'Ej: 180',
            suffix: 'cm',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _EditProfileField(
            controller: ageController,
            label: 'Edad',
            hintText: 'Ej: 25',
            suffix: 'años',
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _GenderDropdownField(
            value: selectedGender,
            onChanged: onGenderChanged,
            onClear: onClearGender,
          ),
          const SizedBox(height: 16),
          _EditProfileField(
            controller: goalController,
            label: 'Objetivo',
            hintText: 'Ej: ganar masa muscular',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 16),
          _EditProfileField(
            controller: bodyFatController,
            label: 'Grasa corporal',
            hintText: 'Ej: 15.2',
            suffix: '%',
            icon: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 16),
          _EditProfileField(
            controller: muscleMassController,
            label: 'Masa muscular',
            hintText: 'Ej: 62',
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

class _GenderDropdownField extends StatelessWidget {
  const _GenderDropdownField({
    required this.value,
    required this.onChanged,
    required this.onClear,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.surface,
      style: const TextStyle(
        color: AppColors.textMain,
        fontSize: 15,
      ),
      iconEnabledColor: AppColors.secondary,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.inputBackground,
        labelText: 'Género',
        labelStyle: const TextStyle(
          color: AppColors.secondary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: const Icon(
          Icons.wc,
          color: AppColors.primary,
        ),
        suffixIcon: value == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.secondary,
                ),
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

class _EditProfileField extends StatelessWidget {
  const _EditProfileField({
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
          color: AppColors.textMain.withValues(alpha: 0.45),
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