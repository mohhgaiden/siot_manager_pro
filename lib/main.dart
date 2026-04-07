import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'screens/login/intro_screen.dart';
import 'theme/app_theme.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/utils/firebase_messaging_service.dart';
import '/utils/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService);

  await Hive.initFlutter();
  await Hive.openBox('login');
  await Hive.openBox('username');
  runApp(const SiotApp());
}

class SiotApp extends StatelessWidget {
  const SiotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: (context, child) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
    child: Stack(
      children: [
        // White background for entire screen
        Container(color: Colors.white),
        // Orange only at top behind status bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).padding.top,
          child: Container(color: AppTheme.primary),
        ),
        // Actual app content with full safe area
        Positioned.fill(
          child: SafeArea(
            top: true,
            bottom: true,
            child: child!,
          ),
        ),
      ],
    ),
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
