import 'package:flutter/material.dart';
import '../../services/portfolio_services.dart';
import '../../services/commodity_services.dart';
import '../../widgets/nav.dart';
import '../../widgets/back_button.dart';
import '../../widgets/footer.dart';
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
      backgroundColor: Colors.white,
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

  Widget _buildContent(Size size, double bottomPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),

          // Portföy Seç Başlığı
          Text(
            "Portföy Seç",
            style: TextStyle(
              fontSize: size.width * 0.042,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: size.height * 0.015),

          // Seçili Portföy Dropdown
          _buildPortfolioSelector(size),
          SizedBox(height: size.height * 0.025),

          // Varlık Listesi Başlığı
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Varlık Seç",
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              Text(
                "${_commodities.length} varlık",
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),

          // Varlık Listesi
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(), // Smooth scroll
              padding: EdgeInsets.only(
                bottom: size.height * 0.082 +
                    size.height * 0.015 +
                    bottomPadding +
                    20,
              ),
              itemCount: _commodities.length,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
              itemBuilder: (_, i) => _CommodityCard(
                commodity: _commodities[i],
                size: size,
                onTap: () => _handleCommodityTap(_commodities[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSelector(Size size) {
    return GestureDetector(
      onTap: () => _showPortfolioBottomSheet(size),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.018,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A0B52),
          borderRadius: BorderRadius.circular(size.width * 0.03),
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
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: size.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  void _showPortfolioBottomSheet(Size size) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false, // Sayfanın yarısından fazla olmasın
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.5, // Maksimum yarım ekran
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(size.width * 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Başlık - Fixed (scroll dışında)
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
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Portföy Listesi - Scrollable
            Flexible(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(), // Smooth scroll
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.01,
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

            // Yeni Portföy Oluştur Butonu - Fixed (scroll dışında)
            Padding(
              padding: EdgeInsets.only(
                left: size.width * 0.05,
                right: size.width * 0.05,
                top: size.height * 0.015,
                bottom: size.height * 0.02,
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
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(size.width * 0.03),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, size: 20),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Portföy Ekle',
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.bold,
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
        margin: EdgeInsets.only(bottom: size.height * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.015,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A0B52) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(size.width * 0.03),
          border: Border.all(
            color: isSelected ? const Color(0xFF1A0B52) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.1,
              height: size.width * 0.1,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF1A0B52).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_outlined,
                color: isSelected ? Colors.white : const Color(0xFF1A0B52),
                size: size.width * 0.05,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text(
                portfolio.name,
                style: TextStyle(
                  fontSize: size.width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
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
                child: Icon(
                  Icons.edit_outlined,
                  color: isSelected ? Colors.white : Colors.blue.shade400,
                  size: size.width * 0.05,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.01),
            // Sil butonu
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(portfolio, size);
              },
              child: Container(
                padding: EdgeInsets.all(size.width * 0.02),
                child: Icon(
                  Icons.delete_outline,
                  color: isSelected ? Colors.white : Colors.red.shade400,
                  size: size.width * 0.05,
                ),
              ),
            ),
            SizedBox(width: size.width * 0.01),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: size.width * 0.05,
              ),
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
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        title: Text(
          'Portföy Güncelle',
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Portföy adı',
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
              'Güncelle',
              style: TextStyle(fontSize: size.width * 0.038),
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
      // Loading göster
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

      // Portföy listesini güncelle
      await _loadData();

      // Güncellenen portföyü seçili tut
      if (mounted) {
        setState(() {
          _selectedPortfolio = _portfolios.firstWhere(
                (p) => p.id == portfolioId,
            orElse: () => _portfolios.isNotEmpty ? _portfolios.first : _selectedPortfolio!,
          );
        });
      }

      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Success mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portföy güncellendi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Error mesajı
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

  void _showDeleteConfirmation(Portfolio portfolio, Size size) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_outlined,
              color: Colors.red.shade400,
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.03),
            Text(
              'Portföy Sil',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '"${portfolio.name}" portföyünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(
            fontSize: size.width * 0.038,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: size.width * 0.038,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
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
              'Sil',
              style: TextStyle(fontSize: size.width * 0.038),
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
      // Loading göster
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (loadingContext) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF1A0B52)),
        ),
      );

      await _portfolioService.deletePortfolio(portfolioId: portfolioId);

      // Portföy listesini güncelle
      await _loadData();

      // Seçili portföy silinmişse, seçimi temizle
      if (_selectedPortfolio?.id == portfolioId) {
        setState(() {
          _selectedPortfolio = _portfolios.isNotEmpty ? _portfolios.first : null;
        });
      }

      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Success mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Portföy silindi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Error mesajı
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

  void _showCreatePortfolioDialog(Size size) async {
    final TextEditingController nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        title: Text(
          'Portföy Adı',
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Örn: Altın Portföyüm',
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
              'Oluştur',
              style: TextStyle(fontSize: size.width * 0.038),
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
      // Loading göster
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

      // Portföy listesini güncelle
      await _loadData();

      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Yeni portföyü seç
        setState(() {
          _selectedPortfolio = _portfolios.firstWhere(
                (p) => p.id == newPortfolio.id,
            orElse: () => _portfolios.last,
          );
        });

        // Success mesajı
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$portfolioName oluşturuldu!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Loading'i kapat
      if (mounted) {
        Navigator.of(context).pop();

        // Error mesajı
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

  void _handleCommodityTap(CommodityItem commodity) {
    if (_selectedPortfolio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen önce bir portföy seçin'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // AddAsset sayfasına git
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
          SizedBox(height: size.height * 0.01),
          _ShimmerBox(width: size.width * 0.3, height: size.height * 0.025),
          SizedBox(height: size.height * 0.015),
          _ShimmerBox(
            width: double.infinity,
            height: size.height * 0.06,
            borderRadius: size.width * 0.03,
          ),
          SizedBox(height: size.height * 0.025),
          _ShimmerBox(width: size.width * 0.3, height: size.height * 0.025),
          SizedBox(height: size.height * 0.015),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
              itemBuilder: (_, __) => _ShimmerBox(
                width: double.infinity,
                height: size.height * 0.08,
                borderRadius: size.width * 0.04,
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
              _errorMessage ?? 'Bilinmeyen hata',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.035,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            ElevatedButton.icon(
              onPressed: _loadData,
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
  final VoidCallback onTap;

  const _CommodityCard({
    required this.commodity,
    required this.size,
    required this.onTap,
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
      onTap: onTap,
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
            SizedBox(width: size.width * 0.02),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: size.width * 0.05,
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