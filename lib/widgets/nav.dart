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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isSmallScreen = constraints.maxWidth < 350;

            return Row(
              children: [
                if (_isLoading)
                  SizedBox(
                    width: isSmallScreen ? 60 : 80,
                  )
                else if (!_isLoggedIn)
                  SizedBox(
                    width: isSmallScreen ? 60 : 80,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: 8,
                        ),
                        backgroundColor: const Color(0xFF1A1060),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: FittedBox(
                        child: const Text(
                          'Giriş Yap',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: isSmallScreen ? 60 : 80,
                  ),

                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: isSmallScreen ? 30 : 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(width: isSmallScreen ? 60 : 80),
              ],
            );
          },
        ),
      ),
    );
  }
}
