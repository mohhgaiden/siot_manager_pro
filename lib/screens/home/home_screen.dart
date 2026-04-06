import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siot_manager_pro/screens/login/login_screen.dart';
import '../../controller/home.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../graph/graph_screen.dart';
import 'cards/sensor_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _buildHeader(),
              Container(
                color: AppTheme.primary,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Row(
                  spacing: 10,
                  children: [
                    Expanded(child: _buildSpaceSelect()),
                    _buildViewToggle(),
                  ],
                ),
              ),
              Expanded(
                child:
                    homeController.isLoading.value
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                        : homeController.isListView.value
                        ? _buildListView()
                        : GraphScreen(sensor: null), // _buildGraphView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      color: AppTheme.primary,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  homeController.managerSurname,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Obx(
                  () => Text(
                    '${homeController.sensors.length} capteurs actifs',
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
            onTap: homeController.getAccess,
            icon: Image.asset(
              'assets/images/home/refresh.png',
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            onTap: _confirmLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ─── Space selector ───────────────────────────────────────────────────────

  Widget _buildSpaceSelect() {
    return GestureDetector(
      onTap: _openSpacePicker,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Obx(
                () => Text(
                  homeController.selectedSpace.value.isEmpty
                      ? 'Sélectionner un espace'
                      : homeController.selectedSpace.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Icon(Icons.logout, size: 28, color: Colors.red),

              const SizedBox(height: 10),

              const Text(
                'Se déconnecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 6),

              const Text(
                'Voulez-vous vraiment vous déconnecter ?',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Hive.box('login').clear();
                        Get.offAll(LoginScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Déconnexion'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSpacePicker() {
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
                    homeController.selectedSpace.value == room.spaceName
                        ? const Icon(Icons.check, color: AppTheme.primary)
                        : null,
                onTap: () => homeController.selectRoom(room),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── View toggle ──────────────────────────────────────────────────────────

  Widget _buildViewToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      child: Obx(
        () => Row(
          spacing: 4,
          children: [
            _toggleBtn(
              Icons.format_list_bulleted,
              homeController.isListView.value,
              () => homeController.toggleView(true),
            ),
            _toggleBtn(
              Icons.show_chart,
              !homeController.isListView.value,
              () => homeController.toggleView(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 34,
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? AppTheme.primary : Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }

  // ─── List view ────────────────────────────────────────────────────────────

  Widget _buildListView() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 10),
        Obx(
          () => Column(
            children:
                homeController.filteredSensors
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SensorCard(
                          sensor: s,
                          isExpanded:
                              homeController.selectedCard.value == s.mac,
                          onToggle: () => homeController.toggleCard(s.mac),
                          onGraphTap: () => Get.to(GraphScreen(sensor: s)),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: homeController.search.value,
      onChanged: homeController.onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Rechercher un capteur...',
        hintStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 2),
          child: Image.asset(
            'assets/images/login/search.png',
            color: AppTheme.textMuted,
            height: 20,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppTheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
      ),
    );
  }
}
