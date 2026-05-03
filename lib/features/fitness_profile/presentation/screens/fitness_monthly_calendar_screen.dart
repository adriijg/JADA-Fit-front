import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_progress_model.dart';
import 'add_physical_log_screen.dart';

class FitnessMonthlyCalendarScreen extends StatefulWidget {
  const FitnessMonthlyCalendarScreen({
    super.key,
    required this.progress,
    required this.initialMonth,
  });

  final List<FitnessProgressModel> progress;
  final DateTime initialMonth;

  @override
  State<FitnessMonthlyCalendarScreen> createState() =>
      _FitnessMonthlyCalendarScreenState();
}

class _FitnessMonthlyCalendarScreenState
    extends State<FitnessMonthlyCalendarScreen> {
  late DateTime visibleMonth;
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();

    visibleMonth = DateTime(
      widget.initialMonth.year,
      widget.initialMonth.month,
    );
  }

  void _previousMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
      selectedDay = null;
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    if (!visibleMonth.isBefore(currentMonth)) return;

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
      selectedDay = null;
    });
  }

  bool get _canGoNextMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return visibleMonth.isBefore(currentMonth);
  }

  Future<void> _openAddLogForDay(DateTime day) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhysicalLogScreen(
          initialDate: day,
        ),
      ),
    );

    if (!mounted) return;

    if (created == true) {
      Navigator.pop(context, true);
    }
  }

  List<DateTime?> _monthCells() {
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final lastDay = DateTime(visibleMonth.year, visibleMonth.month + 1, 0);
    final leadingEmptyCells = firstDay.weekday - 1;

    final cells = <DateTime?>[];

    for (var i = 0; i < leadingEmptyCells; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= lastDay.day; day++) {
      cells.add(DateTime(visibleMonth.year, visibleMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  List<FitnessProgressModel> _recordsForDay(DateTime day) {
    return widget.progress.where((item) {
      final date = item.loggedAt;

      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  String _monthTitle() {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${months[visibleMonth.month - 1]} ${visibleMonth.year}';
  }

  String _formatDouble(double? value, String unit) {
    if (value == null) return '--';

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  bool _isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _monthCells();

    final selectedRecords = selectedDay == null
        ? <FitnessProgressModel>[]
        : _recordsForDay(selectedDay!);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Calendario mensual',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddLogForDay(selectedDay ?? DateTime.now());
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          child: Column(
            children: [
              _MonthlyCalendarCard(
                title: _monthTitle(),
                canGoNext: _canGoNextMonth,
                cells: cells,
                selectedDay: selectedDay,
                recordsForDay: _recordsForDay,
                isSameDay: _isSameDay,
                onPreviousMonth: _previousMonth,
                onNextMonth: _nextMonth,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                },
              ),
              const SizedBox(height: 20),
              if (selectedDay != null)
                _MonthlySelectedDayCard(
                  selectedDay: selectedDay!,
                  records: selectedRecords,
                  formatDouble: _formatDouble,
                  onAddRecord: () => _openAddLogForDay(selectedDay!),
                )
              else
                _NoDaySelectedCard(
                  onAddToday: () => _openAddLogForDay(DateTime.now()),
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlyCalendarCard extends StatelessWidget {
  const _MonthlyCalendarCard({
    required this.title,
    required this.canGoNext,
    required this.cells,
    required this.selectedDay,
    required this.recordsForDay,
    required this.isSameDay,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onDaySelected,
  });

  final String title;
  final bool canGoNext;
  final List<DateTime?> cells;
  final DateTime? selectedDay;
  final List<FitnessProgressModel> Function(DateTime day) recordsForDay;
  final bool Function(DateTime first, DateTime second) isSameDay;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDaySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.secondary,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: canGoNext ? onNextMonth : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoNext
                      ? AppColors.secondary
                      : AppColors.divider.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              _WeekdayHeader(label: 'L'),
              _WeekdayHeader(label: 'M'),
              _WeekdayHeader(label: 'X'),
              _WeekdayHeader(label: 'J'),
              _WeekdayHeader(label: 'V'),
              _WeekdayHeader(label: 'S'),
              _WeekdayHeader(label: 'D'),
            ],
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = cells[index];

              if (day == null) {
                return const SizedBox.shrink();
              }

              final records = recordsForDay(day);
              final hasRecords = records.isNotEmpty;
              final isSelected =
                  selectedDay != null && isSameDay(day, selectedDay!);

              return InkWell(
                onTap: () => onDaySelected(day),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : hasRecords
                            ? AppColors.inputBackground
                            : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasRecords
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : AppColors.divider.withValues(alpha: 0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        day.day.toString(),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.background
                              : AppColors.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (hasRecords)
                        Positioned(
                          bottom: 6,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.background
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
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

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.secondary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MonthlySelectedDayCard extends StatelessWidget {
  const _MonthlySelectedDayCard({
    required this.selectedDay,
    required this.records,
    required this.formatDouble,
    required this.onAddRecord,
  });

  final DateTime selectedDay;
  final List<FitnessProgressModel> records;
  final String Function(double?, String) formatDouble;
  final VoidCallback onAddRecord;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final sortedRecords = [...records]
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.event_available,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(selectedDay),
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      records.isEmpty
                          ? 'Sin registros físicos'
                          : '${records.length} registro${records.length == 1 ? '' : 's'} guardado${records.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAddRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'AÑADIR REGISTRO PARA ESTE DÍA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (records.isEmpty)
            const _EmptySelectedDay()
          else
            ...sortedRecords.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MonthlyRecordCard(
                  record: item,
                  formatDouble: formatDouble,
                  formatTime: _formatTime,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthlyRecordCard extends StatelessWidget {
  const _MonthlyRecordCard({
    required this.record,
    required this.formatDouble,
    required this.formatTime,
  });

  final FitnessProgressModel record;
  final String Function(double?, String) formatDouble;
  final String Function(DateTime) formatTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Registro físico',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.inputBorder,
                    width: 0.7,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatTime(record.loggedAt),
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MonthlyMetricBox(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Peso',
                  value: formatDouble(record.weight, 'kg'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MonthlyMetricBox(
                  icon: Icons.percent,
                  label: 'Grasa',
                  value: formatDouble(record.bodyFat, '%'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MonthlyMetricBox(
            icon: Icons.fitness_center,
            label: 'Masa muscular',
            value: formatDouble(record.muscleMass, 'kg'),
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

class _MonthlyMetricBox extends StatelessWidget {
  const _MonthlyMetricBox({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '--';

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty
                        ? AppColors.textMain.withValues(alpha: 0.45)
                        : AppColors.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
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

class _NoDaySelectedCard extends StatelessWidget {
  const _NoDaySelectedCard({
    required this.onAddToday,
  });

  final VoidCallback onAddToday;

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
          const Icon(
            Icons.touch_app,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(height: 14),
          const Text(
            'Selecciona un día',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pulsa un día del calendario para ver o añadir registros físicos.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onAddToday,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.primary,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                'AÑADIR REGISTRO DE HOY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySelectedDay extends StatelessWidget {
  const _EmptySelectedDay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 0.7,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.secondary,
            size: 30,
          ),
          SizedBox(height: 12),
          Text(
            'No hay registros para este día',
            style: TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Puedes añadir un registro usando el botón superior.',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}