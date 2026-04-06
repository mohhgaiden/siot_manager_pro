import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../controller/chart.dart';
import '../../../theme/app_theme.dart';

class GraphCard extends StatelessWidget {
  const GraphCard({
    super.key,
    required this.title,
    required this.color,
    required this.unit,
    required this.currentValue,
    required this.spots,
    required this.minY,
    required this.maxY,
    this.isBar = false,
  });

  final String title;
  final Color color;
  final String unit;
  final String currentValue;
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final bool isBar;

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Card header ─────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  '$currentValue$unit',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ─── Chart ───────────────────────────────────────────────────────
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: spots.length * 12.0,
                child:
                    isBar
                        ? _buildBarChart(spots, color, minY, maxY)
                        : _buildLineChart(spots, color, minY, maxY),
              ),
            ),
          ),
          const SizedBox(height: 4),

          // ─── Time labels ─────────────────────────────────────────────────
          _timeLabel(),
        ],
      ),
    );
  }

  Widget _timeLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('00:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text('06:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text('12:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text('18:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
        Text('24:00', style: TextStyle(fontSize: 9, color: AppTheme.textMuted)),
      ],
    );
  }

  // ─── Line chart ───────────────────────────────────────────────────────────

  Widget _buildLineChart(
    List<FlSpot> spots,
    Color color,
    double minY,
    double maxY,
  ) {
    final maxSpot = spots.reduce((a, b) => a.y > b.y ? a : b);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: spots.length.toDouble(),
        minY: minY,
        maxY: maxY,
        gridData: _gridData(minY, maxY),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipColor: (_) => const Color(0xFF1A1C20),
            getTooltipItems:
                (spots) =>
                    spots
                        .map(
                          (s) => LineTooltipItem(
                            _formatTooltip(s.x.toInt(), s.y),
                            _tooltipStyle,
                          ),
                        )
                        .toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, _) => spot.x == maxSpot.x,
              getDotPainter:
                  (_, __, ___, ____) => FlDotCirclePainter(
                    radius: 3.5,
                    color: color,
                    strokeWidth: 0,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [color.withOpacity(0.2), color.withOpacity(0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bar chart ────────────────────────────────────────────────────────────

  Widget _buildBarChart(
    List<FlSpot> spots,
    Color color,
    double minY,
    double maxY,
  ) {
    return BarChart(
      BarChartData(
        minY: minY,
        maxY: maxY,
        gridData: _gridData(minY, maxY),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipMargin: 12,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipColor: (_) => const Color(0xFF1A1C20),
            getTooltipItem:
                (group, _, rod, __) => BarTooltipItem(
                  _formatTooltip(group.x.toInt(), rod.toY),
                  _tooltipStyle,
                ),
          ),
        ),
        barGroups:
            spots
                .map(
                  (s) => BarChartGroupData(
                    x: s.x.toInt(),
                    barRods: [
                      BarChartRodData(
                        toY: s.y,
                        color: color.withOpacity(0.6),
                        width: 6,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                )
                .toList(),
      ),
    );
  }

  // ─── Shared grid data ─────────────────────────────────────────────────────

  FlGridData _gridData(double minY, double maxY) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: (maxY - minY) / 3,
      getDrawingHorizontalLine:
          (_) => const FlLine(color: AppTheme.border, strokeWidth: 1),
    );
  }

  // ─── Tooltip helper ───────────────────────────────────────────────────────

  String _formatTooltip(int index, double value) {
    if (index >= chartController.raw.length) return value.toStringAsFixed(1);
    final data = chartController.raw[index];
    final d = data.dateTime;
    final date =
        '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
    return '${value.toStringAsFixed(1)}\n$date  $time';
  }

  static const _tooltipStyle = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );
}
