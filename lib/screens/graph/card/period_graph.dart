import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controller/chart.dart';
import '/models/sensors.dart';
import '../../../theme/app_theme.dart';

class PeriodGraph extends StatelessWidget {
  const PeriodGraph({super.key, this.sensor});
  final SensorModel? sensor;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(ChartController.periods.length, (i) {
          final active = chartController.periodIndex.value == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => chartController.changePeriod(i, sensor?.mac),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : const Color(0xFFEEEEEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    ChartController.periods[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
