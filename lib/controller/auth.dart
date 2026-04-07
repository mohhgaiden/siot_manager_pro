import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:siot_manager_pro/screens/home/main_screen.dart';
import '../services/auth.dart';

class AuthController extends GetxController {
  final RxBool reset = true.obs;
  final rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  // Login form controllers
  final user = TextEditingController().obs;
  final password = TextEditingController().obs;
  final RxBool obscurePassword = true.obs;
  togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;

  clearLogin() {
    user.value.clear();
    password.value.clear();
    obscurePassword.value = true;
  }

  Future<void> login() async {
    isLoading.value = true;
    try {
      // Get FCM token safely for iOS
      String? token;
      try {
        if (GetPlatform.isIOS) {
          // Wait for APNs token first
          String? apnsToken;
          int retries = 0;
          while (apnsToken == null && retries < 5) {
            apnsToken = await FirebaseMessaging.instance.getAPNSToken();
            if (apnsToken == null) {
              await Future.delayed(const Duration(seconds: 2));
              retries++;
            }
          }
        }
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Continue login even if FCM token fails
        token = null;
      }
      await Future.delayed(const Duration(seconds: 1));
      final response = await authService.login({
        "username": user.value.text.trim(),
        "password": password.value.text.trim(),
        "fcm_token": token ?? "",
      });

      final loginData = response['LOGGED_IN_MANAGER'];
      final isSuccess =
          loginData['error'] == 'false' &&
          loginData['connection_established'] == 1;

      if (!isSuccess) {
        // ✅ Show failure and stop
        Get.snackbar('Échec de connexion', loginData['msg']);
        return;
      }

      final box = Hive.box('username');

      if (rememberMe.value) {
        if (box.isEmpty) {
          await box.add({"user": user.value.text, "pass": password.value.text});
        } else {
          await box.putAt(0, {
            "user": user.value.text,
            "pass": password.value.text,
          });
        }
      } else {
        box.clear();
      }

      // ✅ Save session
      await Hive.box('login').clear();
      await Hive.box('login').add(loginData);

      clearLogin();
      Get.snackbar('Succès', loginData['msg']);

      Get.offAll(() => const MainScreen());
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

final authController = Get.put(AuthController());
