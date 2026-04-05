import 'package:flutter/material.dart';
import '../../services/portfolio_services.dart';
import '../../services/commodity_services.dart';
import '../../widgets/nav.dart';
import '../../widgets/back_button.dart';
import '../../widgets/footer.dart';
import '../../widgets/ads_banner_widget.dart';
import 'addAsset_page.dart';

class AddPortfolioPage extends StatefulWidget {
  const AddPortfolioPage({super.key});

  @override
  State<AddPortfolioPage> createState() => _AddPortfolioPageState();
}

class _AddPortfolioPageState extends State<AddPortfolioPage> {
  final PortfolioService _portfolioService = PortfolioService();
  final CommodityService _commodityService = CommodityService();

  List<Portfolio> _portfolios = [];
  List<CommodityItem> _commodities = [];
  Portfolio? _selectedPortfolio;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _portfolioService.getPortfolios(),
        _commodityService.fetchCommodities(),
      ]);

      if (mounted) {
        setState(() {
          _portfolios = results[0] as List<Portfolio>;
          _commodities = results[1] as List<CommodityItem>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _portfolioService.dispose();
    _commodityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: true,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context, size),
            Expanded(
              child: _isLoading
                  ? _buildSkeletonLoading(size)
                  : _errorMessage != null
                  ? _buildErrorState(size)
                  : _buildContent(size, bottomPadding),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Size size) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      decoration: const BoxDecoration(
        //color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
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

  Widget _buildContent(Size size, double bottomPadding) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: size.height * 0.095 + bottomPadding, // navbar + padding için yer
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),

          // Üst Reklam
          //const AdsBannerWidget(),
          //SizedBox(height: size.height * 0.02),

          // Portföy Seç Bölümü
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Portföy Seç",
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: size.height * 0.012),
                _buildPortfolioSelector(size),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.03),

          // Varlık Listesi Bölümü
          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Varlık Seç",
                  style: TextStyle(
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.015),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _commodities.length,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.01),
              itemBuilder: (_, i) => _CommodityCard(
                commodity: _commodities[i],
                size: size,
                onTap: () => _handleCommodityTap(_commodities[i]),
              ),
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Alt Reklam
          //const AdsBannerWidget(),
          //SizedBox(height: size.height * 0.02),
        ],
      ),
    );
  }

  Widget _buildPortfolioSelector(Size size) {
    return GestureDetector(
      onTap: () => _showPortfolioBottomSheet(size),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.045,
          vertical: size.height * 0.02,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0B52), Color(0xFF2D1B6B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size.width * 0.035),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A0B52).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedPortfolio?.name ?? 'Portföy Seçin',
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.all(size.width * 0.015),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: size.width * 0.05,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPortfolioBottomSheet(Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(size.width * 0.06),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: size.height * 0.015),
              width: size.width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Başlık
            Padding(
              padding: EdgeInsets.only(
                top: size.height * 0.02,
                left: size.width * 0.05,
                right: size.width * 0.05,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Portföylerim',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Portföy Listesi
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.015,
                ),
                children: [
                  if (_portfolios.isNotEmpty)
                    ..._portfolios.map((portfolio) {
                      final isSelected = _selectedPortfolio?.id == portfolio.id;
                      return _buildPortfolioItem(
                        portfolio: portfolio,
                        isSelected: isSelected,
                        size: size,
                        onTap: () {
                          setState(() {
                            _selectedPortfolio = portfolio;
                          });
                          Navigator.pop(sheetContext);
                        },
                      );
                    }),
                ],
              ),
            ),

            // Yeni Portföy Oluştur Butonu
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                top: size.height * 0.015,
                bottom: size.height * 0.025,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _showCreatePortfolioDialog(size);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A0B52),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.035),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 22),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Yeni Portföy Oluştur',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPortfolioItem({
    required Portfolio portfolio,
    required bool isSelected,
    required Size size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.012),
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A0B52) : Colors.white,
          borderRadius: BorderRadius.circular(size.width * 0.035),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A0B52) : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF1A0B52).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.11,
              height: size.width * 0.11,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.15)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [
                    const Color(0xFF1A0B52).withOpacity(0.1),
                    const Color(0xFF1A0B52).withOpacity(0.05)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: isSelected ? Colors.white : const Color(0xFF1A0B52),
                size: size.width * 0.05,
              ),
            ),
            SizedBox(width: size.width * 0.035),
            Expanded(
              child: Text(
                portfolio.name,
                style: TextStyle(
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
                  letterSpacing: 0.2,
                ),
              ),
            ),
            // Güncelle butonu
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showUpdatePortfolioDialog(portfolio, size);
              },
              child: Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: isSelected ? Colors.white : Colors.blue.shade600,
                  size: size.width * 0.045,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.015),
            // Sil butonu
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(portfolio, size);
              },
              child: Container(
                padding: EdgeInsets.all(size.width * 0.02),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.15)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: isSelected ? Colors.white : Colors.red.shade600,
                  size: size.width * 0.045,
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: size.width * 0.015),
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: size.width * 0.055,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showUpdatePortfolioDialog(Portfolio portfolio, Size size) async {
    final TextEditingController nameController = TextEditingController(
      text: portfolio.name,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Text(
          'Portföy Güncelle',
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Portföy adı',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.045,
              vertical: size.height * 0.02,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.035),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.035),
              borderSide: const BorderSide(color: Color(0xFF1A0B52), width: 2),
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
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
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
                horizontal: size.width * 0.07,
                vertical: size.height * 0.017,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.035),
              ),
              elevation: 0,
            ),
            child: Text(
              'Güncelle',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _updatePortfolio(portfolio.id, result);
    }
  }

  Future<void> _updatePortfolio(int portfolioId, String newName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
        ),
      );

      await _portfolioService.updatePortfolio(
        portfolioId: portfolioId,
        name: newName,
      );

      await _loadData();

      if (mounted) {
        setState(() {
          _selectedPortfolio = _portfolios.firstWhere(
                (p) => p.id == portfolioId,
            orElse: () =>
            _portfolios.isNotEmpty ? _portfolios.first : _selectedPortfolio!,
          );
        });
      }

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Portföy güncellendi!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(Portfolio portfolio, Size size) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red.shade600,
              size: size.width * 0.07,
            ),
            SizedBox(width: size.width * 0.03),
            Text(
              'Portföy Sil',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          '"${portfolio.name}" portföyünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(
            fontSize: size.width * 0.04,
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.07,
                vertical: size.height * 0.017,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.035),
              ),
              elevation: 0,
            ),
            child: Text(
              'Sil',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _deletePortfolio(portfolio.id);
    }
  }

  Future<void> _deletePortfolio(int portfolioId) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
        ),
      );

      await _portfolioService.deletePortfolio(portfolioId: portfolioId);

      await _loadData();

      if (_selectedPortfolio?.id == portfolioId) {
        setState(() {
          _selectedPortfolio =
          _portfolios.isNotEmpty ? _portfolios.first : null;
        });
      }

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Portföy silindi!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showCreatePortfolioDialog(Size size) async {
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.05),
        ),
        title: Text(
          'Yeni Portföy',
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Örn: Altın Portföyüm',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.045,
              vertical: size.height * 0.02,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.035),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.035),
              borderSide: const BorderSide(color: Color(0xFF1A0B52), width: 2),
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
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
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
                horizontal: size.width * 0.07,
                vertical: size.height * 0.017,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.035),
              ),
              elevation: 0,
            ),
            child: Text(
              'Oluştur',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await _createPortfolio(result);
    }
  }

  Future<void> _createPortfolio(String portfolioName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
        ),
      );

      final newPortfolio = await _portfolioService.createPortfolio(
        name: portfolioName,
        currency: 'TRY',
        isDefault: _portfolios.isEmpty,
      );

      await _loadData();

      if (mounted) {
        Navigator.of(context).pop();

        setState(() {
          _selectedPortfolio = _portfolios.firstWhere(
                (p) => p.id == newPortfolio.id,
            orElse: () => _portfolios.last,
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$portfolioName oluşturuldu!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleCommodityTap(CommodityItem commodity) {
    if (_selectedPortfolio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Lütfen önce bir portföy seçin'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetPage(
          symbol: commodity.symbol,
          name: commodity.name,
          portfolioId: _selectedPortfolio!.id,
        ),
      ),
    );
  }

  Widget _buildSkeletonLoading(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          _ShimmerBox(width: size.width * 0.3, height: size.height * 0.025),
          SizedBox(height: size.height * 0.015),
          _ShimmerBox(
            width: double.infinity,
            height: size.height * 0.065,
            borderRadius: size.width * 0.035,
          ),
          SizedBox(height: size.height * 0.03),
          _ShimmerBox(width: size.width * 0.3, height: size.height * 0.025),
          SizedBox(height: size.height * 0.015),
          Expanded(
            child: ListView.separated(
              itemCount: 8,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.01),
              itemBuilder: (_, __) => _ShimmerBox(
                width: double.infinity,
                height: size.height * 0.075,
                borderRadius: size.width * 0.035,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.08),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: size.width * 0.15,
                color: Colors.red.shade400,
              ),
            ),
            SizedBox(height: size.height * 0.03),
            Text(
              "Bir hata oluştu",
              style: TextStyle(
                fontSize: size.width * 0.055,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Text(
              _errorMessage ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.038,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Tekrar Dene"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A0B52),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.1,
                  vertical: size.height * 0.02,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(size.width * 0.035),
                ),
                elevation: 0,
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
  final VoidCallback onTap;

  const _CommodityCard({
    required this.commodity,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = commodity.dailyChangePercent >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(size.width * 0.035),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
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
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: size.height * 0.004),
                  Text(
                    commodity.symbol,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.3,
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
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: size.height * 0.004),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.02,
                    vertical: size.height * 0.003,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(size.width * 0.015),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: size.width * 0.03,
                        color: isPositive
                            ? Colors.green.shade600
                            : Colors.red.shade600,
                      ),
                      SizedBox(width: size.width * 0.008),
                      Text(
                        "${isPositive ? '+' : ''}${commodity.dailyChangePercent.toStringAsFixed(2)}%",
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w600,
                          color: isPositive
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: size.width * 0.025),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFD1D5DB),
              size: size.width * 0.055,
            ),
          ],
        ),
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