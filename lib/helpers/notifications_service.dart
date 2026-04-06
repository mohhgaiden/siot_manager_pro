import 'package:firebase_messaging/firebase_messaging.dart';
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
