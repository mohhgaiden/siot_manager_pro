import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

    final value = isTemp ? '${a.temperature} °C' : '${a.humidity} %';

    final color = isTemp ? AppTheme.primary : AppTheme.blue;

    //final icon = isTemp ? Icons.thermostat : Icons.water_drop_outlined;

    IconData getIcon(AlertModel a) {
      if (a.type == 2) return Icons.arrow_upward; // high
      if (a.type == 1) return Icons.arrow_downward; // low
      return Icons.info_outline;
    }

    return Container(
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
        ],
      ),
    );
  }
}
/*
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = MockData.alerts.where((a) => !a.resolved).toList();
    final resolved = MockData.alerts.where((a) => a.resolved).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, active.length),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  if (active.isNotEmpty) ...[
                    const _SectionLabel(label: 'Actives'),
                    const SizedBox(height: 8),
                    ...active.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _AlertCard(alert: a),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (resolved.isNotEmpty) ...[
                    const _SectionLabel(label: 'Résolues'),
                    const SizedBox(height: 8),
                    ...resolved.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _AlertCard(alert: a),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int activeCount) {
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
                Text(
                  '$activeCount notifications actives',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.done_all, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTheme.textMuted,
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
  const _AlertCard({required this.alert});

  Color get _color {
    switch (alert.type) {
      case AlertType.danger:
        return AppTheme.red;
      case AlertType.warning:
        return AppTheme.amber;
      case AlertType.success:
        return AppTheme.green;
    }
  }

  IconData get _icon {
    switch (alert.type) {
      case AlertType.danger:
        return Icons.warning_amber_rounded;
      case AlertType.warning:
        return Icons.warning_outlined;
      case AlertType.success:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yyyy HH:mm');
    return Opacity(
      opacity: alert.resolved ? 0.5 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_icon, size: 18, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${alert.sensorName} · ${fmt.format(alert.time)}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                alert.value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _color.withOpacity(0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/