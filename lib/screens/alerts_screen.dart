import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siot_manager_pro/models/sensors.dart';
import 'package:siot_manager_pro/screens/graph/graph_screen.dart';
import '../controller/alert.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  static const _types = ['Température', 'Humidité'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(),
              _buildTypeTabs(),
              Expanded(
                child:
                    alertController.isLoading.value &&
                            alertController.alerts.isEmpty
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : _buildList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                  'Alertes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Obx(
                  () => Text(
                    '${alertController.alerts.length} alertes',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.65),
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            onTap: () => alertController.getAlerts(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Obx(
        () => Row(
          children: List.generate(_types.length, (i) {
            final active = alertController.type.value == i;

            return Expanded(
              child: GestureDetector(
                onTap: () => alertController.changePeriod(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        active ? Colors.white : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _types[i],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color:
                          active
                              ? AppTheme.primary
                              : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildList() {
    return Obx(() {
      if (alertController.alerts.isEmpty) {
        return const Center(
          child: Text(
            'Aucune alerte',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        );
      }

      return ListView.separated(
        controller: alertController.paginateCtrl,
        padding: const EdgeInsets.all(14),
        itemCount: alertController.alerts.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          if (i < alertController.alerts.length) {
            final a =
                alertController.alerts[alertController.alerts.length - 1 - i];
            return _buildAlertItem(a);
          } else {
            if (alertController.offset.value < alertController.total.value) {
              return const Center(child: CupertinoActivityIndicator());
            }
            return const SizedBox();
          }
        },
      );
    });
  }

  Widget _buildAlertItem(AlertModel a) {
    final isTemp = alertController.type.value == 0;

    final unit = isTemp ? '°C' : '%';

    final interval = '${a.min} – ${a.max} $unit';

    final value = isTemp ? '${a.temperature} °C' : '${a.humidity} %';

    final color = isTemp ? AppTheme.primary : AppTheme.blue;

    //final icon = isTemp ? Icons.thermostat : Icons.water_drop_outlined;

    IconData getIcon(AlertModel a) {
      if (a.type == 2) return Icons.arrow_upward; // high
      if (a.type == 1) return Icons.arrow_downward; // low
      return Icons.info_outline;
    }

    return GestureDetector(
      onTap:
          () => Get.to(
            GraphScreen(
              sensor: SensorModel(
                mac: a.macAdrs,
                name: a.name,
                type: '',
                temperature: a.temperature,
                humidity: a.humidity,
                illumination: 0,
                pression: 0,
                voltage: 0,
                amperage: 0,
                level: 0,
                latitude: 0,
                longitude: 0,
                dateTime: DateTime.now(),
                isLive: true,
              ),
            ),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('dd-MM-yyyy HH:mm').format(a.dateTime)} · ${a.tagName}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Icon(getIcon(a), size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                // 🔥 NEW (min/max interval)
                Text(
                  '($interval)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
