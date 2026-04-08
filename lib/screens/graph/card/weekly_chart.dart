import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../controller/chart.dart';
import '../../../controller/home.dart';
import '../../../models/day.dart';
import '../../../theme/app_theme.dart';

// ─── Metric config ────────────────────────────────────────────────────────────

class _MetricConfig {
  final String key;
  final String label;
  final String unit;
  final Color color;

  const _MetricConfig({
    required this.key,
    required this.label,
    required this.unit,
    required this.color,
  });
}

// ─── Weekly grouped bar chart ─────────────────────────────────────────────────

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key});

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  static final _metrics = [
    if (homeController.access.value!.temperature == 1)
      const _MetricConfig(
        key: 'temperature',
        label: 'Température',
        unit: '°C',
        color: AppTheme.primary,
      ),
    if (homeController.access.value!.humidity == 1)
      const _MetricConfig(
        key: 'humidity',
        label: 'Humidité',
        unit: '%',
        color: AppTheme.blue,
      ),
    if (homeController.access.value!.illumination == 1)
      const _MetricConfig(
        key: 'illumination',
        label: 'Luminosité',
        unit: ' lx',
        color: AppTheme.amber,
      ),
    if (homeController.access.value!.pression == 1)
      const _MetricConfig(
        key: 'pression',
        label: 'Pression',
        unit: ' hPa',
        color: AppTheme.green,
      ),
    if (homeController.access.value!.voltage == 1)
      const _MetricConfig(
        key: 'voltage',
        label: 'Tension',
        unit: ' V',
        color: Color(0xFF9C27B0),
      ),
    if (homeController.access.value!.amperage == 1)
      const _MetricConfig(
        key: 'amperage',
        label: 'Ampérage',
        unit: ' A',
        color: Color(0xFFE91E63),
      ),
    if (homeController.access.value!.level == 1)
      const _MetricConfig(
        key: 'level',
        label: 'Niveau',
        unit: '',
        color: Color(0xFF607D8B),
      ),
  ];

  int _metricIndex = 0;

  static const _minColor = Color(0xFF64B5F6); // blue
  static const _avgColor = Color(0xFFF5A623); // orange
  static const _maxColor = Color(0xFF90A4AE); // grey

  _MetricConfig get _current => _metrics[_metricIndex];

  @override
  Widget build(BuildContext context) {
    final data = chartController.weeklyData;
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _current.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_current.label} (${_current.unit.trim()})',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              // ─── Metric switcher ──────────────────────────────────────
              PopupMenuButton<int>(
                initialValue: _metricIndex,
                onSelected: (i) => setState(() => _metricIndex = i),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Changer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
                itemBuilder:
                    (_) =>
                        _metrics
                            .asMap()
                            .entries
                            .map(
                              (e) => PopupMenuItem(
                                value: e.key,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: e.value.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e.value.label),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Legend ───────────────────────────────────────────────────
          Row(
            children: [
              _legendItem(_minColor, 'Min'),
              const SizedBox(width: 14),
              _legendItem(_avgColor, 'Moy'),
              const SizedBox(width: 14),
              _legendItem(_maxColor, 'Max'),
            ],
          ),

          const SizedBox(height: 14),

          // ─── Chart ────────────────────────────────────────────────────
          SizedBox(
            height: 200,
            child: ClipRect(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _computeMaxY(data),
                  minY: _computeMinY(data),
                  groupsSpace: 14,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => const Color(0xFF1A1C20),
                      tooltipRoundedRadius: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      tooltipPadding: const EdgeInsets.all(8),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final labels = ['Min', 'Moy', 'Max'];
                        final day = data[groupIndex];
                        return BarTooltipItem(
                          '${day.nameDay}\n${labels[rodIndex]}: ${rod.toY.toStringAsFixed(1)}${_current.unit}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    // ─── Bottom: day name + date ─────────────────────────
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (value, _) {
                          final i = value.toInt();
                          if (i < 0 || i >= data.length) {
                            return const SizedBox.shrink();
                          }
                          final day = data[i];
                          // Short day: "Mer" from "Mercredi"
                          final short =
                              day.nameDay.length >= 3
                                  ? day.nameDay.substring(0, 3)
                                  : day.nameDay;
                          // Short date: "04-01" from "2026-04-01"
                          final shortDate =
                              day.dateDay.length >= 10
                                  ? day.dateDay.substring(5)
                                  : day.dateDay;
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  short,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF555555),
                                  ),
                                ),
                                Text(
                                  shortDate,
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // ─── Left: values ─────────────────────────────────────
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        //reservedSize: 38,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 9,
                              color: Color(0xFF999999),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _computeInterval(data),
                    getDrawingHorizontalLine:
                        (_) => const FlLine(
                          color: AppTheme.border,
                          strokeWidth: 1,
                        ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildGroups(data),
                ),
                swapAnimationDuration: const Duration(milliseconds: 400),
                swapAnimationCurve: Curves.easeOutCubic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Build bar groups ─────────────────────────────────────────────────────

  List<BarChartGroupData> _buildGroups(List<DayGraphModel> data) {
    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final day = entry.value;
      final (min, avg, max) = day.values(_current.key);

      return BarChartGroupData(
        x: i,
        barRods: [
          _rod(min, _minColor),
          _rod(avg, _avgColor),
          _rod(max, _maxColor),
        ],
        barsSpace: 3,
      );
    }).toList();
  }

  BarChartRodData _rod(double value, Color color) {
    return BarChartRodData(
      toY: value,
      color: color,
      width: 9,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    );
  }

  // ─── Scale helpers ────────────────────────────────────────────────────────

  double _computeMaxY(List<DayGraphModel> data) {
    double max = double.negativeInfinity;
    for (final d in data) {
      final (_, _, mx) = d.values(_current.key);
      if (mx > max) max = mx;
    }
    return (max * 1.15).ceilToDouble();
  }

  double _computeMinY(List<DayGraphModel> data) {
    double min = double.infinity;
    for (final d in data) {
      final (mn, _, _) = d.values(_current.key);
      if (mn < min) min = mn;
    }
    final floor = (min * 0.9).floorToDouble();
    return floor < 0 ? floor : 0;
  }

  double _computeInterval(List<DayGraphModel> data) {
    final range = _computeMaxY(data) - _computeMinY(data);
    if (range <= 5) return 1;
    if (range <= 20) return 5;
    if (range <= 100) return 20;
    if (range <= 500) return 100;
    return 200;
  }

  // ─── Legend ───────────────────────────────────────────────────────────────

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF666666)),
        ),
      ],
    );
  }
}
