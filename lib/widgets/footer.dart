import 'package:flutter/material.dart';
import '../screens/home/home_page.dart';
import '../screens/price/livePrices_page.dart';
import '../screens/news/news_page.dart';
import '../screens/addPortfolio/addPortfolio_page.dart';
import '../screens/profile/profile_page.dart';
import '../services/auth_service.dart';


class AuthCache {
  static bool? isLoggedIn;
}

class CebeciBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CebeciBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  State<CebeciBottomNav> createState() => _CebeciBottomNavState();
}

class _CebeciBottomNavState extends State<CebeciBottomNav> {
  bool _isLoggedIn = AuthCache.isLoggedIn ?? false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService().isLoggedIn();
    AuthCache.isLoggedIn = loggedIn;
    if (mounted && _isLoggedIn != loggedIn) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  void _navigateWithoutAnimation(BuildContext context, Widget page, String routeName) {

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: RouteSettings(name: routeName),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  // Sabit index'li navigation data
  List<Map<String, dynamic>> _getNavData() {
    return [
      {
        'index': 0,
        'label': 'Canlı Fiyatlar',
        'icon': Icons.bar_chart_rounded,
        'page': const LivePricesPage(),
        'route': '/livePrices',
      },
      {
        'index': 1,
        'label': 'Haberler',
        'icon': Icons.newspaper_rounded,
        'page': const NewsPage(),
        'route': '/news',
      },
      {
        'index': 2,
        'label': 'Portföy',
        'icon': Icons.pie_chart_rounded,
        'page': const HomePage(),
        'route': '/home',
      },
      if (_isLoggedIn)
        {
          'index': 3,
          'label': 'Portföy Ekle',
          'icon': Icons.add_circle_outline,
          'page': const AddPortfolioPage(),
          'route': '/add',
        },
      {
        'index': 4,
        'label': 'Profil',
        'icon': Icons.person_outline,
        'page': const ProfilePage(),
        'route': '/profile',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final navData = _getNavData();

    final double barHeight = size.height * 0.082;
    final double horizontalPadding = size.width * 0.04;
    final double bottomPadding = size.height * 0.015;

    return Container(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, bottomPadding),
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(barHeight / 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(barHeight / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: navData.map((item) {
                  final itemIndex = item['index'] as int;
                  final isActive = itemIndex == widget.currentIndex;

                  return Flexible(
                    flex: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onTap != null) widget.onTap!(itemIndex);
                        if (isActive) return;

                        _navigateWithoutAnimation(context, item['page'], item['route']);
                      },
                      child: _NavItemWidget(
                        label: item['label'],
                        icon: item['icon'],
                        isActive: isActive,
                        size: size,
                        itemCount: navData.length,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Size size;
  final int itemCount;

  const _NavItemWidget({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.size,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final double iconSize = itemCount == 5 ? size.width * 0.055 : size.width * 0.06;
    final double fontSize = itemCount == 5 ? size.width * 0.026 : size.width * 0.029;

    const activeColor = Color(0xFF1A0B52);
    const inactiveColor = Color(0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: itemCount == 5 ? 8 : 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF1A0B52).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}