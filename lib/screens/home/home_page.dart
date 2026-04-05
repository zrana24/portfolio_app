import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';
import '../../widgets/ads_banner_widget.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../addPortfolio/assetDetail_page.dart';
import '../../services/portfolio_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  String? _expandedAssetKey; // Yeni: Hangi varlığın açık olduğunu tutar (Unique key)
  bool _isSavingAsset = false; // Yeni: Güncelleme sırasında loading göstermek için

  final PortfolioService _portfolioService = PortfolioService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _isCheckingAuth = false;
      });
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: _isCheckingAuth
            ? null
            : const CebeciBottomNav(currentIndex: 2),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: CebeciAppBar()),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: size.height * 0.006),
                        _buildHeader(size),

                        // Token yoksa ve empty state ise reklam gösterme (aşağıda göstereceğiz)
                        if (!(!_isLoggedIn && state is HomeEmpty))
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                            ),
                            /*child: const SizedBox(
                              child: AdsBannerWidget(key: Key('home_middle_ad')),
                            ),*/
                          ),

                        if (state is HomeLoading)
                          _buildSkeletonLoading(size)
                        else if (state is HomeLoaded)
                          _buildMainContent(state, size)
                        else if (state is HomeEmpty)
                            _buildEmptyState(size)
                          else if (state is HomeError)
                              _buildErrorState((state as HomeError).message, context, size),
                      ]),
                    ),
                  ),

                  if (!(!_isLoggedIn && state is HomeEmpty))
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.02,
                        ),
                        //child: const AdsBannerWidget(key: Key('home_bottom_ad')),
                      ),
                    ),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: size.height * 0.082 +
                          size.height * 0.015 +
                          bottomPadding +
                          size.height * 0.02 + 30,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Portföyüm",
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _ShimmerBox(
            width: size.width * 0.55,
            height: size.width * 0.55,
            borderRadius: size.width * 0.275,
          ),
        ),
        SizedBox(height: size.height * 0.05),
        _ShimmerBox(width: size.width * 0.4, height: size.height * 0.02),
        SizedBox(height: size.height * 0.015),
        _ShimmerBox(width: size.width * 0.55, height: size.height * 0.045),
        SizedBox(height: size.height * 0.015),
        Row(
          children: [
            _ShimmerBox(
              width: size.width * 0.38,
              height: size.height * 0.04,
              borderRadius: size.width * 0.05,
            ),
            SizedBox(width: size.width * 0.02),
            _ShimmerBox(
              width: size.width * 0.22,
              height: size.height * 0.04,
              borderRadius: size.width * 0.05,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),
        _ShimmerBox(width: size.width * 0.2, height: size.height * 0.02),
        SizedBox(height: size.height * 0.02),
        ...List.generate(
          3,
              (i) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: _ShimmerBox(
              width: double.infinity,
              height: size.height * 0.1,
              borderRadius: size.width * 0.06,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(HomeLoaded state, Size size) {
    final totalValue = state.totalValue;
    final totalProfitLoss = state.totalProfitLoss;
    final totalPnLPercent = state.totalPnLPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.categoryDistribution.isNotEmpty) ...[
          _buildDonutChartSection(state, size),
          SizedBox(height: size.height * 0.05),
        ],

        _buildSectionTitle("Portföyler Toplamı", size, hasArrows: true),
        Text(
          "${totalValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₺",
          style: TextStyle(
            fontSize: size.width * 0.09,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        Wrap(
          spacing: size.width * 0.02,
          runSpacing: size.height * 0.01,
          children: [
            // Toplam K/Z gösterimi
            _badge(
              size: size,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Toplam K/Z ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                  Text(
                    "${totalProfitLoss >= 0 ? '+' : ''}${totalProfitLoss.toStringAsFixed(0)} ₺",
                    style: TextStyle(
                      color: totalProfitLoss >= 0
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),

            // Toplam K/Z % gösterimi
            _badge(
              size: size,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${totalPnLPercent >= 0 ? '+' : ''}%${totalPnLPercent.toStringAsFixed(1).replaceAll('.', ',')}  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),

        // Varlık listesi (İçerik)
        if (state.assets.isNotEmpty) ...[
          _buildSectionTitle("İçerik", size, hasSort: true),
          SizedBox(height: size.height * 0.02),
          ...state.assets.asMap().entries.map((entry) {
            final index = entry.key;
            final asset = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.015),
              child: _expandableContentCard(asset, size, index),
            );
          }),
        ],

        // Portföy bilgisi (eğer varsa farklı bir yapıda)
        if (state.assets.isEmpty && state.totalValue > 0) ...[
          _buildSectionTitle("Portföy Özeti", size, hasSort: true),
          SizedBox(height: size.height * 0.02),
          _contentCard(
            "Ana Portföy",
            totalValue.toStringAsFixed(0),
            "${totalProfitLoss >= 0 ? '+' : ''}${totalProfitLoss.toStringAsFixed(0)}",
            "${totalPnLPercent >= 0 ? '+' : ''}%${totalPnLPercent.toStringAsFixed(1).replaceAll('.', ',')}",
            totalPnLPercent,
            size,
          ),
        ],
      ],
    );
  }

  Widget _buildDonutChartSection(HomeLoaded state, Size size) {
    final chartSize = size.width * 0.55;

    if (state.categoryDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(
              painter: DonutChartPainter(
                categories: state.categoryDistribution,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: state.categoryDistribution.map((cat) {
              return Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: _legendItem(
                  _getCategoryColor(cat.category),
                  cat.label,
                  "%${cat.percentage.toStringAsFixed(1).replaceAll('.', ',')}",
                  size,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'doviz': return const Color(0xFFFFD700);
      case 'altin': return const Color(0xFFEAB308);
      case 'emtia': return const Color(0xFF0D9488);
      case 'parite': return const Color(0xFF2563EB);
      case 'hisse': return const Color(0xFF6366F1);
      case 'kripto': return const Color(0xFFF59E0B);
      case 'nakit': return const Color(0xFF22C55E);
      default:
        final int hash = category.hashCode.abs();
        final List<Color> fallbackColors = [
          const Color(0xFFEC4899), const Color(0xFFA855F7), 
          const Color(0xFF06B6D4), const Color(0xFFF97316),
          const Color(0xFF14B8A6), const Color(0xFF6366F1)
        ];
        return fallbackColors[hash % fallbackColors.length];
    }
  }

  Widget _legendItem(Color color, String label, String value, Size size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size.width * 0.02,
          height: size.width * 0.02,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.03,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: size.width * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title,
      Size size, {
        bool hasArrows = false,
        bool hasSort = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF35238A),
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
          if (hasArrows)
            Row(
              children: [
                Icon(Icons.chevron_left,
                    color: Colors.grey.shade300, size: size.width * 0.06),
                Icon(Icons.chevron_right,
                    color: Colors.black87, size: size.width * 0.06),
              ],
            ),
          if (hasSort) _circularIcon(Icons.swap_vert, size),
        ],
      ),
    );
  }

  Widget _expandableContentCard(AssetItem asset, Size size, int index) {
    final String uniqueKey = "${asset.portfolioId}_${asset.id}_$index";
    final bool isExpanded = _expandedAssetKey == uniqueKey;
    final bool isPositive = asset.pnlPercent >= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.06),
      ),
      child: Column(
        children: [
          // Ana Kart Başlığı
          InkWell(
            onTap: () {
              setState(() {
                if (_expandedAssetKey == uniqueKey) {
                  _expandedAssetKey = null;
                } else {
                  _expandedAssetKey = uniqueKey;
                }
              });
            },
            borderRadius: BorderRadius.circular(size.width * 0.06),
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        asset.name,
                        style: TextStyle(
                          color: const Color(0xFF1A1A1A),
                          fontWeight: FontWeight.bold,
                          fontSize: size.width * 0.04,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "${asset.currentValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₺",
                            style: TextStyle(
                              fontSize: size.width * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: size.width * 0.06,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.005),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${asset.profitLoss >= 0 ? '+' : ''}${asset.profitLoss.toStringAsFixed(0)} ₺",
                        style: TextStyle(
                          color: isPositive
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Text(
                        "%${asset.pnlPercent.toStringAsFixed(1).replaceAll('.', ',')}",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                          fontSize: size.width * 0.035,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Genişleyen Düzenleme Bölümü
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                  size.width * 0.05, 0, size.width * 0.05, size.width * 0.05),
              child: Column(
                children: [
                  const Divider(),
                  SizedBox(height: size.height * 0.015),
                  
                  // Detay Bilgileri
                  _buildExpandableRow("Miktar", asset.quantity.toString(), size),
                  _buildExpandableRow("Alış Fiyatı", "${asset.purchasePrice.toStringAsFixed(2)} ₺", size),
                  _buildExpandableRow("Güncel Fiyat", "${asset.currentPrice.toStringAsFixed(2)} ₺", size),
                  
                  SizedBox(height: size.height * 0.02),
                  
                  // Kaydet (Düzenle) Butonu
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _navigateToDetail(asset),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1060),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Düzenle"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableRow(String label, String value, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: size.width * 0.035)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: size.width * 0.035)),
        ],
      ),
    );
  }

  Future<void> _navigateToDetail(AssetItem asset) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailPage(
          portfolioId: asset.portfolioId,
          assetId: asset.id,
          assetName: asset.name,
          symbol: asset.symbol,
          quantity: asset.quantity,
          purchasePrice: asset.purchasePrice,
          currentPrice: asset.currentPrice,
          currentValue: asset.currentValue,
          profitLoss: asset.profitLoss,
          pnlPercent: asset.pnlPercent,
        ),
      ),
    );

    if (result == true && mounted) {
      context.read<HomeBloc>().add(LoadHomeData());
    }
  }

  Widget _badge({required Widget child, required Size size}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04, vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: child,
    );
  }

  Widget _buildEmptyState(Size size) {
    final chartSize = size.width * 0.65;
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),

        // Üst reklam (Her durumda göster)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          //child: AdsBannerWidget(key: Key('empty_state_top_ad')),
        ),

        SizedBox(height: size.height * 0.02),

        Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(painter: EmptyDonutPainter()),
          ),
        ),
        SizedBox(height: size.height * 0.03),

        if (!_isLoggedIn) ...[
          Text(
            "Portföyünüzü görüntülemek için",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.025),
          ElevatedButton(
            onPressed: _navigateToLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A0B52),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.12,
                vertical: size.height * 0.018,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.08),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login, size: 20),
                SizedBox(width: size.width * 0.02),
                Text(
                  "Giriş Yap",
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Alt reklam (Giriş yapmamış kullanıcılar için)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            //child: AdsBannerWidget(key: Key('empty_state_bottom_ad')),
          ),
        ]
        else ...[
          Text(
            "Henüz portföyünüz bulunmuyor",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Alt reklam (Giriş yapmış ama portföyü olmayan kullanıcılar için)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            //child: AdsBannerWidget(key: Key('empty_state_bottom_ad')),
          ),
        ],
        SizedBox(height: size.height * 0.02),
      ],
    );
  }

  Widget _buildErrorState(String message, BuildContext context, Size size) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.1),
        Icon(
          Icons.error_outline,
          size: size.width * 0.2,
          color: Colors.red.shade300,
        ),
        SizedBox(height: size.height * 0.03),
        Text(
          "Bir hata oluştu",
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: size.height * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.04),
        ElevatedButton.icon(
          onPressed: () {
            context.read<HomeBloc>().add(LoadHomeData());
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Tekrar Dene"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1060),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.018,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(size.width * 0.08),
            ),
          ),
        ),
      ],
    );
  }


  Widget _circularIcon(IconData icon, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size.width * 0.045, color: Colors.black87),
    );
  }

  @override
  void dispose() {
    _portfolioService.dispose();
    super.dispose();
  }

  Widget _contentCard(
    String title,
    String value,
    String profit,
    String pnl,
    double pnlPercent,
    Size size,
  ) {
    final bool isPositive = pnlPercent >= 0;
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.06),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.03),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_outlined,
                    size: size.width * 0.06, color: const Color(0xFF1A0B52)),
              ),
              SizedBox(width: size.width * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: size.width * 0.035, color: Colors.grey),
                  ),
                  Text(
                    "$value ₺",
                    style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$profit ₺",
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  pnl,
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

class EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.15;

    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, size.width / 2 - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryDistribution> categories;

  DonutChartPainter({required this.categories}) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.15;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -math.pi / 2;
    const double gap = 0.05; // Dilimler arası boşluk miktarı

    for (var category in categories) {
      final sweepAngle = 2 * math.pi * (category.percentage / 100);
      
      // Çok küçük dilimler için boşluğu ayarla
      double adjustedSweep = sweepAngle - gap;
      if (adjustedSweep < 0.05) adjustedSweep = sweepAngle * 0.8;

      final paint = Paint()
        ..color = _getCategoryColor(category.category)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle + (gap / 2), // Boşluğun yarısı kadar ileriden başla
        adjustedSweep,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'doviz': return const Color(0xFFFFD700);
      case 'altin': return const Color(0xFFEAB308);
      case 'emtia': return const Color(0xFF0D9488);
      case 'parite': return const Color(0xFF2563EB);
      case 'hisse': return const Color(0xFF6366F1);
      case 'kripto': return const Color(0xFFF59E0B);
      case 'nakit': return const Color(0xFF22C55E);
      default:
        final int hash = category.hashCode.abs();
        final List<Color> fallbackColors = [
          const Color(0xFFEC4899), const Color(0xFFA855F7), 
          const Color(0xFF06B6D4), const Color(0xFFF97316),
          const Color(0xFF14B8A6), const Color(0xFF6366F1)
        ];
        return fallbackColors[hash % fallbackColors.length];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}