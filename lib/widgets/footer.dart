import 'package:flutter/material.dart';
import '../app/routes.dart';

class CebeciBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CebeciBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final canPop = Navigator.of(context).canPop();

    const items = [
      _NavItem(label: 'Portfoyum',      icon: Icons.pie_chart_rounded),
      _NavItem(label: 'Ekle',           icon: Icons.add_circle_rounded),
      _NavItem(label: 'Canlı Fiyatlar', icon: Icons.bar_chart_rounded),
      _NavItem(label: 'Haberler',       icon: Icons.newspaper_rounded),
    ];

    return Container(
      color: Colors.transparent,
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
              children: [
                if (canPop)
                  _BackNavButton(size: size),

                ...List.generate(items.length, (index) {
                  final isActive = index == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (onTap != null) onTap!(index);
                        if (index == currentIndex) return;
                        switch (index) {
                          case 0:
                            Navigator.pushReplacementNamed(context, AppRoutes.home);
                            break;
                          case 1:
                            Navigator.pushReplacementNamed(context, AppRoutes.add);
                            break;
                          case 2:
                            break;
                          case 3:
                            break;
                        }
                      },
                      child: _NavItemWidget(
                        item: items[index],
                        isActive: isActive,
                        size: size,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackNavButton extends StatelessWidget {
  final Size size;

  const _BackNavButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: size.width * 0.14,
        height: double.infinity,
        margin: EdgeInsets.only(left: size.width * 0.03),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(size.height * 0.04),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: size.width * 0.045,
            color: Colors.black87,
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