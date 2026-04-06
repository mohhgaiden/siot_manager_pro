import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siot_manager_pro/controller/home.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/sensors.dart';
import '../../../theme/app_theme.dart';
import 'details_item.dart';

class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onGraphTap;

  const SensorCard({
    super.key,
    required this.sensor,
    required this.isExpanded,
    required this.onToggle,
    required this.onGraphTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd-MM-yyyy · HH:mm:ss');
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 0),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sensor.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sensor.mac,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.primary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        if (sensor.latitude > 0 && sensor.longitude > 0)
                          _miniButton(Icons.location_on_outlined, () async {
                            final Uri url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${sensor.latitude},${sensor.longitude}',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          }),
                        _miniButton(Icons.show_chart, onGraphTap),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (homeController.access.value!.temperature == 1)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/home/thermometer.png',
                              color: AppTheme.primary,
                              height: 40,
                            ),
                            const SizedBox(width: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sensor.temperature.toStringAsFixed(
                                    sensor.temperature % 1 == 0 ? 0 : 2,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const Text(
                                  ' °C',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      else
                        SizedBox(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'En direct',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            fmt.format(sensor.dateTime),
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          // Expanded details
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _buildDetails(),
            crossFadeState:
                isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
          // Expand button
          InkWell(
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color:
                    isExpanded
                        ? AppTheme.primaryLight
                        : const Color(0xFFFAFAFA),
                border: const Border(top: BorderSide(color: AppTheme.border)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'Masquer les détails' : 'Voir les détails',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isExpanded ? AppTheme.primary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: isExpanded ? AppTheme.primary : AppTheme.textMuted,
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

  Widget _buildDetails() {
    return Obx(
      () => Container(
        color: const Color(0xFFFAFAFA),
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.8,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            if (homeController.access.value!.humidity == 1)
              DetailItem(
                label: 'Humidité',
                value: sensor.humidity.toStringAsFixed(0),
                unit: ' %',
              ),
            if (homeController.access.value!.illumination == 1)
              DetailItem(
                label: 'Luminosité',
                value: sensor.illumination.toStringAsFixed(2),
                unit: ' lx',
              ),
            if (homeController.access.value!.pression == 1)
              DetailItem(
                label: 'Pression',
                value: sensor.pression.toStringAsFixed(0),
                unit: ' hPa',
              ),
            if (homeController.access.value!.voltage == 1)
              DetailItem(
                label: 'voltage',
                value: sensor.level.toStringAsFixed(0),
                unit: ' v',
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppTheme.primary),
      ),
    );
  }
}
