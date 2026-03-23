import 'package:flutter/material.dart';
import '../app/app.dart';
import 'services/token_service.dart';
import 'app/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? token = await TokenService.getToken();

  //String initialRoute = (token != null) ? AppRoutes.home : AppRoutes.login;

  String initialRoute = AppRoutes.livePrices;

  runApp(MyApp(initialRoute: initialRoute));
}