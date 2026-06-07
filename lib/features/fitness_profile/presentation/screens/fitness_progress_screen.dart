import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/unit_converter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../data/models/fitness_progress_model.dart';
import '../../data/services/fitness_progress_service.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../screens/add_physical_log_screen.dart';
import 'fitness_monthly_calendar_screen.dart';
import '../../../../l10n/app_localizations.dart';

class FitnessProgressScreen extends StatefulWidget {
  const FitnessProgressScreen({super.key});

  @override
  State<FitnessProgressScreen> createState() => _FitnessProgressScreenState();
}

class _FitnessProgressScreenState extends State<FitnessProgressScreen> {
  final FitnessProgressService _progressService = FitnessProgressService();

  bool isLoading = true;
  String? errorMessage;

  List<FitnessProgressModel> progress = [];

  _ProgressMetric selectedMetric = _ProgressMetric.weight;

  DateTime visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  bool _monthInitializedFromData = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await _progressService.getMyFitnessProgress()
        ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));

      if (!mounted) return;

      setState(() {
        progress = result;

        if (!_monthInitializedFromData && result.isNotEmpty) {
          final latest = result.last.loggedAt;
          visibleMonth = DateTime(latest.year, latest.month);
          _monthInitializedFromData = true;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage = AppLocalizations.of(context)!.fitnessLoadError;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddLog({DateTime? initialDate}) async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddPhysicalLogScreen(
          initialDate: initialDate,
        ),
      ),
    );

    if (created == true) {
      await _loadProgress();
    }
  }

  Future<void> _openMonthlyCalendar() async {
    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FitnessMonthlyCalendarScreen(
          progress: progress,
          initialMonth: visibleMonth,
        ),
      ),
    );

    if (shouldRefresh == true) {
      await _loadProgress();
    }
  }

  List<FitnessProgressModel> get _orderedProgress {
    final copy = [...progress];
    copy.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return copy;
  }

  List<FitnessProgressModel> get _visibleMonthRecords {
    return _orderedProgress.where((item) {
      return item.loggedAt.year == visibleMonth.year &&
          item.loggedAt.month == visibleMonth.month;
    }).toList();
  }

  List<_ChartPoint> _chartPointsForMetric(
    List<FitnessProgressModel> source,
    _ProgressMetric metric,
  ) {
    final points = <_ChartPoint>[];

    for (final item in source) {
      final value = _valueFromItem(item, metric);

      if (value != null) {
        points.add(
          _ChartPoint(
            date: item.loggedAt,
            value: value,
          ),
        );
      }
    }

    return points;
  }

  double? _valueFromItem(FitnessProgressModel item, _ProgressMetric metric) {
    switch (metric) {
      case _ProgressMetric.weight:
        return item.weight;
      case _ProgressMetric.bodyFat:
        return item.bodyFat;
      case _ProgressMetric.muscleMass:
        return item.muscleMass;
    }
  }

  double? _lastValueOverall(_ProgressMetric metric) {
    for (final item in _orderedProgress.reversed) {
      final value = _valueFromItem(item, metric);
      if (value != null) return value;
    }

    return null;
  }

  double? _firstValueOverall(_ProgressMetric metric) {
    for (final item in _orderedProgress) {
      final value = _valueFromItem(item, metric);
      if (value != null) return value;
    }

    return null;
  }

  double? _overallChange(_ProgressMetric metric) {
    final first = _firstValueOverall(metric);
    final last = _lastValueOverall(metric);

    if (first == null || last == null) return null;

    return last - first;
  }

  DateTime _referenceWeekDate() {
    final now = DateTime.now();

    if (visibleMonth.year == now.year && visibleMonth.month == now.month) {
      return now;
    }

    if (_visibleMonthRecords.isNotEmpty) {
      return _visibleMonthRecords.first.loggedAt;
    }

    return visibleMonth;
  }

  bool get _canGoNextMonth {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

    return visibleMonth.isBefore(currentMonth);
  }

  void _previousMonth() {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!_canGoNextMonth) return;

    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + 1);
    });
  }

  String _formatDouble(double? value, String unit, {bool imperial = false}) {
    if (value == null) return '--';
    if (unit == 'kg') {
      return UnitConverter.formatWeight(value, imperial);
    }
    if (unit == '%') return UnitConverter.formatBodyFat(value);

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  bool get _imperial => context.read<SettingsProvider>().isImperial;

  String _formatChange(double? value, String unit, {bool imperial = false}) {
    if (value == null) return '--';
    if (unit == 'kg') {
      return UnitConverter.formatWeightChange(value, imperial);
    }

    final sign = value > 0 ? '+' : '';

    if (value % 1 == 0) {
      return '$sign${value.toInt()} $unit';
    }

    return '$sign${value.toStringAsFixed(1)} $unit';
  }

  String _monthTitle(DateTime date) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return DateFormat.yMMMM(locale).format(date);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final latestWeight = _lastValueOverall(_ProgressMetric.weight);
    final weightChange = _overallChange(_ProgressMetric.weight);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(
          color: context.colors.textMain,
        ),
        title: Text(
          AppLocalizations.of(context)!.fitnessStats,
          style: TextStyle(
            color: context.colors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddLog(),
        backgroundColor: context.colors.primary,
        foregroundColor: context.colors.background,
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: context.colors.primary,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: _buildBody(
              latestWeight: latestWeight,
              weightChange: weightChange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required double? latestWeight,
    required double? weightChange,
  }) {
    if (isLoading) {
      return SizedBox(
        height: 500,
        child: Center(
          child: CircularProgressIndicator(
            color: context.colors.primary,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return SizedBox(
        height: 500,
        child: Center(
          child: _ErrorCard(
            message: errorMessage!,
            onRetry: _loadProgress,
          ),
        ),
      );
    }

    if (progress.isEmpty) {
      return _EmptyProgressCard(
        onAddRecord: () => _openAddLog(),
      );
    }

    final monthRecords = _visibleMonthRecords;
    final chartPoints = _chartPointsForMetric(monthRecords, selectedMetric);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProgressHeroCard(
          latestWeight: _formatDouble(latestWeight, 'kg', imperial: _imperial),
          weightChange: _formatChange(weightChange, 'kg', imperial: _imperial),
          totalRecords: progress.length,
          onAddRecord: () => _openAddLog(),
        ),
        SizedBox(height: 18),
        _MonthSelectorCard(
          title: _monthTitle(visibleMonth),
          canGoNext: _canGoNextMonth,
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
        SizedBox(height: 18),
        _MetricSelectorCard(
          selectedMetric: selectedMetric,
          onMetricSelected: (metric) {
            setState(() {
              selectedMetric = metric;
            });
          },
        ),
        SizedBox(height: 18),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            final velocity = details.primaryVelocity ?? 0;

            if (velocity > 250) {
              _previousMonth();
            }

            if (velocity < -250 && _canGoNextMonth) {
              _nextMonth();
            }
          },
          child: _SingleProgressChartCard(
            metric: selectedMetric,
            monthTitle: _monthTitle(visibleMonth),
            chartPoints: chartPoints,
          ),
        ),
        SizedBox(height: 24),
        _WeeklyCalendarCard(
          progress: progress,
          referenceDate: _referenceWeekDate(),
          formatDate: _formatDate,
          onAddRecordForDay: (day) => _openAddLog(initialDate: day),
        ),
        SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _openMonthlyCalendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: Icon(Icons.calendar_month),
            label: Text(
              AppLocalizations.of(context)!.fitnessViewMonthlyCalendar.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        SizedBox(height: 80),
      ],
    );
  }
}

class _ChartPoint {
  const _ChartPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;
}

enum _ProgressMetric {
  weight,
  bodyFat,
  muscleMass,
}

extension _ProgressMetricExtension on _ProgressMetric {
  String title(BuildContext context) {
    switch (this) {
      case _ProgressMetric.weight:
        return AppLocalizations.of(context)!.fitnessWeightLabel;
      case _ProgressMetric.bodyFat:
        return AppLocalizations.of(context)!.fitnessFatLabel;
      case _ProgressMetric.muscleMass:
        return AppLocalizations.of(context)!.fitnessMuscle;
    }
  }

  String fullTitle(BuildContext context) {
    switch (this) {
      case _ProgressMetric.weight:
        return AppLocalizations.of(context)!.fitnessWeightEvolution;
      case _ProgressMetric.bodyFat:
        return AppLocalizations.of(context)!.fitnessBodyFat;
      case _ProgressMetric.muscleMass:
        return AppLocalizations.of(context)!.fitnessMuscleMass;
    }
  }

  String subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (this) {
      case _ProgressMetric.weight:
        return l10n.fitnessWeightSubtitle;
      case _ProgressMetric.bodyFat:
        return l10n.fitnessFatSubtitle;
      case _ProgressMetric.muscleMass:
        return l10n.fitnessMuscleSubtitle;
    }
  }

  String get unit {
    switch (this) {
      case _ProgressMetric.weight:
        return 'kg';
      case _ProgressMetric.bodyFat:
        return '%';
      case _ProgressMetric.muscleMass:
        return 'kg';
    }
  }

  IconData get icon {
    switch (this) {
      case _ProgressMetric.weight:
        return Icons.monitor_weight_outlined;
      case _ProgressMetric.bodyFat:
        return Icons.percent;
      case _ProgressMetric.muscleMass:
        return Icons.fitness_center;
    }
  }
}

class _ProgressHeroCard extends StatelessWidget {
  const _ProgressHeroCard({
    required this.latestWeight,
    required this.weightChange,
    required this.totalRecords,
    required this.onAddRecord,
  });

  final String latestWeight;
  final String weightChange;
  final int totalRecords;
  final VoidCallback onAddRecord;

  @override
  Widget build(BuildContext context) {
    return AppCard.primary(
      borderRadius: 28,
      padding: EdgeInsets.all(26),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.inputBackground,
                  border: Border.all(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.show_chart,
                  color: context.colors.primary,
                  size: 42,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.fitnessProgress,
                      style: TextStyle(
                        color: context.colors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      latestWeight,
                      style: TextStyle(
                        color: context.colors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.fitnessTotalChange(weightChange),
                      style: TextStyle(
                        color: context.colors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.fitnessRecordsSaved(totalRecords),
                      style: TextStyle(
                        color: context.colors.textMain.withOpacity(0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
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
                AppLocalizations.of(context)!.fitnessAddRecord,
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

class _MonthSelectorCard extends StatelessWidget {
  const _MonthSelectorCard({
    required this.title,
    required this.canGoNext,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final bool canGoNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: Icon(
              Icons.chevron_left,
              color: context.colors.secondary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.fitnessSwipeChartHint,
                  style: TextStyle(
                    color: context.colors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: canGoNext ? onNext : null,
            icon: Icon(
              Icons.chevron_right,
              color: canGoNext
                  ? context.colors.secondary
                  : context.colors.divider.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSelectorCard extends StatelessWidget {
  const _MetricSelectorCard({
    required this.selectedMetric,
    required this.onMetricSelected,
  });

  final _ProgressMetric selectedMetric;
  final ValueChanged<_ProgressMetric> onMetricSelected;

  @override
  Widget build(BuildContext context) {
    return AppCard.elevated(
      borderRadius: 24,
      padding: EdgeInsets.all(10),
      child: Row(
        children: _ProgressMetric.values.map((metric) {
          final isSelected = metric == selectedMetric;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onMetricSelected(metric),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
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
                  child: Column(
                    children: [
                      Icon(
                        metric.icon,
                        color: isSelected
                            ? context.colors.background
                            : context.colors.primary,
                        size: 22,
                      ),
                      SizedBox(height: 7),
                      Text(
                        metric.title(context),
                        style: TextStyle(
                          color: isSelected
                              ? context.colors.background
                              : context.colors.textMain,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SingleProgressChartCard extends StatelessWidget {
  const _SingleProgressChartCard({
    required this.metric,
    required this.monthTitle,
    required this.chartPoints,
  });

  final _ProgressMetric metric;
  final String monthTitle;
  final List<_ChartPoint> chartPoints;

  double? get _latestValue {
    if (chartPoints.isEmpty) return null;
    return chartPoints.last.value;
  }

  double? get _changeValue {
    if (chartPoints.length < 2) return null;
    return chartPoints.last.value - chartPoints.first.value;
  }

  double? get _minValue {
    if (chartPoints.isEmpty) return null;

    return chartPoints
        .map((point) => point.value)
        .reduce((a, b) => a < b ? a : b);
  }

  double? get _maxValue {
    if (chartPoints.isEmpty) return null;

    return chartPoints
        .map((point) => point.value)
        .reduce((a, b) => a > b ? a : b);
  }

  String _formatDouble(double? value, String unit, {bool imperial = false}) {
    if (value == null) return '--';
    if (unit == 'kg') {
      return UnitConverter.formatWeight(value, imperial);
    }
    if (unit == '%') return UnitConverter.formatBodyFat(value);

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatChange(double? value, String unit, {bool imperial = false}) {
    if (value == null) return '--';
    if (unit == 'kg') {
      return UnitConverter.formatWeightChange(value, imperial);
    }

    final sign = value > 0 ? '+' : '';

    if (value % 1 == 0) {
      return '$sign${value.toInt()} $unit';
    }

    return '$sign${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughData = chartPoints.length >= 2;
    final imperial = context.watch<SettingsProvider>().isImperial;

    return AppCard.elevated(
      borderRadius: 26,
      padding: EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                metric.icon,
                color: context.colors.primary,
                size: 25,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.fullTitle(context),
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            '$monthTitle · ${metric.subtitle(context)}',
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: [
              _ChartMiniValue(
                label: AppLocalizations.of(context)!.fitnessCurrentLabel,
                value: _formatDouble(_latestValue, metric.unit, imperial: imperial),
              ),
              SizedBox(width: 12),
              _ChartMiniValue(
                label: AppLocalizations.of(context)!.fitnessChangeLabel,
                value: _formatChange(_changeValue, metric.unit, imperial: imperial),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              _ChartMiniValue(
                label: AppLocalizations.of(context)!.fitnessMin,
                value: _formatDouble(_minValue, metric.unit, imperial: imperial),
              ),
              SizedBox(width: 12),
              _ChartMiniValue(
                label: AppLocalizations.of(context)!.fitnessMax,
                value: _formatDouble(_maxValue, metric.unit, imperial: imperial),
              ),
            ],
          ),
          SizedBox(height: 22),
          if (hasEnoughData)
            SizedBox(
              height: 230,
              width: double.infinity,
              child: LineChart(
                _lineChartData(context, chartPoints, metric.unit),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.colors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.colors.inputBorder,
                  width: 0.7,
                ),
              ),
              child: Text(
                chartPoints.isEmpty
                    ? AppLocalizations.of(context)!.fitnessNoRecordsThisDay
                    : AppLocalizations.of(context)!.fitnessNeedTwoRecords,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _lineChartData(BuildContext context, List<_ChartPoint> points, String unit) {
    final spots = <FlSpot>[];

    for (var i = 0; i < points.length; i++) {
      spots.add(
        FlSpot(
          i.toDouble(),
          points[i].value,
        ),
      );
    }

    final values = points.map((point) => point.value).toList();

    final minYRaw = values.reduce((a, b) => a < b ? a : b);
    final maxYRaw = values.reduce((a, b) => a > b ? a : b);

    final range = maxYRaw - minYRaw;
    final padding = range == 0 ? 1.0 : range * 0.2;

    return LineChartData(
      minX: 0,
      maxX: (points.length - 1).toDouble(),
      minY: minYRaw - padding,
      maxY: maxYRaw + padding,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: context.colors.inputBorder,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval:
                points.length <= 5 ? 1 : (points.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();

              if (index < 0 || index >= points.length) {
                return SizedBox.shrink();
              }

              final date = points[index].date;

              return Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: context.colors.textMain.withOpacity(0.55),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(0),
                style: TextStyle(
                  color: context.colors.textMain.withOpacity(0.55),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => context.colors.inputBackground,
          tooltipRoundedRadius: 12,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.x.toInt();

              if (index < 0 || index >= points.length) {
                return null;
              }

              final date = points[index].date;

              return LineTooltipItem(
                '${date.day}/${date.month}\n${spot.y.toStringAsFixed(spot.y % 1 == 0 ? 0 : 1)} $unit',
                TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: context.colors.primary,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: context.colors.primary,
                strokeWidth: 3,
                strokeColor: context.colors.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: context.colors.primary.withOpacity(0.12),
          ),
        ),
      ],
    );
  }
}

class _ChartMiniValue extends StatelessWidget {
  const _ChartMiniValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isEmpty = value == '--';

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: context.colors.inputBorder,
            width: 0.7,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isEmpty
                    ? context.colors.textMain.withOpacity(0.45)
                    : context.colors.textMain,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: context.colors.secondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyCalendarCard extends StatelessWidget {
  const _WeeklyCalendarCard({
    required this.progress,
    required this.referenceDate,
    required this.formatDate,
    required this.onAddRecordForDay,
  });

  final List<FitnessProgressModel> progress;
  final DateTime referenceDate;
  final String Function(DateTime) formatDate;
  final ValueChanged<DateTime> onAddRecordForDay;

  List<DateTime> _weekDays() {
    final day = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    final monday = day.subtract(
      Duration(days: day.weekday - 1),
    );

    return List.generate(
      7,
      (index) => monday.add(Duration(days: index)),
    );
  }

  List<FitnessProgressModel> _recordsForDay(DateTime day) {
    return progress.where((item) {
      final date = item.loggedAt;

      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList()
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
  }

  String _weekdayLabel(int weekday, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (weekday) {
      case DateTime.monday:
        return l10n.weekdayMon;
      case DateTime.tuesday:
        return l10n.weekdayTue;
      case DateTime.wednesday:
        return l10n.weekdayWed;
      case DateTime.thursday:
        return l10n.weekdayThu;
      case DateTime.friday:
        return l10n.weekdayFri;
      case DateTime.saturday:
        return l10n.weekdaySat;
      case DateTime.sunday:
        return l10n.weekdaySun;
      default:
        return '';
    }
  }

  String _formatValue(double? value, String unit) {
    if (value == null) return '--';

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekDays();

    return AppCard.elevated(
      borderRadius: 26,
      padding: EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                color: context.colors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.fitnessCalendarWeekly,
                  style: TextStyle(
                    color: context.colors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.fitnessWeekOfRange(formatDate(days.first), formatDate(days.last)),
            style: TextStyle(
              color: context.colors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                onAddRecordForDay(DateTime.now());
              },
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
                AppLocalizations.of(context)!.fitnessAddRecord,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          SizedBox(height: 18),
          Row(
            children: days.map((day) {
              final records = _recordsForDay(day);
              final hasRecords = records.isNotEmpty;
              final latest = hasRecords ? records.first : null;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(28),
                          ),
                        ),
                        builder: (_) {
                          return _DayRecordsBottomSheet(
                            day: day,
                            records: records,
                            formatDate: formatDate,
                            onAddRecord: () {
                              Navigator.pop(context);
                              onAddRecordForDay(day);
                            },
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hasRecords
                            ? context.colors.primary
                            : context.colors.inputBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasRecords
                              ? context.colors.primary
                              : context.colors.inputBorder,
                          width: 0.7,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekdayLabel(day.weekday, context),
                            style: TextStyle(
                              color: hasRecords
                                  ? context.colors.background
                                  : context.colors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: hasRecords
                                  ? context.colors.background
                                  : context.colors.textMain,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 8),
                          Icon(
                            hasRecords
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            size: 15,
                            color: hasRecords
                                ? context.colors.background
                                : context.colors.secondary,
                          ),
                          if (latest != null) ...[
                            SizedBox(height: 8),
                            Text(
                              _formatValue(latest.weight, 'kg'),
                              style: TextStyle(
                                color: context.colors.background,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayRecordsBottomSheet extends StatelessWidget {
  const _DayRecordsBottomSheet({
    required this.day,
    required this.records,
    required this.formatDate,
    required this.onAddRecord,
  });

  final DateTime day;
  final List<FitnessProgressModel> records;
  final String Function(DateTime) formatDate;
  final VoidCallback onAddRecord;

  String _formatDouble(double? value, String unit, {bool imperial = false}) {
    if (value == null) return '--';
    if (unit == 'kg') {
      return UnitConverter.formatWeight(value, imperial);
    }
    if (unit == '%') return UnitConverter.formatBodyFat(value);

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
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
    final imperial = context.watch<SettingsProvider>().isImperial;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDate(day),
              style: TextStyle(
                color: context.colors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
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
            if (sortedRecords.isEmpty)
              Text(
                AppLocalizations.of(context)!.fitnessNoRecordsThisDay,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 13,
                ),
              )
            else
              ...sortedRecords.map(
                (item) => Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: context.colors.inputBorder,
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.fitnessRecordSummary(
                      _formatTime(item.loggedAt),
                      _formatDouble(item.weight, 'kg', imperial: imperial),
                      _formatDouble(item.bodyFat, '%'),
                      _formatDouble(item.muscleMass, 'kg', imperial: imperial),
                    ),
                    style: TextStyle(
                      color: context.colors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProgressCard extends StatelessWidget {
  const _EmptyProgressCard({
    required this.onAddRecord,
  });

  final VoidCallback onAddRecord;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Center(
        child: AppCard.elevated(
          borderRadius: 26,
          padding: EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart,
                color: context.colors.primary,
                size: 48,
              ),
              SizedBox(height: 18),
              Text(
                AppLocalizations.of(context)!.fitnessNoProgressData,
                style: TextStyle(
                  color: context.colors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.fitnessAddFirstDataHint,
                style: TextStyle(
                  color: context.colors.secondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
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
                    AppLocalizations.of(context)!.fitnessAddFirstRecord,
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
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 24,
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 42,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: context.colors.textMain,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: context.colors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.nutritionRetry,
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
