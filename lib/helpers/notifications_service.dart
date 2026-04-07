import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Background handler for Firebase messages
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
  final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
  bool isLocalNotificationsInitialized = false;

  /// Initialize service
  Future<void> initialize() async {
    await requestPermission();
    await setupFlutterNotifications();
    await setupMessageHandlers();
  }

  /// Request notification permissions (iOS)
  Future<void> requestPermission() async {
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );
  }

  /// Setup Flutter local notifications
  Future<void> setupFlutterNotifications() async {
    if (isLocalNotificationsInitialized) return;

    // Android notification channel
    const channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    // Register channel on Android
    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

    // Initialization settings for Android + iOS
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle taps on notifications here if needed
      },
    );

    isLocalNotificationsInitialized = true;
  }

  /// Show notification (foreground)
  Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      await localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Listen for foreground and background messages
  Future<void> setupMessageHandlers() async {
    // Foreground
    FirebaseMessaging.onMessage.listen(showNotification);

    // When app opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageTap);

    // Initial message if app was terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      handleMessageTap(initialMessage);
    }
  }

  /// Handle notification taps
  void handleMessageTap(RemoteMessage message) {
    // Example: navigate based on message type
    if (message.data['type'] == 'chat') {
      // Navigate to chat screen
    }
  }
}