import 'package:flutter/material.dart';
import '../app/app.dart';
import 'services/token_service.dart';
import 'app/routes.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'services/push_notification_service.dart';
import 'services/meta_events_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");


  await MetaEventsService.instance.initialize();

  final pushService = PushNotificationService();
  await pushService.initialize();

  await MobileAds.instance.initialize();

  debugPrint('AdMob başlatıldı!');

  String? token = await TokenService.getToken();

  //String initialRoute = (token != null) ? AppRoutes.home : AppRoutes.login;

  String initialRoute = AppRoutes.livePrices;

  runApp(MyApp(initialRoute: initialRoute));
}