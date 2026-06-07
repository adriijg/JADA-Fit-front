import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/widgets/app_card.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_profile_model.dart';
import '../../data/services/fitness_profile_service.dart';
import '../../../../l10n/app_localizations.dart';

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

  DateTime? selectedDateOfBirth;
  String? selectedGender;
  String? selectedGoal;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    heightController.text = widget.currentProfile.height?.toString() ?? '';

    selectedDateOfBirth = widget.currentProfile.dateOfBirth != null
        ? DateTime.tryParse(widget.currentProfile.dateOfBirth!)
        : null;

    selectedGender = _normalizeGender(widget.currentProfile.gender);
    selectedGoal = _normalizeGoal(widget.currentProfile.goal);
  }

  @override
  void dispose() {
    heightController.dispose();
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
    if (normalized == 'MEJORAR_RENDIMIENTO') return 'MEJORAR_RENDIMIENTO';
    if (normalized == 'RECOMPOSICION_CORPORAL') return 'RECOMPOSICION_CORPORAL';

    return null;
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) return null;

    return int.tryParse(trimmed);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveProfile() async {
    final height = _parseInt(heightController.text);
    final dateOfBirth = selectedDateOfBirth;

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

    if (dateOfBirth == null) {
      setState(() {
        errorMessage = 'Introduce tu fecha de nacimiento';
      });
      return;
    }

    if (selectedGender == null) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.fitnessSelectGenderError;
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
        dateOfBirth: _formatDate(dateOfBirth),
        gender: selectedGender,
        goal: selectedGoal,
        bodyFat: widget.currentProfile.bodyFat,
        muscleMass: widget.currentProfile.muscleMass,
      );

      await _recalculateGoals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.fitnessDataUpdated),
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
        errorMessage = AppLocalizations.of(context)!.fitnessUpdateDataError;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _recalculateGoals() async {
    try {
      final storage = SecureStorageService();
      final token = await storage.getToken();
      if (token == null) return;

      final client = http.Client();
      await client.post(
        Uri.parse(ApiEndpoints.nutritionGoalsRecalculate),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      client.close();
    } catch (_) {}
  }

  String _genderLabel(String value) {
    switch (value) {
      case 'HOMBRE':
        return AppLocalizations.of(context)!.fitnessMale;
      case 'MUJER':
        return AppLocalizations.of(context)!.fitnessFemale;
      default:
        return value;
    }
  }

  String _goalLabel(String value) {
    switch (value) {
      case 'GANAR_MUSCULO':
        return AppLocalizations.of(context)!.fitnessGainMuscle;
      case 'PERDER_GRASA':
        return AppLocalizations.of(context)!.fitnessLoseFat;
      case 'MANTENERSE_ATLETICO':
        return AppLocalizations.of(context)!.fitnessStayAthletic;
      case 'MEJORAR_RENDIMIENTO':
        return 'Mejorar rendimiento';
      case 'RECOMPOSICION_CORPORAL':
        return AppLocalizations.of(context)!.fitnessRecomposition;
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          AppLocalizations.of(context)!.fitnessEditPhysicalData,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IntroCard(),
              SizedBox(height: 24),
              _FormCard(
                heightController: heightController,
                selectedDateOfBirth: selectedDateOfBirth,
                onDateOfBirthChanged: (value) {
                  setState(() {
                    selectedDateOfBirth = value;
                  });
                },
              ),
              SizedBox(height: 18),
              _SelectorCard(
                title: AppLocalizations.of(context)!.fitnessGender,
                subtitle: AppLocalizations.of(context)!.fitnessSelectOption,
                selectedValue: selectedGender,
                values: const ['HOMBRE', 'MUJER'],
                labelBuilder: _genderLabel,
                onSelected: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
              ),
              SizedBox(height: 18),
              _SelectorCard(
                title: AppLocalizations.of(context)!.fitnessGoal,
                subtitle: AppLocalizations.of(context)!.fitnessPersonalizeHelp,
                selectedValue: selectedGoal,
                values: const [
                  'GANAR_MUSCULO',
                  'PERDER_GRASA',
                  'MANTENERSE_ATLETICO',
                  'MEJORAR_RENDIMIENTO',
                  'RECOMPOSICION_CORPORAL',
                ],
                labelBuilder: _goalLabel,
                onSelected: (value) {
                  setState(() {
                    selectedGoal = value;
                  });
                },
              ),
              SizedBox(height: 18),
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
                height: 58,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: context.colors.background,
                    elevation: 12,
                    shadowColor: context.colors.primary.withOpacity(0.32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: context.colors.background,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.fitnessSaveChanges,
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
              SizedBox(height: 20),
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
    return AppCard.primary(
        borderRadius: 28,
        padding: EdgeInsets.all(24),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.tune,
            color: context.colors.primary,
            size: 42,
          ),
          SizedBox(height: 18),
          Text(
            AppLocalizations.of(context)!.fitnessSetupProfile,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.fitnessSetupProfileDesc,
            style: TextStyle(
              color: context.colors.secondary,
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
    required this.selectedDateOfBirth,
    required this.onDateOfBirthChanged,
  });

  final TextEditingController heightController;
  final DateTime? selectedDateOfBirth;
  final ValueChanged<DateTime?> onDateOfBirthChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
        borderRadius: 28,
        padding: EdgeInsets.all(22),
        child: Column(
        children: [
          _FitnessTextField(
            controller: heightController,
            label: AppLocalizations.of(context)!.fitnessHeight,
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
    return AppCard.elevated(
        borderRadius: 28,
        padding: EdgeInsets.all(22),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16),
          ...values.map(
            (value) {
              final isSelected = value == selectedValue;

              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onSelected(value),
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colors.primary
                          : context.colors.inputBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? context.colors.primary
                            : context.colors.inputBorder,
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
                              ? context.colors.background
                              : context.colors.secondary,
                          size: 21,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            labelBuilder(value),
                            style: TextStyle(
                              color: isSelected
                                  ? context.colors.background
                                  : context.colors.textMain,
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
