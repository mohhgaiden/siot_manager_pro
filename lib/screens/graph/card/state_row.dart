import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siot_manager_pro/controller/chart.dart';
import 'package:siot_manager_pro/controller/home.dart';
import '../../../theme/app_theme.dart';

class StateRowCard extends StatelessWidget {
  const StateRowCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 6,
        children: [
          if (homeController.access.value!.temperature == 1)
            Expanded(
              child: _buildState(
                value: '${chartController.avgTemp.value.toStringAsFixed(0)}°',
                label: 'Température',
                icon: Icons.thermostat,
                color: AppTheme.primary,
              ),
            ),
          if (homeController.access.value!.humidity == 1)
            Expanded(
              child: _buildState(
                value: '${chartController.avgHum.value.toStringAsFixed(0)}%',
                label: 'Humidité',
                icon: Icons.water_drop_outlined,
                color: AppTheme.blue,
              ),
            ),
          if (homeController.access.value!.illumination == 1)
            Expanded(
              child: _buildState(
                value: chartController.avgLux.value.toStringAsFixed(2),
                label: 'Luminosité',
                icon: Icons.wb_sunny_outlined,
                color: AppTheme.amber,
              ),
            ),
          if (homeController.access.value!.pression == 1)
            Expanded(
              child: _buildState(
                value: chartController.avgCo2.value.toStringAsFixed(2),
                label: 'Pression',
                icon: Icons.air,
                color: AppTheme.green,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildState({
    String? value,
    String? label,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color!.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label!,
            style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
