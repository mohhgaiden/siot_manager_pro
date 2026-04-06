import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siot_manager_pro/theme/app_theme.dart';
import '../../controller/main.dart';
import '../history/history_screen.dart';
import 'home_screen.dart';
import '../alerts_screen.dart';
import '../report_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildCurrentTab(mainController.currentIndex.value)),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildBottomNavItem(
                  icon: 'home',
                  label: 'Accueil',
                  index: 0,
                  isActive: mainController.currentIndex.value == 0,
                  onTap: () => mainController.changeTab(0),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: 'history',
                  label: 'Historique',
                  index: 1,
                  isActive: mainController.currentIndex.value == 1,
                  onTap: () => mainController.changeTab(1),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: 'notif',
                  label: 'Alertes',
                  index: 2,
                  isActive: mainController.currentIndex.value == 2,
                  onTap: () => mainController.changeTab(2),
                ),
              ),
              Expanded(
                child: _buildBottomNavItem(
                  icon: 'form',
                  label: 'Report',
                  index: 3,
                  isActive: mainController.currentIndex.value == 3,
                  onTap: () => mainController.changeTab(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return HomeScreen();
      case 1:
        return HistoryScreen();
      case 2:
        return AlertsScreen();
      case 3:
        return ReportScreen();
      default:
        return HomeScreen();
    }
  }

  Widget _buildBottomNavItem({
    required String icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 1.5,
              color: isActive ? AppTheme.primary : Colors.transparent,
            ),
          ),
        ),
        child: Column(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/home/$icon${isActive ? '1' : ''}.png',
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
              height: 24,
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppTheme.primary : AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
