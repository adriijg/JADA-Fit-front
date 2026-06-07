import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/fitness_progress_model.dart';
import 'add_physical_log_screen.dart';
import '../../../../l10n/app_localizations.dart';

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
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMM(locale).format(visibleMonth);
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
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          AppLocalizations.of(context)!.fitnessCalendarMonthly,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openAddLogForDay(selectedDay ?? DateTime.now());
        },
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.background,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
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
              SizedBox(height: 20),
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
              SizedBox(height: 80),
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
    return AppCard.elevated(
      borderRadius: 26,
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousMonth,
                icon: Icon(
                  Icons.chevron_left,
                  color: context.colors.secondary,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textMain,
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
                      ? context.colors.secondary
                      : context.colors.divider.withOpacity(0.55),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdayMon),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdayTue),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdayWed),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdayThu),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdayFri),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdaySat),
          _WeekdayHeader(label: AppLocalizations.of(context)!.weekdaySun),
            ],
          ),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final day = cells[index];

              if (day == null) {
                return SizedBox.shrink();
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
                        ? context.colors.primary
                        : hasRecords
                            ? context.colors.inputBackground
                            : context.colors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasRecords
                          ? context.colors.primary.withOpacity(0.7)
                          : context.colors.divider.withOpacity(0.4),
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
                              ? context.colors.background
                              : context.colors.textMain,
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
                                  ? context.colors.background
                                  : context.colors.primary,
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
        style: TextStyle(
          color: context.colors.secondary,
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

    return AppCard.elevated(
      borderRadius: 28,
      padding: EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppCardIcon(
                icon: Icons.event_available,
                size: 46,
                borderRadius: 16,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(selectedDay),
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      records.isEmpty
                          ? AppLocalizations.of(context)!.fitnessNoPhysicalRecords
                          : AppLocalizations.of(context)!.fitnessRecordsSaved(records.length),
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAddRecord,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: Icon(Icons.add),
              label: Text(
                AppLocalizations.of(context)!.fitnessAddRecordForDay,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ),
          SizedBox(height: 18),
          if (records.isEmpty)
            const _EmptySelectedDay()
          else
            ...sortedRecords.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12),
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
    return AppCard.primary(
      borderRadius: 22,
      padding: EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: context.colors.primary,
                size: 22,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.fitnessPhysicalRecord,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: context.colors.inputBorder,
                    width: 0.7,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: context.colors.secondary,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      formatTime(record.loggedAt),
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MonthlyMetricBox(
                  icon: Icons.monitor_weight_outlined,
                  label: AppLocalizations.of(context)!.fitnessWeightLabel,
                  value: formatDouble(record.weight, 'kg'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _MonthlyMetricBox(
                  icon: Icons.percent,
                  label: AppLocalizations.of(context)!.fitnessFatLabel,
                  value: formatDouble(record.bodyFat, '%'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _MonthlyMetricBox(
            icon: Icons.fitness_center,
            label: AppLocalizations.of(context)!.fitnessMuscleMass,
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
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: context.colors.primary,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: isEmpty
                        ? context.colors.textMain.withOpacity(0.45)
                        : context.colors.textMain,
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
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(22),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            color: context.colors.primary,
            size: 34,
          ),
          SizedBox(height: 14),
          Text(
            AppLocalizations.of(context)!.fitnessSelectDay,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.fitnessCalendarHint,
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onAddToday,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.primary,
                side: BorderSide(
                  color: context.colors.primary,
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: Icon(Icons.add),
              label: Text(
                AppLocalizations.of(context)!.fitnessAddTodayRecord,
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
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.inputBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.colors.inputBorder,
          width: 0.7,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: context.colors.secondary,
            size: 30,
          ),
          SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.fitnessNoRecordsThisDay,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.fitnessAddRecordUsingButton,
            style: TextStyle(
              color: context.colors.secondary,
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
