import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ads_banner_widget.dart';
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

  void _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/905300929388?text=${Uri.encodeComponent("Merhaba, yardıma ihtiyacım var.")}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch WhatsApp');
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
          Positioned(
            right: size.width * 0.04,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: _launchWhatsApp,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    CupertinoIcons.phone_circle_fill,
                    color: Color(0xFF25D366),
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
