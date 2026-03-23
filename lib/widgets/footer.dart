import 'package:flutter/material.dart';
import '../app/routes.dart';
import '../screens/home/home_page.dart';
import '../screens/price/livePrices_page.dart';
import '../screens/news/news_page.dart';

class CebeciBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CebeciBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  void _navigateWithoutAnimation(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const items = [
      _NavItem(label: 'Canlı Fiyatlar', icon: Icons.bar_chart_rounded),
      _NavItem(label: 'Haberler',       icon: Icons.newspaper_rounded),
      _NavItem(label: 'Portföyüm',      icon: Icons.pie_chart_rounded),
    ];

    return Container(
      color: Colors.transparent, // Arka plan şeffaf
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: size.width * 0.05,
            right: size.width * 0.05,
            bottom: size.height * 0.015,
            top: size.height * 0.008,
          ),
          child: Container(
            height: size.height * 0.082,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(size.height * 0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final isActive = index == currentIndex;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (onTap != null) onTap!(index);
                      if (index == currentIndex) return;

                      Widget page;
                      switch (index) {
                        case 0:
                          page = const LivePricesPage();
                          break;
                        case 1:
                          page = const NewsPage();
                          break;
                        case 2:
                          page = const HomePage();
                          break;
                        default:
                          return;
                      }

                      _navigateWithoutAnimation(context, page);
                    },
                    child: _NavItemWidget(
                      item: items[index],
                      isActive: isActive,
                      size: size,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final Size size;

  const _NavItemWidget({
    required this.item,
    required this.isActive,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size.width * 0.062;
    const activeColor = Color(0xFF1A0B52);
    const inactiveColor = Colors.black54;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: isActive ? size.width * 0.14 : iconSize,
          height: size.height * 0.038,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEEEBF8) : Colors.transparent,
            borderRadius: BorderRadius.circular(size.height * 0.02),
          ),
          child: Center(
            child: Icon(
              item.icon,
              size: iconSize,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.005),
        Text(
          item.label,
          style: TextStyle(
            fontSize: size.width * 0.027,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}