import 'package:flutter/material.dart';
import '../services/token_service.dart';

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
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            height: 32,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}