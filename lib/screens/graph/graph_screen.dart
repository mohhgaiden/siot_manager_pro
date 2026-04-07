import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home.dart';
import '/models/sensors.dart';
import '../../controller/chart.dart';
import '../../theme/app_theme.dart';
import 'card/graph_card.dart';
import 'card/period_graph.dart';
import 'card/state_row.dart';

/*
class GraphScreen extends StatelessWidget {
  final SensorModel? sensor;
  const GraphScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => chartController.getChart(sensor?.mac),
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            if (sensor != null) _buildHeader(context),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }*/
class GraphScreen extends StatefulWidget {
  final SensorModel? sensor;

  const GraphScreen({super.key, required this.sensor});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ CALL ONLY ONCE
    chartController.getChart(widget.sensor?.mac);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            if (widget.sensor != null) _buildHeader(context),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.sensor!.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.sensor!.mac,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.sensor!.isLive ? 'En direct' : 'Hors ligne',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent() {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.all(14),
        children: [
          StateRowCard(),
          SizedBox(height: 10),
          PeriodGraph(sensor: widget.sensor),
          if (homeController.access.value!.temperature == 1)
            SizedBox(height: 12),
          if (homeController.access.value!.temperature == 1)
            GraphCard(
              title: 'Température',
              color: AppTheme.primary,
              unit: '°C',
              currentValue: chartController.avgTemp.value.toStringAsFixed(1),
              spots: chartController.tempSpots,
              minY: -20,
              maxY: 60,
            ),
          if (homeController.access.value!.humidity == 1)
            const SizedBox(height: 12),
          if (homeController.access.value!.humidity == 1)
            GraphCard(
              title: 'Humidité',
              color: AppTheme.blue,
              unit: '%',
              currentValue: chartController.avgHum.value.toStringAsFixed(1),
              spots: chartController.humSpots,
              minY: 20,
              maxY: 80,
            ),
          if (homeController.access.value!.illumination == 1)
            const SizedBox(height: 12),
          if (homeController.access.value!.illumination == 1)
            GraphCard(
              title: 'Luminosité',
              color: AppTheme.amber,
              unit: ' lx',
              currentValue: chartController.avgLux.value.toStringAsFixed(2),
              spots: chartController.luxSpots,
              minY: 0,
              maxY: 1000,
              isBar: true,
            ),
          if (homeController.access.value!.pression == 1)
            const SizedBox(height: 12),
          if (homeController.access.value!.pression == 1)
            GraphCard(
              title: 'Pression',
              color: AppTheme.green,
              unit: ' hPa',
              currentValue: chartController.avgCo2.value.toStringAsFixed(0),
              spots: chartController.co2Spots,
              minY: -10,
              maxY: 150,
            ),
        ],
      ),
    );
  }
}
