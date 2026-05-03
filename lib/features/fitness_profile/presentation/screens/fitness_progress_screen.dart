import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/fitness_progress_model.dart';
import '../../data/services/fitness_progress_service.dart';
import '../screens/add_physical_log_screen.dart';
import 'fitness_monthly_calendar_screen.dart';

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
        errorMessage = 'No se pudo cargar el progreso físico.';
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

  String _formatDouble(double? value, String unit) {
    if (value == null) return '--';

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatChange(double? value, String unit) {
    if (value == null) return '--';

    final sign = value > 0 ? '+' : '';

    if (value % 1 == 0) {
      return '$sign${value.toInt()} $unit';
    }

    return '$sign${value.toStringAsFixed(1)} $unit';
  }

  String _monthTitle(DateTime date) {
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

    return '${months[date.month - 1]} ${date.year}';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.textMain,
        ),
        title: const Text(
          'Estadísticas físicas',
          style: TextStyle(
            color: AppColors.textMain,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddLog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
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
      return const SizedBox(
        height: 500,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
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
          latestWeight: _formatDouble(latestWeight, 'kg'),
          weightChange: _formatChange(weightChange, 'kg'),
          totalRecords: progress.length,
          onAddRecord: () => _openAddLog(),
        ),
        const SizedBox(height: 18),
        _MonthSelectorCard(
          title: _monthTitle(visibleMonth),
          canGoNext: _canGoNextMonth,
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
        const SizedBox(height: 18),
        _MetricSelectorCard(
          selectedMetric: selectedMetric,
          onMetricSelected: (metric) {
            setState(() {
              selectedMetric = metric;
            });
          },
        ),
        const SizedBox(height: 18),
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
        const SizedBox(height: 24),
        _WeeklyCalendarCard(
          progress: progress,
          referenceDate: _referenceWeekDate(),
          formatDate: _formatDate,
          onAddRecordForDay: (day) => _openAddLog(initialDate: day),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _openMonthlyCalendar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.calendar_month),
            label: const Text(
              'VER CALENDARIO MENSUAL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 80),
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
  String get title {
    switch (this) {
      case _ProgressMetric.weight:
        return 'Peso';
      case _ProgressMetric.bodyFat:
        return 'Grasa';
      case _ProgressMetric.muscleMass:
        return 'Músculo';
    }
  }

  String get fullTitle {
    switch (this) {
      case _ProgressMetric.weight:
        return 'Evolución de peso';
      case _ProgressMetric.bodyFat:
        return 'Grasa corporal';
      case _ProgressMetric.muscleMass:
        return 'Masa muscular';
    }
  }

  String get subtitle {
    switch (this) {
      case _ProgressMetric.weight:
        return 'Peso registrado durante el mes seleccionado';
      case _ProgressMetric.bodyFat:
        return 'Porcentaje de grasa durante el mes seleccionado';
      case _ProgressMetric.muscleMass:
        return 'Masa muscular durante el mes seleccionado';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.35),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.inputBackground,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: AppColors.primary,
                  size: 42,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Progreso físico',
                      style: TextStyle(
                        color: AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      latestWeight,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cambio total: $weightChange',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalRecords registros guardados',
                      style: TextStyle(
                        color: AppColors.textMain.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                'AÑADIR REGISTRO FÍSICO',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
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
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.secondary,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Desliza la gráfica para cambiar de mes',
                  style: TextStyle(
                    color: AppColors.secondary,
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
                  ? AppColors.secondary
                  : AppColors.divider.withValues(alpha: 0.55),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Row(
        children: _ProgressMetric.values.map((metric) {
          final isSelected = metric == selectedMetric;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onMetricSelected(metric),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
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
                  child: Column(
                    children: [
                      Icon(
                        metric.icon,
                        color: isSelected
                            ? AppColors.background
                            : AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        metric.title,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.background
                              : AppColors.textMain,
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

  String _formatDouble(double? value, String unit) {
    if (value == null) return '--';

    if (value % 1 == 0) {
      return '${value.toInt()} $unit';
    }

    return '${value.toStringAsFixed(1)} $unit';
  }

  String _formatChange(double? value, String unit) {
    if (value == null) return '--';

    final sign = value > 0 ? '+' : '';

    if (value % 1 == 0) {
      return '$sign${value.toInt()} $unit';
    }

    return '$sign${value.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final hasEnoughData = chartPoints.length >= 2;

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                metric.icon,
                color: AppColors.primary,
                size: 25,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  metric.fullTitle,
                  style: const TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$monthTitle · ${metric.subtitle}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _ChartMiniValue(
                label: 'Actual',
                value: _formatDouble(_latestValue, metric.unit),
              ),
              const SizedBox(width: 12),
              _ChartMiniValue(
                label: 'Cambio',
                value: _formatChange(_changeValue, metric.unit),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ChartMiniValue(
                label: 'Mínimo',
                value: _formatDouble(_minValue, metric.unit),
              ),
              const SizedBox(width: 12),
              _ChartMiniValue(
                label: 'Máximo',
                value: _formatDouble(_maxValue, metric.unit),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (hasEnoughData)
            SizedBox(
              height: 230,
              width: double.infinity,
              child: LineChart(
                _lineChartData(chartPoints, metric.unit),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 170,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.inputBorder,
                  width: 0.7,
                ),
              ),
              child: Text(
                chartPoints.isEmpty
                    ? 'No hay registros para este mes'
                    : 'Necesitas al menos 2 registros para ver la gráfica',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _lineChartData(List<_ChartPoint> points, String unit) {
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
            color: AppColors.inputBorder,
            strokeWidth: 1,
          );
        },
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
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
                return const SizedBox.shrink();
              }

              final date = points[index].date;

              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  date.day.toString(),
                  style: TextStyle(
                    color: AppColors.textMain.withValues(alpha: 0.55),
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
                  color: AppColors.textMain.withValues(alpha: 0.55),
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
          getTooltipColor: (_) => AppColors.inputBackground,
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
                const TextStyle(
                  color: AppColors.primary,
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
          color: AppColors.primary,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 3,
                strokeColor: AppColors.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.12),
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 0.7,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isEmpty
                    ? AppColors.textMain.withValues(alpha: 0.45)
                    : AppColors.textMain,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.secondary,
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

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'L';
      case DateTime.tuesday:
        return 'M';
      case DateTime.wednesday:
        return 'X';
      case DateTime.thursday:
        return 'J';
      case DateTime.friday:
        return 'V';
      case DateTime.saturday:
        return 'S';
      case DateTime.sunday:
        return 'D';
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.calendar_view_week,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Calendario semanal',
                  style: TextStyle(
                    color: AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Semana del ${formatDate(days.first)} al ${formatDate(days.last)}',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {
                onAddRecordForDay(DateTime.now());
              },
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
                'AÑADIR REGISTRO',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: days.map((day) {
              final records = _recordsForDay(day);
              final hasRecords = records.isNotEmpty;
              final latest = hasRecords ? records.first : null;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: AppColors.surface,
                        shape: const RoundedRectangleBorder(
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: hasRecords
                            ? AppColors.primary
                            : AppColors.inputBackground,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hasRecords
                              ? AppColors.primary
                              : AppColors.inputBorder,
                          width: 0.7,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _weekdayLabel(day.weekday),
                            style: TextStyle(
                              color: hasRecords
                                  ? AppColors.background
                                  : AppColors.secondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day.day.toString(),
                            style: TextStyle(
                              color: hasRecords
                                  ? AppColors.background
                                  : AppColors.textMain,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            hasRecords
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            size: 15,
                            color: hasRecords
                                ? AppColors.background
                                : AppColors.secondary,
                          ),
                          if (latest != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _formatValue(latest.weight, 'kg'),
                              style: const TextStyle(
                                color: AppColors.background,
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

  String _formatDouble(double? value, String unit) {
    if (value == null) return '--';

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatDate(day),
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
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
            if (sortedRecords.isEmpty)
              const Text(
                'No hay registros para este día.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
              )
            else
              ...sortedRecords.map(
                (item) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.inputBorder,
                      width: 0.7,
                    ),
                  ),
                  child: Text(
                    '${_formatTime(item.loggedAt)} · ${_formatDouble(item.weight, 'kg')} · ${_formatDouble(item.bodyFat, '%')} grasa · ${_formatDouble(item.muscleMass, 'kg')} músculo',
                    style: const TextStyle(
                      color: AppColors.textMain,
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.divider.withValues(alpha: 0.4),
              width: 0.7,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.show_chart,
                color: AppColors.primary,
                size: 48,
              ),
              const SizedBox(height: 18),
              const Text(
                'Todavía no hay datos de progreso',
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Añade tus primeros datos físicos para empezar a ver tu evolución.',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
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
                    'AÑADIR PRIMER REGISTRO',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
          width: 0.7,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 42,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Reintentar',
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