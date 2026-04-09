import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:siot_manager_pro/controller/home.dart';
import '../controller/report.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _metricIndex = 0;

  _MetricDef get _currentMetric => _metrics[_metricIndex];

  // ─── Metric configs ───────────────────────────────────────────────────────
  final _metrics = [
    if (homeController.access.value!.temperature == 1)
      _MetricDef(
        title: 'Température',
        unit: '°C',
        color: AppTheme.primary,
        icon: Icons.thermostat,
        avg: _getAvgTemp,
        max: _getMaxTemp,
        min: _getMinTemp,
      ),
    if (homeController.access.value!.humidity == 1)
      _MetricDef(
        title: 'Humidité',
        unit: '%',
        color: AppTheme.blue,
        icon: Icons.water_drop_outlined,
        avg: _getAvgHum,
        max: _getMaxHum,
        min: _getMinHum,
      ),
    if (homeController.access.value!.illumination == 1)
      _MetricDef(
        title: 'Luminosité',
        unit: ' lx',
        color: AppTheme.amber,
        icon: Icons.wb_sunny_outlined,
        avg: _getAvgLux,
        max: _getMaxLux,
        min: _getMinLux,
      ),
    if (homeController.access.value!.pression == 1)
      _MetricDef(
        title: 'Pression',
        unit: ' hPa',
        color: AppTheme.green,
        icon: Icons.compress,
        avg: _getAvgPress,
        max: _getMaxPress,
        min: _getMinPress,
      ),
    if (homeController.access.value!.voltage == 1)
      _MetricDef(
        title: 'Tension',
        unit: ' V',
        color: Color(0xFF9C27B0),
        icon: Icons.electrical_services,
        avg: _getAvgVolt,
        max: _getMaxVolt,
        min: _getMinVolt,
      ),
    if (homeController.access.value!.amperage == 1)
      _MetricDef(
        title: 'Ampérage',
        unit: ' A',
        color: Color(0xFFE91E63),
        icon: Icons.bolt,
        avg: _getAvgAmp,
        max: _getMaxAmp,
        min: _getMinAmp,
      ),
    if (homeController.access.value!.level == 1)
      _MetricDef(
        title: 'Niveau',
        unit: '',
        color: Color(0xFF607D8B),
        icon: Icons.bar_chart,
        avg: _getAvgLvl,
        max: _getMaxLvl,
        min: _getMinLvl,
      ),
  ];

  // ─── Static getters for const usage ──────────────────────────────────────
  static double _getAvgTemp(ReportModel r) => r.avgTemperature;
  static double _getMaxTemp(ReportModel r) => r.maxTemperature;
  static double _getMinTemp(ReportModel r) => r.minTemperature;
  static double _getAvgHum(ReportModel r) => r.avgHumidity;
  static double _getMaxHum(ReportModel r) => r.maxHumidity;
  static double _getMinHum(ReportModel r) => r.minHumidity;
  static double _getAvgLux(ReportModel r) => r.avgIllumination;
  static double _getMaxLux(ReportModel r) => r.maxIllumination;
  static double _getMinLux(ReportModel r) => r.minIllumination;
  static double _getAvgPress(ReportModel r) => r.avgPressure;
  static double _getMaxPress(ReportModel r) => r.maxPressure;
  static double _getMinPress(ReportModel r) => r.minPressure;
  static double _getAvgVolt(ReportModel r) => r.avgVoltage;
  static double _getMaxVolt(ReportModel r) => r.maxVoltage;
  static double _getMinVolt(ReportModel r) => r.minVoltage;
  static double _getAvgAmp(ReportModel r) => r.avgAmperage;
  static double _getMaxAmp(ReportModel r) => r.maxAmperage;
  static double _getMinAmp(ReportModel r) => r.minAmperage;
  static double _getAvgLvl(ReportModel r) => r.avgLevel;
  static double _getMaxLvl(ReportModel r) => r.maxLevel;
  static double _getMinLvl(ReportModel r) => r.minLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(context),
              Expanded(
                child:
                    reportController.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : _buildList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rapport',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _openTagPicker,
                  child: Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reportController.selectedSpace.value.isEmpty
                              ? 'Sélectionner une chambre'
                              : reportController.selectedSpace.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onTap: _openMonthYearPicker,
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Month/year picker ────────────────────────────────────────────────────
  void _openMonthYearPicker() {
    int tempYear = reportController.selectedYear.value;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Sélectionner mois & année',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _yearBtn(
                        DateTime.now().year - 1,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                      const SizedBox(width: 10),
                      _yearBtn(
                        DateTime.now().year,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, index) {
                      final month = index + 1;
                      final date = DateTime(tempYear, month);
                      final isDisabled =
                          date.isBefore(DateTime(2025, 3)) ||
                          date.isAfter(DateTime.now());
                      final isSelected =
                          month == reportController.selectedMonth.value &&
                          tempYear == reportController.selectedYear.value;

                      return GestureDetector(
                        onTap:
                            isDisabled
                                ? null
                                : () {
                                  reportController.setMouth(tempYear, month);
                                  final space = homeController.rooms
                                      .firstWhereOrNull(
                                        (e) =>
                                            e.spaceName ==
                                            reportController
                                                .selectedSpace
                                                .value,
                                      );
                                  if (space != null) {
                                    reportController.getReports(
                                      space.spaceUuid,
                                    );
                                  }
                                  Get.back();
                                },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isDisabled
                                    ? Colors.grey.shade300
                                    : isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDisabled
                                        ? Colors.grey
                                        : isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _yearBtn(int year, int selectedYear, Function(int) onTap) {
    final isActive = selectedYear == year;
    return GestureDetector(
      onTap: () => onTap(year),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          year.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return months[m - 1];
  }

  // ─── List ─────────────────────────────────────────────────────────────────
  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (reportController.reports.isEmpty) {
        return const Center(
          child: Text(
            'Aucun rapport disponible',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ─── Summary cards ───────────────────────────────────────────
          _buildSummaryCards(),
          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildMetricSection(
              key: ValueKey(_metricIndex),
              metric: _currentMetric,
              reports: reportController.reports,
            ),
          ),

          const SizedBox(height: 16),
          _buildExportButton(context),
        ],
      );
    });
  }

  // ─── Room picker ──────────────────────────────────────────────────────────
  void _openTagPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: homeController.rooms.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final room = homeController.rooms[index];
              return ListTile(
                title: Text(room.spaceName),
                trailing:
                    reportController.selectedSpace.value == room.spaceName
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                onTap: () => reportController.selectRoom(room),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Summary cards ────────────────────────────────────────────────────────
  Widget _buildSummaryCards() {
    return Obx(
      () => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statCard(
            'Mesures totales',
            reportController.mesures.value.toStringAsFixed(0),
            AppTheme.primary,
            Icons.sensors,
          ),
          _statCard(
            'Alertes',
            reportController.alerts.value.toStringAsFixed(0),
            AppTheme.red,
            Icons.warning_amber_rounded,
          ),
          _statCard(
            'Capteurs actifs',
            reportController.tags.value.toStringAsFixed(0),
            AppTheme.green,
            Icons.check_circle_outline,
          ),
          _statCard(
            'Dernière maj',
            reportController.uptime.value.split(' ').last.substring(0, 5),
            AppTheme.blue,
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Metric section with min/avg/max bars ─────────────────────────────────
  Widget _buildMetricSection({
    required ValueKey<int> key,
    required _MetricDef metric,
    required List<ReportModel> reports,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section header ────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, size: 14, color: metric.color),
              ),
              const SizedBox(width: 8),
              Text(
                '${_currentMetric.title} (${_currentMetric.unit.trim()})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Spacer(),
              // ✅ SAME BUTTON AS WEEKLY
              PopupMenuButton<int>(
                initialValue: _metricIndex,
                onSelected: (i) => setState(() => _metricIndex = i),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                                    Text(e.value.title),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Legend row ────────────────────────────────────────────
          Row(
            children: [
              _legendDot(metric.color.withOpacity(0.4), 'Min'),
              const SizedBox(width: 12),
              _legendDot(metric.color, 'Moy'),
              const SizedBox(width: 12),
              _legendDot(metric.color.withOpacity(0.7), 'Max'),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Bars per week ─────────────────────────────────────────
          ...reports.map((r) {
            final avgVal = metric.avg(r);
            final maxVal = metric.max(r);
            final minVal = metric.min(r);

            // Global max for normalizing bar widths
            final globalMax = reports
                .map(metric.max)
                .reduce((a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week label
                  Text(
                    r.week,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ─── Min bar ────────────────────────────────────
                  _metricBar(
                    label: 'Min',
                    value: minVal,
                    globalMax: globalMax,
                    color: metric.color.withOpacity(0.4),
                    unit: metric.unit,
                  ),
                  const SizedBox(height: 3),

                  // ─── Avg bar ────────────────────────────────────
                  _metricBar(
                    label: 'Moy',
                    value: avgVal,
                    globalMax: globalMax,
                    color: metric.color,
                    unit: metric.unit,
                  ),
                  const SizedBox(height: 3),

                  // ─── Max bar ────────────────────────────────────
                  _metricBar(
                    label: 'Max',
                    value: maxVal,
                    globalMax: globalMax,
                    color: metric.color.withOpacity(0.7),
                    unit: metric.unit,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _metricBar({
    required String label,
    required double value,
    required double globalMax,
    required Color color,
    required String unit,
  }) {
    final ratio = globalMax <= 0 ? 0.0 : (value / globalMax).clamp(0.0, 1.0);

    return Row(
      children: [
        // Label
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(width: 6),
        // Bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Value
        SizedBox(
          width: 48,
          child: Text(
            '${value.toStringAsFixed(1)}${unit.trim()}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // ─── Export button ────────────────────────────────────────────────────────
  Widget _buildExportButton(BuildContext ctx) {
    return ElevatedButton.icon(
      onPressed: reportController.reports.isEmpty ? null : exportAdvancedPdf,
      icon: const Icon(Icons.download_outlined, size: 18),
      label: const Text('Exporter en PDF'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  // ─── PDF export ───────────────────────────────────────────────────────────
  Future<void> exportAdvancedPdf() async {
    final font = await rootBundle.load('assets/fonts/Roboto-Thin.ttf');
    final ttf = pw.Font.ttf(font);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: ttf, bold: ttf));

    final reports = reportController.reports;
    final logo = await imageFromAssetBundle('assets/images/login/logo.png');

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              // ─── Header ─────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SIOT Manager',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Rapport — ${reportController.selectedSpace.value}',
                      ),
                      pw.Text(
                        '${_monthName(reportController.selectedMonth.value)} ${reportController.selectedYear.value}',
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ─── Summary ────────────────────────────────────────────
              pw.Text(
                'Résumé',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfStat(
                    'Mesures',
                    reportController.mesures.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Alertes',
                    reportController.alerts.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Capteurs',
                    reportController.tags.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Dernière maj',
                    reportController.uptime.value.split(' ').last,
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ─── Table per metric ────────────────────────────────────
              ..._metrics.map((m) => _pdfMetricTable(m, reports)),
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  pw.Widget _pdfMetricTable(_MetricDef metric, List<ReportModel> reports) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 14),
        pw.Text(
          metric.title,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell('Semaine'),
                _cell('Min${metric.unit}'),
                _cell('Moy${metric.unit}'),
                _cell('Max${metric.unit}'),
              ],
            ),
            // Data rows
            ...reports.map(
              (r) => pw.TableRow(
                children: [
                  _cell(r.week),
                  _cell(metric.min(r).toStringAsFixed(1)),
                  _cell(metric.avg(r).toStringAsFixed(1)),
                  _cell(metric.max(r).toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfStat(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}

// ─── Metric definition ────────────────────────────────────────────────────────

class _MetricDef {
  final String title;
  final String unit;
  final Color color;
  final IconData icon;
  final double Function(ReportModel) avg;
  final double Function(ReportModel) max;
  final double Function(ReportModel) min;

  const _MetricDef({
    required this.title,
    required this.unit,
    required this.color,
    required this.icon,
    required this.avg,
    required this.max,
    required this.min,
  });
}

/*import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:siot_manager_pro/controller/home.dart';
import '../controller/report.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  // ─── Metric configs ───────────────────────────────────────────────────────
  static const _metrics = [
    _MetricDef(
      title: 'Température',
      unit: '°C',
      color: AppTheme.primary,
      icon: Icons.thermostat,
      avg: _getAvgTemp,
      max: _getMaxTemp,
      min: _getMinTemp,
    ),
    _MetricDef(
      title: 'Humidité',
      unit: '%',
      color: AppTheme.blue,
      icon: Icons.water_drop_outlined,
      avg: _getAvgHum,
      max: _getMaxHum,
      min: _getMinHum,
    ),
    _MetricDef(
      title: 'Luminosité',
      unit: ' lx',
      color: AppTheme.amber,
      icon: Icons.wb_sunny_outlined,
      avg: _getAvgLux,
      max: _getMaxLux,
      min: _getMinLux,
    ),
    _MetricDef(
      title: 'Pression',
      unit: ' hPa',
      color: AppTheme.green,
      icon: Icons.compress,
      avg: _getAvgPress,
      max: _getMaxPress,
      min: _getMinPress,
    ),
    _MetricDef(
      title: 'Tension',
      unit: ' V',
      color: Color(0xFF9C27B0),
      icon: Icons.electrical_services,
      avg: _getAvgVolt,
      max: _getMaxVolt,
      min: _getMinVolt,
    ),
    _MetricDef(
      title: 'Ampérage',
      unit: ' A',
      color: Color(0xFFE91E63),
      icon: Icons.bolt,
      avg: _getAvgAmp,
      max: _getMaxAmp,
      min: _getMinAmp,
    ),
    _MetricDef(
      title: 'Niveau',
      unit: '',
      color: Color(0xFF607D8B),
      icon: Icons.bar_chart,
      avg: _getAvgLvl,
      max: _getMaxLvl,
      min: _getMinLvl,
    ),
  ];

  // ─── Static getters for const usage ──────────────────────────────────────
  static double _getAvgTemp(ReportModel r) => r.avgTemperature;
  static double _getMaxTemp(ReportModel r) => r.maxTemperature;
  static double _getMinTemp(ReportModel r) => r.minTemperature;
  static double _getAvgHum(ReportModel r) => r.avgHumidity;
  static double _getMaxHum(ReportModel r) => r.maxHumidity;
  static double _getMinHum(ReportModel r) => r.minHumidity;
  static double _getAvgLux(ReportModel r) => r.avgIllumination;
  static double _getMaxLux(ReportModel r) => r.maxIllumination;
  static double _getMinLux(ReportModel r) => r.minIllumination;
  static double _getAvgPress(ReportModel r) => r.avgPressure;
  static double _getMaxPress(ReportModel r) => r.maxPressure;
  static double _getMinPress(ReportModel r) => r.minPressure;
  static double _getAvgVolt(ReportModel r) => r.avgVoltage;
  static double _getMaxVolt(ReportModel r) => r.maxVoltage;
  static double _getMinVolt(ReportModel r) => r.minVoltage;
  static double _getAvgAmp(ReportModel r) => r.avgAmperage;
  static double _getMaxAmp(ReportModel r) => r.maxAmperage;
  static double _getMinAmp(ReportModel r) => r.minAmperage;
  static double _getAvgLvl(ReportModel r) => r.avgLevel;
  static double _getMaxLvl(ReportModel r) => r.maxLevel;
  static double _getMinLvl(ReportModel r) => r.minLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(context),
              Expanded(
                child:
                    reportController.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : _buildList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rapport',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: _openTagPicker,
                  child: Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reportController.selectedSpace.value.isEmpty
                              ? 'Sélectionner une chambre'
                              : reportController.selectedSpace.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onTap: _openMonthYearPicker,
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Month/year picker ────────────────────────────────────────────────────

  void _openMonthYearPicker() {
    int tempYear = reportController.selectedYear.value;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Sélectionner mois & année',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _yearBtn(
                        DateTime.now().year - 1,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                      const SizedBox(width: 10),
                      _yearBtn(
                        DateTime.now().year,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, index) {
                      final month = index + 1;
                      final date = DateTime(tempYear, month);
                      final isDisabled =
                          date.isBefore(DateTime(2025, 3)) ||
                          date.isAfter(DateTime.now());
                      final isSelected =
                          month == reportController.selectedMonth.value &&
                          tempYear == reportController.selectedYear.value;

                      return GestureDetector(
                        onTap:
                            isDisabled
                                ? null
                                : () {
                                  reportController.setMouth(tempYear, month);
                                  final space = homeController.rooms
                                      .firstWhereOrNull(
                                        (e) =>
                                            e.spaceName ==
                                            reportController
                                                .selectedSpace
                                                .value,
                                      );
                                  if (space != null) {
                                    reportController.getReports(
                                      space.spaceUuid,
                                    );
                                  }
                                  Get.back();
                                },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isDisabled
                                    ? Colors.grey.shade300
                                    : isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDisabled
                                        ? Colors.grey
                                        : isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _yearBtn(int year, int selectedYear, Function(int) onTap) {
    final isActive = selectedYear == year;
    return GestureDetector(
      onTap: () => onTap(year),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          year.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return months[m - 1];
  }

  // ─── List ─────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (reportController.reports.isEmpty) {
        return const Center(
          child: Text(
            'Aucun rapport disponible',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          // ─── Summary cards ───────────────────────────────────────────
          _buildSummaryCards(),
          const SizedBox(height: 16),

          // ─── All metric sections ─────────────────────────────────────
          ..._metrics.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMetricSection(
                metric: m,
                reports: reportController.reports,
              ),
            ),
          ),

          const SizedBox(height: 4),
          _buildExportButton(context),
        ],
      );
    });
  }

  // ─── Room picker ──────────────────────────────────────────────────────────

  void _openTagPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: homeController.rooms.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final room = homeController.rooms[index];
              return ListTile(
                title: Text(room.spaceName),
                trailing:
                    reportController.selectedSpace.value == room.spaceName
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                onTap: () => reportController.selectRoom(room),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Summary cards ────────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    return Obx(
      () => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statCard(
            'Mesures totales',
            reportController.mesures.value.toStringAsFixed(0),
            AppTheme.primary,
            Icons.sensors,
          ),
          _statCard(
            'Alertes',
            reportController.alerts.value.toStringAsFixed(0),
            AppTheme.red,
            Icons.warning_amber_rounded,
          ),
          _statCard(
            'Capteurs actifs',
            reportController.tags.value.toStringAsFixed(0),
            AppTheme.green,
            Icons.check_circle_outline,
          ),
          _statCard(
            'Dernière maj',
            reportController.uptime.value.split(' ').last.substring(0, 5),
            AppTheme.blue,
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Metric section with min/avg/max bars ─────────────────────────────────

  Widget _buildMetricSection({
    required _MetricDef metric,
    required List<ReportModel> reports,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Section header ────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: metric.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(metric.icon, size: 14, color: metric.color),
              ),
              const SizedBox(width: 8),
              Text(
                metric.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Legend row ────────────────────────────────────────────
          Row(
            children: [
              _legendDot(metric.color.withOpacity(0.4), 'Min'),
              const SizedBox(width: 12),
              _legendDot(metric.color, 'Moy'),
              const SizedBox(width: 12),
              _legendDot(metric.color.withOpacity(0.7), 'Max'),
            ],
          ),

          const SizedBox(height: 10),

          // ─── Bars per week ─────────────────────────────────────────
          ...reports.map((r) {
            final avgVal = metric.avg(r);
            final maxVal = metric.max(r);
            final minVal = metric.min(r);

            // Global max for normalizing bar widths
            final globalMax = reports
                .map(metric.max)
                .reduce((a, b) => a > b ? a : b);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week label
                  Text(
                    r.week,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // ─── Min bar ────────────────────────────────────
                  _metricBar(
                    label: 'Min',
                    value: minVal,
                    globalMax: globalMax,
                    color: metric.color.withOpacity(0.4),
                    unit: metric.unit,
                  ),
                  const SizedBox(height: 3),

                  // ─── Avg bar ────────────────────────────────────
                  _metricBar(
                    label: 'Moy',
                    value: avgVal,
                    globalMax: globalMax,
                    color: metric.color,
                    unit: metric.unit,
                  ),
                  const SizedBox(height: 3),

                  // ─── Max bar ────────────────────────────────────
                  _metricBar(
                    label: 'Max',
                    value: maxVal,
                    globalMax: globalMax,
                    color: metric.color.withOpacity(0.7),
                    unit: metric.unit,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _metricBar({
    required String label,
    required double value,
    required double globalMax,
    required Color color,
    required String unit,
  }) {
    final ratio = globalMax <= 0 ? 0.0 : (value / globalMax).clamp(0.0, 1.0);

    return Row(
      children: [
        // Label
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
          ),
        ),
        const SizedBox(width: 6),
        // Bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppTheme.background,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Value
        SizedBox(
          width: 48,
          child: Text(
            '${value.toStringAsFixed(1)}${unit.trim()}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  // ─── Export button ────────────────────────────────────────────────────────

  Widget _buildExportButton(BuildContext ctx) {
    return ElevatedButton.icon(
      onPressed: reportController.reports.isEmpty ? null : exportAdvancedPdf,
      icon: const Icon(Icons.download_outlined, size: 18),
      label: const Text('Exporter en PDF'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  // ─── PDF export ───────────────────────────────────────────────────────────

  Future<void> exportAdvancedPdf() async {
    final font = await rootBundle.load('assets/fonts/Roboto-Thin.ttf');
    final ttf = pw.Font.ttf(font);
    final pdf = pw.Document(theme: pw.ThemeData.withFont(base: ttf, bold: ttf));

    final reports = reportController.reports;
    final logo = await imageFromAssetBundle('assets/images/login/logo.png');

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => [
              // ─── Header ─────────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: 60),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'SIOT Manager',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Rapport — ${reportController.selectedSpace.value}',
                      ),
                      pw.Text(
                        '${_monthName(reportController.selectedMonth.value)} ${reportController.selectedYear.value}',
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ─── Summary ────────────────────────────────────────────
              pw.Text(
                'Résumé',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _pdfStat(
                    'Mesures',
                    reportController.mesures.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Alertes',
                    reportController.alerts.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Capteurs',
                    reportController.tags.value.toStringAsFixed(0),
                  ),
                  _pdfStat(
                    'Dernière maj',
                    reportController.uptime.value.split(' ').last,
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // ─── Table per metric ────────────────────────────────────
              ..._metrics.map((m) => _pdfMetricTable(m, reports)),
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  pw.Widget _pdfMetricTable(_MetricDef metric, List<ReportModel> reports) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 14),
        pw.Text(
          metric.title,
          style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _cell('Semaine'),
                _cell('Min${metric.unit}'),
                _cell('Moy${metric.unit}'),
                _cell('Max${metric.unit}'),
              ],
            ),
            // Data rows
            ...reports.map(
              (r) => pw.TableRow(
                children: [
                  _cell(r.week),
                  _cell(metric.min(r).toStringAsFixed(1)),
                  _cell(metric.avg(r).toStringAsFixed(1)),
                  _cell(metric.max(r).toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _pdfStat(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 10)),
    );
  }
}

// ─── Metric definition ────────────────────────────────────────────────────────

class _MetricDef {
  final String title;
  final String unit;
  final Color color;
  final IconData icon;
  final double Function(ReportModel) avg;
  final double Function(ReportModel) max;
  final double Function(ReportModel) min;

  const _MetricDef({
    required this.title,
    required this.unit,
    required this.color,
    required this.icon,
    required this.avg,
    required this.max,
    required this.min,
  });
}
*/

/*import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:siot_manager_pro/controller/home.dart';
import '../controller/report.dart';
import '../models/report.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(context),
              Expanded(
                child:
                    reportController.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : _buildList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rapport',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                // ✅ Sensor selector dropdown
                GestureDetector(
                  onTap: _openTagPicker,
                  child: Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          reportController.selectedSpace.value.isEmpty
                              ? 'Sélectionner une chambre'
                              : reportController.selectedSpace.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onTap: _openMonthYearPicker,
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _openMonthYearPicker() {
    int tempYear = reportController.selectedYear.value;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              'Sélectionner mois & année',
              textAlign: TextAlign.center,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── YEAR SELECTOR ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _yearBtn(
                        DateTime.now().year - 1,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                      const SizedBox(width: 10),
                      _yearBtn(
                        DateTime.now().year,
                        tempYear,
                        (y) => setState(() => tempYear = y),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── MONTH GRID ───
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 12,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemBuilder: (_, index) {
                      final month = index + 1;
                      final date = DateTime(tempYear, month);

                      final isDisabled =
                          date.isBefore(DateTime(2025, 3)) ||
                          date.isAfter(DateTime.now());

                      final isSelected =
                          month == reportController.selectedMonth.value &&
                          tempYear == reportController.selectedYear.value;

                      return GestureDetector(
                        onTap:
                            isDisabled
                                ? null
                                : () {
                                  reportController.setMouth(tempYear, month);

                                  final space = homeController.rooms
                                      .firstWhereOrNull(
                                        (e) =>
                                            e.spaceName ==
                                            reportController
                                                .selectedSpace
                                                .value,
                                      );

                                  if (space != null) {
                                    reportController.getReports(
                                      space.spaceUuid,
                                    );
                                  }

                                  Get.back();
                                },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isDisabled
                                    ? Colors.grey.shade300
                                    : isSelected
                                    ? AppTheme.primary
                                    : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              _monthName(month),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDisabled
                                        ? Colors.grey
                                        : isSelected
                                        ? Colors.white
                                        : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _yearBtn(int year, int selectedYear, Function(int) onTap) {
    final isActive = selectedYear == year;

    return GestureDetector(
      onTap: () => onTap(year),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          year.toString(),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Jun',
      'Jul',
      'Aoû',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return months[m - 1];
  }

  Widget _buildList(BuildContext context) {
    return Obx(() {
      if (reportController.reports.isEmpty) {
        return const Center(
          child: Text(
            'Aucun report disponible',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        );
      }
      return ListView(
        padding: const EdgeInsets.all(14),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 12),
          _buildBarSection(
            title: 'Température moyenne',
            data: _buildData(reportController.reports, (r) => r.avgTemperature),
            color: AppTheme.primary,
            unit: '°',
          ),
          const SizedBox(height: 12),
          _buildBarSection(
            title: 'Humidité moyenne',
            data: _buildData(reportController.reports, (r) => r.avgHumidity),
            color: AppTheme.blue,
            unit: '%',
          ),
          const SizedBox(height: 16),
          _buildExportButton(context),
        ],
      );
    });
  }

  // ─── Tag picker bottom sheet ──────────────────────────────────────────────
  void _openTagPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(
          () => ListView.separated(
            shrinkWrap: true,
            itemCount: homeController.rooms.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final room = homeController.rooms[index];
              return ListTile(
                title: Text(room.spaceName),
                trailing:
                    reportController.selectedSpace.value == room.spaceName
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                onTap: () => reportController.selectRoom(room),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(
      () => GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _statCard(
            'Mesures totales',
            reportController.mesures.value.toStringAsFixed(0),
            AppTheme.primary,
            Icons.sensors,
          ),
          _statCard(
            'Alertes',
            reportController.alerts.value.toStringAsFixed(0),
            AppTheme.red,
            Icons.warning_amber_rounded,
          ),
          _statCard(
            'Capteurs actifs',
            reportController.tags.value.toStringAsFixed(0),
            AppTheme.green,
            Icons.check_circle_outline,
          ),
          _statCard(
            'Dernière maj',
            reportController.uptime.value.split(' ').last.substring(0, 5),
            AppTheme.blue,
            Icons.access_time,
          ),
          /*_statCard(
            'Uptime',
            '${reportController.uptime.value.toStringAsFixed(1)}%',
            AppTheme.blue,
            Icons.trending_up,
          ),*/
        ],
      ),
    );
  }

  Widget _buildBarSection({
    required String title,
    required List<(String, double, num)> data,
    required Color color,
    required String unit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...data.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    row.$1,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: row.$3.toDouble(),
                        minHeight: 8,
                        backgroundColor: AppTheme.background,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${row.$2.toStringAsFixed(1)}$unit',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(BuildContext ctx) {
    return ElevatedButton.icon(
      onPressed: reportController.reports.isEmpty ? null : exportAdvancedPdf,
      icon: const Icon(Icons.download_outlined, size: 18),
      label: const Text('Exporter en PDF'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
      ),
    );
  }

  List<(String, double, num)> _buildData(
    List<ReportModel> reports,
    double Function(ReportModel r) selector,
  ) {
    if (reports.isEmpty) return [];

    final max = reports.map(selector).reduce((a, b) => a > b ? a : b);

    return reports.map((r) {
      final val = selector(r);
      return (r.week, val, max == 0 ? 0 : val / max);
    }).toList();
  }

  Future<void> exportAdvancedPdf() async {
    final font = await rootBundle.load('assets/fonts/Roboto-Thin.ttf');

    final ttf = pw.Font.ttf(font);
    final ttfBold = pw.Font.ttf(font);
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
    );

    final reports = reportController.reports;

    // 🔹 Load logo (put in assets)
    final logo = await imageFromAssetBundle('assets/images/login/logo.png');

    // ───────────────────────── PAGE 1 ─────────────────────────
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ─── HEADER ───
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logo, width: 60),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'SIOT Manager',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text('Rapport général'),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                // ─── STATS ───
                pw.Text(
                  'Résumé',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _pdfStat(
                      'Mesures',
                      reportController.mesures.value.toStringAsFixed(0),
                    ),
                    _pdfStat(
                      'Alertes',
                      reportController.alerts.value.toStringAsFixed(0),
                    ),
                    _pdfStat(
                      'Capteurs',
                      reportController.tags.value.toStringAsFixed(0),
                    ),
                    _pdfStat(
                      'Dernière maj',
                      reportController.uptime.value.split(' ').last,
                    ),
                  ],
                ),

                pw.SizedBox(height: 20),

                pw.Text(
                  'Détails',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 10),

                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                    3: const pw.FlexColumnWidth(2),
                    4: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        _cell('Semaine'),
                        _cell('Température'),
                        _cell('Humidité'),
                        _cell('Luminosité'),
                        _cell('Pression'),
                      ],
                    ),
                    ...reports.map(
                      (r) => pw.TableRow(
                        children: [
                          _cell(r.week),
                          _cell('${r.avgTemperature.toStringAsFixed(1)}°'),
                          _cell('${r.avgHumidity.toStringAsFixed(1)}%'),
                          _cell('${r.avgIllumination.toStringAsFixed(2)}lx'),
                          _cell('${r.avgPressure.toStringAsFixed(0)}hPa'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );

    // ───────────────────────── SAVE FILE ─────────────────────────
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report.pdf');

    await file.writeAsBytes(await pdf.save());

    // optional preview
    //await Printing.layoutPdf(onLayout: (_) => pdf.save());
    await OpenFile.open(file.path);
  }

  pw.Widget _pdfStat(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(title, style: const pw.TextStyle(fontSize: 10)),
      ],
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text),
    );
  }
}
*/
