import 'package:flutter/material.dart';
import '../services/token_service.dart';
import 'ads_banner_widget.dart';

class CebeciAppBar extends StatefulWidget {
  const CebeciAppBar({super.key});

  @override
  State<CebeciAppBar> createState() => _CebeciAppBarState();
}

class _CebeciAppBarState extends State<CebeciAppBar> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    final token = await TokenService.getToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.white,
      height: size.height * 0.060,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/nav_img.jpg',
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}