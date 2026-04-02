import 'package:flutter/material.dart';
import '../screens/home/home_page.dart';
import '../screens/addPortfolio/addPortfolio_page.dart';
import '../screens/price/livePrices_page.dart';
import '../screens/news/news_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/register_page.dart';
import '../screens/profile/profile_page.dart';
import '../screens/profile/changePassword_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String add = '/add';
  static const String livePrices = '/livePrices';
  static const String news = '/news';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String changePassword = '/changePassword';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      add: (context) => const AddPortfolioPage(),
      livePrices: (context) => const LivePricesPage(),
      news: (context) => const NewsPage(),
      login: (context) => const LoginPage(),
      register: (context) => const RegisterPage(),
      profile: (context) => const ProfilePage(),
      changePassword : (context) => const ChangePasswordPage(),
    };
  }
}