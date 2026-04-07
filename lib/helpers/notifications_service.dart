import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:siot_manager_pro/controller/home.dart';

// 👉 IMPORT YOUR SCREEN
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

  Future<void> requestPermission() async {
    await messaging.requestPermission(alert: true, badge: true, sound: true);
  }

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
        print("🟡 LOCAL CLICK");
        print("📦 PAYLOAD: ${details.payload}");

        if (details.payload != null && details.payload!.isNotEmpty) {
          final data = jsonDecode(details.payload!);

          // 🔥 Important delay (context ready)
          Future.delayed(const Duration(milliseconds: 300), () {
            _handleNavigation(data);
          });
        }
      },
    );

    isLocalNotificationsInitialized = true;
  }

  // ─────────────────────────────────────────

  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title =
        message.data['sensor_name'] ?? notification?.title ?? 'Sensor';

    final body = notification?.body ?? message.data['body'] ?? '';

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
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
    FirebaseMessaging.onMessage.listen((message) {
      print("🟢 FOREGROUND");
      print("📦 ${message.data}");

      showNotification(message);
    });

    /// 🟡 CLICK FROM BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("🟡 BACKGROUND CLICK");
      print("📦 ${message.data}");

      _handleNavigation(message.data);
    });

    /// 🔵 CLICK FROM TERMINATED
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print("🔵 TERMINATED CLICK");
      print("📦 ${initialMessage.data}");

      _handleNavigation(initialMessage.data);
    }
  }

  // ─────────────────────────────────────────
  // 🔥 MAIN NAVIGATION LOGIC

  Future<void> _handleNavigation(Map<String, dynamic> data) async {
    final tagId = data['TAG_ID'];

    if (tagId != null) {
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

      homeController.getAccess();
    }
  }
}

/*import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationsService.instance.setupFlutterNotifications();
  await NotificationsService.instance.showNotification(message);
}

class NotificationsService {
  NotificationsService._();
  static final NotificationsService instance = NotificationsService._();

  final messaging = FirebaseMessaging.instance;
  final localNotifications = FlutterLocalNotificationsPlugin();
  bool isLocalNotificationsInitialized = false;

  Future<void> initialize() async {
    await requestPermission();
    await setupMessageHandlers();
    //final token = await messaging.getToken();
    //print('FCM TOKEN: $token');
  }

  Future<void> requestPermission() async {
    //final setting =
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
    //print('Permission status: ${setting.authorizationStatus}');
  }

  Future<void> setupFlutterNotifications() async {
    if (isLocalNotificationsInitialized) {
      return;
    }

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: '',
      importance: Importance.high,
    );

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSetting = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await localNotifications.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (details) {},
    );

    isLocalNotificationsInitialized = true;
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      await localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_important_channel',
            'High Important Notification',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen(
      (message) {
        showNotification(message);
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      handleBackgroundMessage(initialMessage);
    }
  }

  void handleBackgroundMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {}
  }
}
*/
