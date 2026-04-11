import 'dart:io';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PushNotificationService {
  Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    String onesignalAppId = Platform.isIOS 
        ? (dotenv.env['ONESIGNAL_APP_ID_IOS'] ?? '') 
        : (dotenv.env['ONESIGNAL_APP_ID_ANDROID'] ?? '');
    OneSignal.initialize(onesignalAppId);

    OneSignal.Notifications.requestPermission(true).then((bool accepted) {
      debugPrint("Bildirim izni kabul edildi mi: $accepted");
    });
    
    OneSignal.Notifications.addClickListener((event) {
      debugPrint("Bildirime tıklandı: ${event.notification.title} - ${event.notification.body}");
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint("Uygulama aktifken bildirim geldi: ${event.notification.title}");
    });
  }
}
