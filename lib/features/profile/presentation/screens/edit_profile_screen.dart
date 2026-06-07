import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
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
  late final TextEditingController goalController;
  late final TextEditingController bodyFatController;
  late final TextEditingController muscleMassController;

  DateTime? selectedDateOfBirth;

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

    selectedDateOfBirth = widget.profile.dateOfBirth != null
        ? DateTime.tryParse(widget.profile.dateOfBirth!)
        : null;

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
    goalController.dispose();
    bodyFatController.dispose();
    muscleMassController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final weight = _parseDouble(weightController.text);
    final height = _parseInt(heightController.text);
    final dateOfBirth = selectedDateOfBirth;
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
        dateOfBirth: dateOfBirth != null ? _formatDate(dateOfBirth) : null,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textMain),
        title: Text(
          l10n.profileEditPhysicalData,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              _HeaderCard(
                name: widget.profile.name,
                email: widget.profile.email,
              ),
              SizedBox(height: 24),
              _EditFormCard(
                weightController: weightController,
                heightController: heightController,
                selectedDateOfBirth: selectedDateOfBirth,
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
                onDateOfBirthChanged: (value) {
                  setState(() {
                    selectedDateOfBirth = value;
                  });
                },
              ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage!,
                    style: TextStyle(
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
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: context.colors.background,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          l10n.fitnessSaveChanges,
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
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.4),
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
              color: context.colors.inputBackground,
              border: Border.all(
                color: context.colors.primary,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.person,
              color: context.colors.primary,
              size: 30,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  email,
                  style: TextStyle(
                    color: context.colors.secondary,
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
    required this.selectedDateOfBirth,
    required this.goalController,
    required this.bodyFatController,
    required this.muscleMassController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.onClearGender,
    required this.onDateOfBirthChanged,
  });

  final TextEditingController weightController;
  final TextEditingController heightController;
  final DateTime? selectedDateOfBirth;
  final TextEditingController goalController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;
  final VoidCallback onClearGender;
  final ValueChanged<DateTime?> onDateOfBirthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colors.divider.withOpacity(0.4),
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
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          SizedBox(height: 16),
          _EditProfileField(
            controller: heightController,
            label: 'Altura',
            hintText: 'Ej: 180',
            suffix: 'cm',
            icon: Icons.height,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          _DateOfBirthField(
            selectedDate: selectedDateOfBirth,
            onChanged: onDateOfBirthChanged,
          ),
          SizedBox(height: 16),
          _GenderDropdownField(
            value: selectedGender,
            onChanged: onGenderChanged,
            onClear: onClearGender,
          ),
          SizedBox(height: 16),
          _EditProfileField(
            controller: goalController,
            label: 'Objetivo',
            hintText: 'Ej: ganar masa muscular',
            icon: Icons.flag_outlined,
          ),
          SizedBox(height: 16),
          _EditProfileField(
            controller: bodyFatController,
            label: 'Grasa corporal',
            hintText: 'Ej: 15.2',
            suffix: '%',
            icon: Icons.percent,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          SizedBox(height: 16),
          _EditProfileField(
            controller: muscleMassController,
            label: 'Masa muscular',
            hintText: 'Ej: 62',
            suffix: 'kg',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({
    required this.selectedDate,
    required this.onChanged,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    final dateStr = selectedDate != null
        ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
        : '';

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(now.year - 25, now.month, now.day),
          firstDate: DateTime(now.year - 120, 1, 1),
          lastDate: now,
          helpText: 'Selecciona tu fecha de nacimiento',
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: dateStr),
        decoration: InputDecoration(
          filled: true,
          fillColor: context.colors.inputBackground,
          labelText: 'Fecha de nacimiento',
          labelStyle: TextStyle(
            color: context.colors.secondary,
            fontWeight: FontWeight.w600,
          ),
          hintText: 'Selecciona tu fecha de nacimiento',
          hintStyle: TextStyle(
            color: context.colors.textMain.withOpacity(0.45),
          ),
          prefixIcon: Icon(
            Icons.cake_outlined,
            color: context.colors.primary,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: context.colors.inputBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: context.colors.primary,
              width: 1.4,
            ),
          ),
        ),
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
    final l10n = AppLocalizations.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: context.colors.surface,
      style: TextStyle(
        color: context.colors.textMain,
        fontSize: 15,
      ),
      iconEnabledColor: context.colors.secondary,
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.inputBackground,
        labelText: l10n.profileGender,
        labelStyle: TextStyle(
          color: context.colors.secondary,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.wc,
          color: context.colors.primary,
        ),
        suffixIcon: value == null
            ? null
            : IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.close,
                  color: context.colors.secondary,
                ),
              ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.primary,
            width: 1.4,
          ),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'HOMBRE',
          child: Text(l10n.fitnessMale),
        ),
        DropdownMenuItem(
          value: 'MUJER',
          child: Text(l10n.fitnessFemale),
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
      style: TextStyle(
        color: context.colors.textMain,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: context.colors.inputBackground,
        labelText: label,
        labelStyle: TextStyle(
          color: context.colors.secondary,
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.colors.textMain.withOpacity(0.45),
        ),
        prefixIcon: Icon(
          icon,
          color: context.colors.primary,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: context.colors.secondary,
          fontWeight: FontWeight.w700,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.inputBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: context.colors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
