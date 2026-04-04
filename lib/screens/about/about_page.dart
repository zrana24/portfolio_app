import 'package:flutter/material.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  final Color primaryPurple = const Color(0xFF1A0B52);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.06,
                  size.width * 0.04,
                  size.width * 0.06,
                  size.width * 0.02,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: size.width * 0.055,
                          color: primaryPurple,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.04),
                    Text(
                      "Cebeci Kuyumculuk",
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  SizedBox(height: size.height * 0.02),

                  Text(
                    'Yaşamın en değerli anlarını süsleyecek takıları sizlerle buluşturuyoruz. Modern ve zamansız geçmişin izleriyle harmanladığımız tasarımlarımız, en kaliteli işçilikleri ve otantik tınıları barındırıyor.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: const Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Text(
                    'CEBECİ GOLD markası ile tüm Türkiye\'ye sigortalı kargo imkanı ile gramlık altın ve gümüş ürünlerinin satışını gerçekleştirmektedir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: const Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  Text(
                    'Sektörde uzun deneyimimizle birlikte, yıllar içerisinde gerçekleştirdiğimiz teknolojik değişim ile alanında uzman ve dinamik insan kaynağımız ile daha yüksek hedeflere, daha kararlı bir şekilde yürüyoruz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      color: const Color(0xFF6B7280),
                      height: 1.6,
                    ),
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '1958\'den\nbu yana',
                          Icons.history_rounded,
                          size,
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
                        child: _buildStatCard(
                          '81 İl\nSigortalı kargo',
                          Icons.local_shipping_outlined,
                          size,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.015),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '%100\nGüvenli alışveriş',
                          Icons.verified_user_outlined,
                          size,
                        ),
                      ),
                      SizedBox(width: size.width * 0.04),
                      Expanded(
                        child: _buildStatCard(
                          '1000+\nMutlu müşteri',
                          Icons.sentiment_satisfied_alt_rounded,
                          size,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.04),

                  SizedBox(height: size.height * 0.095 + bottomPadding),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String text, IconData icon, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryPurple,
            primaryPurple.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.04),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size.width * 0.08,
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value, Size size) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: size.width * 0.05,
          color: primaryPurple,
        ),
        SizedBox(width: size.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: size.height * 0.003),
              Text(
                value,
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  color: const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}