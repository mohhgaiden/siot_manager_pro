import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/auth.dart';
import '../../../helpers/notifications_service.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    if (Hive.box('username').isNotEmpty) {
      authController.user.value.text = Hive.box('username').getAt(0)['user'];
      authController.password.value.text = Hive.box('username').get(0)['pass'];
    }
    // Request notification permission after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationsService.instance.requestPermission();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 50),

                  // ─── Logo ─────────────────────────────────────────────
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/login/logo.png',
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ─── App name ─────────────────────────────────────────
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        children: [
                          TextSpan(text: 'S'),
                          TextSpan(
                            text: '-',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                          TextSpan(text: 'IOT '),
                          TextSpan(
                            text: 'Manager',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  const Center(
                    child: Text(
                      'SENSOR MONITORING',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Title ────────────────────────────────────────────
                  const Text(
                    'Bon retour',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Username field ───────────────────────────────────
                  TextField(
                    controller: authController.user.value,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Nom d\'utilisateur',
                      hintStyle: const TextStyle(color: AppTheme.textMuted),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(Icons.person_3, color: AppTheme.textMuted),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ─── Password field ───────────────────────────────────
                  Obx(
                    () => TextField(
                      controller: authController.password.value,
                      obscureText: authController.obscurePassword.value,
                      decoration: InputDecoration(
                        hintText: 'Mot de passe',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            Icons.password,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            authController.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textMuted,
                          ),
                          onPressed: authController.togglePasswordVisibility,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Obx(
                    () => Row(
                      children: [
                        Checkbox(
                          value: authController.rememberMe.value,
                          onChanged:
                              (val) =>
                                  authController.rememberMe.value =
                                      val ?? false,
                          activeColor: AppTheme.primary,
                        ),
                        const Text(
                          'Se souvenir de moi',
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Login button ─────────────────────────────────────
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            authController.isLoading.value ? null : _onLogin,
                        label: Row(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              authController.isLoading.value
                                  ? 'Connexion...'
                                  : 'SE CONNECTER',
                            ),
                            authController.isLoading.value
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ─── Footer ───────────────────────────────────────────────────
            /*
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('© 2026 Développé par Sirius NET'),
            ),*/
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () async {
                  final url = Uri.parse('https://www.sirius-net.dz');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text(
                  '© 2026 Développé par Sirius NET',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Validation before calling controller ─────────────────────────────────
  void _onLogin() {
    final username = authController.user.value.text.trim();
    final password = authController.password.value.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir le nom d\'utilisateur et le mot de passe',
      );
      return;
    }

    authController.login();
  }
}
