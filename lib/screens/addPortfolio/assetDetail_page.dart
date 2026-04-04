import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/portfolio_services.dart';
import '../../widgets/back_button.dart';

class AssetDetailPage extends StatefulWidget {
  final int portfolioId;
  final int assetId;
  final String assetName;
  final String symbol;
  final double quantity;
  final double purchasePrice;
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
  final double pnlPercent;

  const AssetDetailPage({
    super.key,
    required this.portfolioId,
    required this.assetId,
    required this.assetName,
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    required this.pnlPercent,
  });

  @override
  State<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends State<AssetDetailPage> {
  final PortfolioService _portfolioService = PortfolioService();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.quantity.toString();
    _purchasePriceController.text = widget.purchasePrice.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _portfolioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(size),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  size.width * 0.05,
                  size.width * 0.05,
                  size.width * 0.05,
                  size.width * 0.05 + bottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummarySection(size),
                    SizedBox(height: size.height * 0.025),
                    _buildEditSection(size),
                    SizedBox(height: size.height * 0.025),
                    _buildActionButtons(size),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
      ),
      child: Row(
        children: [
          const BackButtonWidget(),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Text(
              widget.assetName,
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Size size) {
    final isPositive = widget.profitLoss >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.symbol,
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: size.height * 0.008),
        Text(
          '₺${widget.currentValue.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
          )}',
          style: TextStyle(
            fontSize: size.width * 0.1,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: size.height * 0.012),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: size.width * 0.035,
                    color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                  ),
                  SizedBox(width: size.width * 0.01),
                  Text(
                    '${isPositive ? '+' : ''}₺${widget.profitLoss.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w700,
                      color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
                vertical: size.height * 0.008,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(size.width * 0.02),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${widget.pnlPercent.toStringAsFixed(2)}%',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, Size size) {
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.012),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.038,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Düzenle',
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: size.height * 0.02),
          _buildEditField(
            label: 'Miktar',
            controller: _quantityController,
            size: size,
          ),
          SizedBox(height: size.height * 0.015),
          _buildEditField(
            label: 'Alış Fiyatı',
            controller: _purchasePriceController,
            size: size,
          ),
        ],
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required Size size,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: size.height * 0.008),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.015,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(size.width * 0.03),
              borderSide: const BorderSide(color: Color(0xFF1A0B52), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Size size) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A0B52),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
              elevation: 0,
            ),
            child: _isSaving
                ? SizedBox(
              height: size.width * 0.05,
              width: size.width * 0.05,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              'Değişiklikleri Kaydet',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.015),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isSaving ? null : _confirmDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade600),
              padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.03),
              ),
            ),
            child: Text(
              'Varlığı Sil',
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveChanges() async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0;

    if (quantity <= 0 || purchasePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Miktar ve fiyat 0\'dan büyük olmalıdır'),
          backgroundColor: Colors.orange.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _portfolioService.updateAsset(
        portfolioId: widget.portfolioId,
        assetId: widget.assetId,
        quantity: quantity,
        purchasePrice: purchasePrice,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Varlık güncellendi!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete() async {
    final size = MediaQuery.of(context).size;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.red.shade400,
              size: size.width * 0.06,
            ),
            SizedBox(width: size.width * 0.03),
            const Text('Varlığı Sil'),
          ],
        ),
        content: Text(
          '"${widget.assetName}" varlığını silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
          style: TextStyle(fontSize: size.width * 0.038),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'İptal',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: size.width * 0.038,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              'Sil',
              style: TextStyle(fontSize: size.width * 0.038),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAsset();
    }
  }

  Future<void> _deleteAsset() async {
    setState(() => _isSaving = true);

    try {
      await _portfolioService.deleteAsset(
        portfolioId: widget.portfolioId,
        assetId: widget.assetId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Varlık silindi!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}