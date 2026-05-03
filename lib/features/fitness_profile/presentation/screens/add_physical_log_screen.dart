import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_profile_model.dart';
import '../../data/services/fitness_progress_service.dart';

class AddPhysicalLogScreen extends StatefulWidget {
  const AddPhysicalLogScreen({
    super.key,
    this.currentProfile,
    this.initialDate,
  });

  final FitnessProfileModel? currentProfile;
  final DateTime? initialDate;

  @override
  State<AddPhysicalLogScreen> createState() => _AddPhysicalLogScreenState();
}

class _AddPhysicalLogScreenState extends State<AddPhysicalLogScreen> {
  final FitnessProgressService _fitnessProgressService =
      FitnessProgressService();

  final TextEditingController weightController = TextEditingController();
  final TextEditingController bodyFatController = TextEditingController();
  final TextEditingController muscleMassController = TextEditingController();

  late DateTime selectedDate;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final initialDateTime = widget.initialDate ?? DateTime.now();

    selectedDate = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
    );

    weightController.text = _formatInitialValue(widget.currentProfile?.weight);
    bodyFatController.text =
        _formatInitialValue(widget.currentProfile?.bodyFat);
    muscleMassController.text =
        _formatInitialValue(widget.currentProfile?.muscleMass);
  }

  @override
  void dispose() {
    weightController.dispose();
    bodyFatController.dispose();
    muscleMassController.dispose();
    super.dispose();
  }

  String _formatInitialValue(double? value) {
    if (value == null) return '';

    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

  double? _parseDouble(String value) {
    final trimmed = value.trim().replaceAll(',', '.');

    if (trimmed.isEmpty) return null;

    return double.tryParse(trimmed);
  }

  DateTime _selectedDateTime() {
    final now = DateTime.now();

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      now.hour,
      now.minute,
      now.second,
    );
  }

  String _formatSelectedDate() {
    final day = selectedDate.day.toString().padLeft(2, '0');
    final month = selectedDate.month.toString().padLeft(2, '0');
    final year = selectedDate.year.toString();

    return '$day/$month/$year';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isAfter(now) ? now : selectedDate,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
              onSurface: AppColors.textMain,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    setState(() {
      selectedDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
      );
    });
  }

  Future<void> _saveLog() async {
    final weight = _parseDouble(weightController.text);
    final bodyFat = _parseDouble(bodyFatController.text);
    final muscleMass = _parseDouble(muscleMassController.text);
    final loggedAt = _selectedDateTime();

    setState(() {
      errorMessage = null;
    });

    if (weight == null) {
      setState(() {
        errorMessage = 'Introduce tu peso actual';
      });
      return;
    }

    if (weight <= 0) {
      setState(() {
        errorMessage = 'El peso debe ser mayor que 0';
      });
      return;
    }

    if (bodyFat != null && bodyFat < 0) {
      setState(() {
        errorMessage = 'La grasa corporal no puede ser negativa';
      });
      return;
    }

    if (muscleMass != null && muscleMass < 0) {
      setState(() {
        errorMessage = 'La masa muscular no puede ser negativa';
      });
      return;
    }

    if (loggedAt.isAfter(DateTime.now())) {
      setState(() {
        errorMessage = 'No puedes registrar datos en una fecha futura';
      });
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await _fitnessProgressService.createFitnessProgressLog(
        weight: weight,
        bodyFat: bodyFat,
        muscleMass: muscleMass,
        loggedAt: loggedAt,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registro físico guardado correctamente'),
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
        errorMessage = 'No se pudo guardar el registro físico';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatGoal(String? value) {
    if (value == null || value.trim().isEmpty) return 'Sin configurar';

    switch (value.trim().toUpperCase()) {
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
    final profile = widget.currentProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Añadir datos físicos',
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
              _IntroCard(
                goal: _formatGoal(profile?.goal),
              ),
              const SizedBox(height: 24),
              _DateCard(
                selectedDate: _formatSelectedDate(),
                onPickDate: _pickDate,
              ),
              const SizedBox(height: 18),
              _PhysicalLogFormCard(
                weightController: weightController,
                bodyFatController: bodyFatController,
                muscleMassController: muscleMassController,
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
                  onPressed: isLoading ? null : _saveLog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    elevation: 12,
                    shadowColor: AppColors.primary.withValues(alpha: 0.32),
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
                              'GUARDAR REGISTRO',
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
  const _IntroCard({
    required this.goal,
  });

  final String goal;

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal != 'Sin configurar';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.28),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.add_chart,
            color: AppColors.primary,
            size: 42,
          ),
          const SizedBox(height: 18),
          const Text(
            'Nuevo registro físico',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Puedes registrar datos de hoy o de una fecha anterior si se te olvidó apuntarlos.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.inputBorder,
                width: 0.7,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.flag_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  hasGoal ? goal : 'Sin objetivo configurado',
                  style: TextStyle(
                    color: hasGoal
                        ? AppColors.textMain
                        : AppColors.textMain.withValues(alpha: 0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontStyle: hasGoal ? FontStyle.normal : FontStyle.italic,
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

class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.selectedDate,
    required this.onPickDate,
  });

  final String selectedDate;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: InkWell(
        onTap: onPickDate,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.inputBorder,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FECHA DEL REGISTRO',
                      style: TextStyle(
                        color: AppColors.secondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      selectedDate,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'La hora se guardará automáticamente',
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_calendar,
                color: AppColors.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhysicalLogFormCard extends StatelessWidget {
  const _PhysicalLogFormCard({
    required this.weightController,
    required this.bodyFatController,
    required this.muscleMassController,
  });

  final TextEditingController weightController;
  final TextEditingController bodyFatController;
  final TextEditingController muscleMassController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          _PhysicalLogTextField(
            controller: weightController,
            label: 'Peso actual',
            hintText: 'Ej: 70',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _PhysicalLogTextField(
            controller: bodyFatController,
            label: 'Grasa corporal',
            hintText: 'Opcional · Ej: 15',
            suffix: '%',
            icon: Icons.percent,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          _PhysicalLogTextField(
            controller: muscleMassController,
            label: 'Masa muscular',
            hintText: 'Opcional · Ej: 58',
            suffix: 'kg',
            icon: Icons.fitness_center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}

class _PhysicalLogTextField extends StatelessWidget {
  const _PhysicalLogTextField({
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