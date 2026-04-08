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
