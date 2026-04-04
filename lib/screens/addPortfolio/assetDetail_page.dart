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

  bool _isEditing = true; // Doğrudan düzenleme modunda açılması için true yapıldı
  bool _isLoading = false;

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Row(
                children: [
                  const BackButtonWidget(),
                  SizedBox(width: size.width * 0.03),
                  Expanded(
                    child: Text(
                      widget.assetName,
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  // Save Button (Always in edit mode now)
                  IconButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: const Icon(
                      Icons.save,
                      color: Color(0xFF1A0B52),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Stats Card (Only visible when NOT editing, but now always hidden or simplified)
                    if (!_isEditing) ...[
                      _buildStatsCard(size),
                      SizedBox(height: size.height * 0.03),
                    ],

                    // Edit Form (visible when editing)
                    if (_isEditing) ...[
                      _buildEditSection(size),
                      SizedBox(height: size.height * 0.03),
                    ],

                    // Delete Button
                    _buildDeleteButton(size),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(Size size) {
    final isPositive = widget.profitLoss >= 0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symbol
          Text(
            widget.symbol,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.01),

          // Current Value
          Text(
            "${widget.currentValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₺",
            style: TextStyle(
              fontSize: size.width * 0.08,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Profit/Loss
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up
                          : Icons.trending_down,
                      size: size.width * 0.04,
                      color: isPositive
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      "${isPositive ? '+' : ''}${widget.profitLoss.toStringAsFixed(0)} ₺",
                      style: TextStyle(
                        fontSize: size.width * 0.035,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
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
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Text(
                  "${isPositive ? '+' : ''}%${widget.pnlPercent.toStringAsFixed(1).replaceAll('.', ',')}",
                  style: TextStyle(
                    fontSize: size.width * 0.035,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.025),

          // Details
          Divider(color: Colors.grey.shade300),
          SizedBox(height: size.height * 0.015),

          _buildDetailRow('Miktar', '${widget.quantity}', size),
          SizedBox(height: size.height * 0.012),
          _buildDetailRow('Alış Fiyatı', '${widget.purchasePrice.toStringAsFixed(2)} ₺', size),
          SizedBox(height: size.height * 0.012),
          _buildDetailRow('Güncel Fiyat', '${widget.currentPrice.toStringAsFixed(2)} ₺', size),
          SizedBox(height: size.height * 0.012),
          _buildDetailRow('Toplam Yatırım', '${(widget.quantity * widget.purchasePrice).toStringAsFixed(0)} ₺', size),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildEditSection(Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Düzenleme Modu',
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A0B52),
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // Miktar
          _buildEditField(
            label: 'Miktar',
            controller: _quantityController,
            size: size,
          ),
          SizedBox(height: size.height * 0.015),

          // Alış Fiyatı
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
            color: Colors.grey.shade700,
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
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.015,
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
        ),
      ],
    );
  }

  Widget _buildDeleteButton(Size size) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _confirmDelete,
        icon: const Icon(Icons.delete_outline),
        label: Text(
          'Varlığı Sil',
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final purchasePrice = double.tryParse(_purchasePriceController.text) ?? 0;

    if (quantity <= 0 || purchasePrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Miktar ve fiyat 0\'dan büyük olmalıdır'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _portfolioService.updateAsset(
        portfolioId: widget.portfolioId,
        assetId: widget.assetId,
        quantity: quantity,
        purchasePrice: purchasePrice,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varlık güncellendi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Geri dön ve home page'i yenile
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
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
                color: Colors.grey.shade600,
                fontSize: size.width * 0.038,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
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
    setState(() {
      _isLoading = true;
    });

    try {
      await _portfolioService.deleteAsset(
        portfolioId: widget.portfolioId,
        assetId: widget.assetId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Varlık silindi!'),
            backgroundColor: Colors.green,
          ),
        );

        // Geri dön ve home page'i yenile
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}