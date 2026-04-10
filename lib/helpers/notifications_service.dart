import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../controller/home.dart';
import '../models/sensors.dart';
import '../screens/graph/graph_screen.dart';

/// 🔴 BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationsService.instance.setupFlutterNotifications();
  await NotificationsService.instance.showNotification(message);
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  bool isLocalNotificationsInitialized = false;

  // ─────────────────────────────────────────

  Future<void> initialize() async {
    await requestPermission();
    await setupFlutterNotifications();
    await setupMessageHandlers();
  }

  // ─────────────────────────────────────────

  Future<void> requestPermission() async =>
      await messaging.requestPermission(alert: true, badge: true, sound: true);

  // ─────────────────────────────────────────

  Future<void> setupFlutterNotifications() async {
    if (isLocalNotificationsInitialized) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Used for important notifications',
      importance: Importance.high,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          _handleNavigation(jsonDecode(details.payload!));
        }
      },
    );

    isLocalNotificationsInitialized = true;
  }

  // ─────────────────────────────────────────

  Future<void> showNotification(RemoteMessage message) async {
    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
      message.notification?.title ?? message.data['title'],
      message.notification?.body ?? message.data['body'],
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
  // ─────────────────────────────────────────

  Future<void> setupMessageHandlers() async {
    /// 🟢 FOREGROUND
    FirebaseMessaging.onMessage.listen((message) => showNotification(message));

    /// 🟡 CLICK FROM BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNavigation(message.data),
    );

    /// 🔵 CLICK FROM TERMINATED
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) _handleNavigation(initialMessage.data);
  }

  // ─────────────────────────────────────────
  // 🔥 MAIN NAVIGATION LOGIC

  Future<void> _handleNavigation(Map<String, dynamic> data) async {
    final tagId = data['TAG_ID'];

    if (tagId != null) {
      Get.back();
      if (homeController.sensors.isEmpty ||
          homeController.sensors.where((e) => e.mac == tagId).isEmpty) {
        homeController.getAccess();
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.to(
          () => GraphScreen(
            sensor: SensorModel(
              mac: tagId,
              name: data['sensor_name'] ?? 'Anonyme',
              type: '',
              temperature: 0,
              humidity: 0,
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
        );
      });
    }
  }
}
