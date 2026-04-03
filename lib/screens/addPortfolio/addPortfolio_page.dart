import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/addPortfolio/addportfolio_bloc.dart';
import '../../bloc/addPortfolio/addPortfolio_event.dart';
import '../../bloc/addPortfolio/addPortfolio_state.dart';
import '../../services/commodity_services.dart';
import '../../services/portfolio_services.dart';
import '../../widgets/nav.dart';
import '../../widgets/back_button.dart';
import '../../widgets/footer.dart';
import 'addAsset_page.dart';

class AddPortfolioPage extends StatelessWidget {
  const AddPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocProvider(
      create: (context) => AddPortfolioBloc()..add(LoadPortfolioTypes()),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context, size),
              Expanded(
                child: BlocBuilder<AddPortfolioBloc, AddPortfolioState>(
                  builder: (context, state) {
                    if (state is AddPortfolioLoading) {
                      return _buildSkeletonLoading(size, bottomPadding);
                    } else if (state is AddPortfolioLoaded) {
                      return _buildList(state.allCommodities, size, bottomPadding);
                    } else if (state is AddPortfolioError) {
                      return _buildErrorState(context, state.message, size);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: BackButtonWidget(),
          ),
          Text(
            "Portföy Ekle",
            style: TextStyle(
              fontSize: size.width * 0.045,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(Size size, double bottomPadding) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        right: size.width * 0.05,
        top: size.height * 0.01,
        bottom: size.height * 0.082 + size.height * 0.015 + bottomPadding + 20,
      ),
      itemCount: 15,
      separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
      itemBuilder: (_, __) => _SkeletonCard(size: size),
    );
  }

  Widget _buildList(List<CommodityItem> commodities, Size size, double bottomPadding) {
    if (commodities.isEmpty) {
      return _buildEmptyState(size);
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        right: size.width * 0.05,
        top: size.height * 0.01,
        bottom: size.height * 0.082 + size.height * 0.015 + bottomPadding + 20,
      ),
      itemCount: commodities.length,
      separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
      itemBuilder: (_, i) => _CommodityCard(
        commodity: commodities[i],
        size: size,
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: size.width * 0.2,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: size.height * 0.02),
          Text(
            "Henüz ürün bulunamadı",
            style: TextStyle(
              fontSize: size.width * 0.04,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AddPortfolioBloc>().add(LoadPortfolioTypes());
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Tekrar Dene"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A0B52),
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
        ),
      ),
    );
  }
}

class _CommodityCard extends StatelessWidget {
  final CommodityItem commodity;
  final Size size;

  const _CommodityCard({
    required this.commodity,
    required this.size,
  });

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'altin':
        return const Color(0xFFFFD700);
      case 'doviz':
        return const Color(0xFF43A047);
      case 'kripto':
        return const Color(0xFFF9A825);
      case 'emtia':
        return const Color(0xFFFB8C00);
      case 'parite':
        return const Color(0xFF5C9CE5);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'altin':
        return Icons.brightness_5;
      case 'doviz':
        return Icons.euro;
      case 'kripto':
        return Icons.currency_bitcoin;
      case 'emtia':
        return Icons.grain;
      case 'parite':
        return Icons.compare_arrows;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = commodity.dailyChangePercent >= 0;

    return GestureDetector(
      onTap: () {
        _showPortfolioNameDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(size.width * 0.04),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.11,
              height: size.width * 0.11,
              decoration: BoxDecoration(
                color: _getCategoryColor(commodity.category),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(commodity.category),
                color: Colors.white,
                size: size.width * 0.055,
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commodity.name,
                    style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: size.height * 0.003),
                  Text(
                    commodity.symbol,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  commodity.bid.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: size.height * 0.003),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: size.width * 0.03,
                      color: isPositive
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      "${isPositive ? '+' : ''}${commodity.dailyChangePercent.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        fontWeight: FontWeight.w600,
                        color: isPositive
                            ? Colors.green.shade400
                            : Colors.red.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPortfolioNameDialog(BuildContext context) async {
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        title: Text(
          'Portföy İsmi',
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Örn: ${commodity.name} Portföyüm',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.018,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: const BorderSide(color: Color(0xFF1A0B52), width: 1.5),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              Navigator.of(dialogContext).pop(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: size.width * 0.038,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                Navigator.of(dialogContext).pop(nameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A0B52),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.06,
                vertical: size.height * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
            ),
            child: Text(
              'Portföy Oluştur',
              style: TextStyle(fontSize: size.width * 0.038),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      // Portfolio oluştur
      _createPortfolio(context, result);
    }
  }

  Future<void> _createPortfolio(BuildContext context, String portfolioName) async {
    try {
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
        ),
      );

      final portfolioService = PortfolioService();
      final newPortfolio = await portfolioService.createPortfolio(
        name: portfolioName,
        currency: 'TRY',
        isDefault: false,
      );

      // Loading'i kapat
      if (context.mounted) {
        Navigator.of(context).pop(); // Loading dialog'u kapat
      }

      // Kısa bir gecikme
      await Future.delayed(const Duration(milliseconds: 100));

      if (!context.mounted) return;

      // Success mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$portfolioName oluşturuldu!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );

      // AddAsset sayfasına git - portfolioId ile
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AddAssetPage(
            symbol: commodity.symbol,
            name: commodity.name,
            portfolioId: newPortfolio.id,
          ),
        ),
      );

    } catch (e) {
      // Loading'i kapat
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Error mesajı
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _SkeletonCard extends StatelessWidget {
  final Size size;

  const _SkeletonCard({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Row(
        children: [
          _ShimmerBox(
            width: size.width * 0.11,
            height: size.width * 0.11,
            borderRadius: size.width * 0.055,
          ),
          SizedBox(width: size.width * 0.04),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(
                width: size.width * 0.35,
                height: size.height * 0.02,
                borderRadius: 6,
              ),
              SizedBox(height: size.height * 0.006),
              _ShimmerBox(
                width: size.width * 0.2,
                height: size.height * 0.016,
                borderRadius: 4,
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(
                width: size.width * 0.15,
                height: size.height * 0.02,
                borderRadius: 6,
              ),
              SizedBox(height: size.height * 0.006),
              _ShimmerBox(
                width: size.width * 0.12,
                height: size.height * 0.016,
                borderRadius: 4,
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