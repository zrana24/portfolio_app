import 'package:flutter/material.dart';

class CebeciAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CebeciAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Image.asset(
        'assets/logo.png',
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}