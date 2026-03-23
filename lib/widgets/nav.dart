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
    final size = MediaQuery.of(context).size;

    return Container(
      color: Colors.white,
      child: Container(
        height: size.height * 0.065,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.008,
        ),
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            height: size.height * 0.04,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}