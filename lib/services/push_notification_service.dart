import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushNotificationService {
  Future<void> initialize() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    OneSignal.initialize("YOUR_ONESIGNAL_APP_ID_HERE");

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
