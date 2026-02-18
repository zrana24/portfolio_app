import 'package:flutter/material.dart';
import '../screens/home/home_page.dart';
import '../screens/addPortfolio/addPortfolio_page.dart';
import '../screens/price/price_page.dart';
//import '../screens/news/news_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String add = '/add';
  static const String price = '/price';
  static const String news = '/news';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      home: (context) => const HomePage(),
      add: (context) => const AddPortfolioPage(),
      //price: (context) => const PricesPage(),
      //news: (context) => const NewsPage(),
    };
  }
}
