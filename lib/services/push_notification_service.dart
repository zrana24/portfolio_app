import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../app/app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Arka plan mesajı alındı: ${message.messageId}");
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidInitData = AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initSettings = InitializationSettings(android: androidInitData);
    await _localNotifications.initialize(settings: initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'Önemli Bildirimler', 
      description: 'Uygulama ön plandayken gelen önemli bildirimler.',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Bildirim İzni Durumu: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized || 
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      try {
        String? token = await _fcm.getToken();
        debugPrint("FCM Token: $token");
      } catch (e) {
        debugPrint("Token alınamadı: $e");
      }

      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint("Token yenilendi: $newToken");
      });

      await _fcm.setForegroundNotificationPresentationOptions(
        alert: true, 
        badge: true, 
        sound: true,
      );

      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Uygulama aktif konumdayken mesaj geldi!');
        
        if (message.notification != null) {
          debugPrint('Başlık: ${message.notification?.title}');
          debugPrint('İçerik: ${message.notification?.body}');
          
          _localNotifications.show(
            id: message.notification.hashCode,
            title: message.notification?.title,
            body: message.notification?.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'Önemli Bildirimler',
                channelDescription: 'Uygulama ön plandayken gelen önemli bildirimler.',
                icon: '@mipmap/launcher_icon',
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
              ),
            ),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('Bildirime tıklandı ve uygulama açıldı (Arkaplan)!');
      });

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
         debugPrint('Uygulama tamamen kapalıydı, bildirime tıklanarak açıldı.');
      }
    } else {
      debugPrint('Kullanıcı bildirim izinlerini reddetti.');
    }
  }
}
