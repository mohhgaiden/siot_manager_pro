import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'helpers/notifications_service.dart';
import 'screens/login/intro_screen.dart';
import 'theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationsService.instance.initialize();
  await Hive.initFlutter();
  await Hive.openBox('login');
  await Hive.openBox('username');
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppTheme.primary,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SiotApp());
}

class SiotApp extends StatelessWidget {
  const SiotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
        return SafeArea(
          bottom: true,
          top: false,
          left: false,
          right: false,
          child: child!,
        );
      },
      title: 'S-IOT Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: AnimatedSplashScreen(
        splash: 'assets/images/login/logo.png',
        splashIconSize: 200,
        duration: 2500,
        nextScreen: IntroScreen(),
        splashTransition: SplashTransition.sizeTransition,
      ),
    );
  }
}
