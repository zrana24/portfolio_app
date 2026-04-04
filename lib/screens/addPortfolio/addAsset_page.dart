import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/addAsset/addAsset_bloc.dart';
import '../../bloc/addAsset/addAsset_event.dart';
import '../../bloc/addAsset/addAsset_state.dart';
import '../../widgets/back_button.dart';
import '../../app/routes.dart';

class AddAssetPage extends StatefulWidget {
  final String symbol;
  final String? name;
  final String? portfolioName;
  final int? portfolioId;

  const AddAssetPage({
    super.key,
    required this.symbol,
    this.name,
    this.portfolioName,
    this.portfolioId,
  });

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();

  @override
  void dispose() {
    _assetNameController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AddAssetBloc(
        symbol: widget.symbol,
        portfolioName: widget.portfolioName,
        portfolioId: widget.portfolioId,
      )..add(LoadAssetData()),
      child: BlocListener<AddAssetBloc, AddAssetState>(
        listener: (context, state) {
          if (state is AddAssetLoaded) {
            if (_assetNameController.text != state.assetName) {
              _assetNameController.text = state.assetName;
            }

            final currentQuantity = double.tryParse(_quantityController.text) ?? 0;
            if (currentQuantity != state.quantity) {
              _quantityController.text = state.quantity == 0 ? '' : state.quantity.toString();
            }

            final currentPrice = double.tryParse(_purchasePriceController.text) ?? 0;
            if (currentPrice != state.purchasePrice) {
              _purchasePriceController.text = state.purchasePrice == 0 ? '' : state.purchasePrice.toString();
            }
          }

          if (state is AddAssetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Varlık başarıyla eklendi'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.add,
                  (route) => false,
            );
          } else if (state is AddAssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SafeArea(
            child: BlocBuilder<AddAssetBloc, AddAssetState>(
              builder: (context, state) {
                if (state is AddAssetLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1A0B52)));
                } else if (state is AddAssetLoaded) {
                  return _buildContent(context, state, size);
                } else if (state is AddAssetSaving) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1A0B52)));
                } else if (state is AddAssetError) {
                  return _buildErrorState(context, state.message, size);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, Size size) {
    return Column(
      children: [
        _buildAppBar(context, widget.name ?? widget.symbol, size),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: size.width * 0.15,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Bir hata oluştu',
                    style: TextStyle(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: size.height * 0.01),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  ElevatedButton.icon(
                    onPressed: () => context.read<AddAssetBloc>().add(LoadAssetData()),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tekrar Dene'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A0B52),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.08,
                        vertical: size.height * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, String title, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: const BoxDecoration(
        color: Colors.white,
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
          const Align(
            alignment: Alignment.centerLeft,
            child: BackButtonWidget(),
          ),
          Text(
            '$title Ekle',
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

  Widget _buildContent(BuildContext context, AddAssetLoaded state, Size size) {
    return Column(
      children: [
        _buildAppBar(context, state.name, size),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                _buildPriceSection(state, size),
                SizedBox(height: size.height * 0.02),
                _buildInputSection(context, state, size),
                SizedBox(height: size.height * 0.02),
                _buildSaveButton(context, state, size),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(AddAssetLoaded state, Size size) {
    final isPositive = state.dailyChange >= 0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.035),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anlık Fiyat',
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: size.height * 0.005),
                  Text(
                    state.currentPrice.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: size.width * 0.065,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.006,
                ),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(size.width * 0.02),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: size.width * 0.035,
                      color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                    ),
                    SizedBox(width: size.width * 0.01),
                    Text(
                      '${isPositive ? '+' : ''}${state.dailyChange.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        fontWeight: FontWeight.w600,
                        color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          SizedBox(
            height: size.height * 0.15,
            child: _buildLineChart(state, size, isPositive),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(AddAssetLoaded state, Size size, bool isPositive) {
    if (state.priceHistory.chart.data.isEmpty) {
      return Center(
        child: Text(
          'Grafik verisi yok',
          style: TextStyle(
            fontSize: size.width * 0.035,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < state.priceHistory.chart.data.length; i++) {
      spots.add(FlSpot(i.toDouble(), state.priceHistory.chart.data[i]));
    }

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFF3F4F6),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: minY * 0.998,
        maxY: maxY * 1.002,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2.5,
                    strokeColor: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isPositive ? Colors.green.shade600 : Colors.red.shade600).withOpacity(0.15),
                  (isPositive ? Colors.green.shade600 : Colors.red.shade600).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, AddAssetLoaded state, Size size) {
    return Column(
      children: [
        _buildPortfolioSelector(context, state, size),
        SizedBox(height: size.height * 0.015),
        _buildInput(
          label: 'Varlık Adı',
          hint: 'Örn: Altın Gram',
          controller: _assetNameController,
          onChanged: (value) {
            context.read<AddAssetBloc>().add(UpdateAssetName(assetName: value));
          },
          size: size,
          isNumeric: false,
        ),
        SizedBox(height: size.height * 0.015),
        _buildInput(
          label: 'Miktar',
          hint: '0.0',
          controller: _quantityController,
          onChanged: (value) {
            final quantity = double.tryParse(value) ?? 0.0;
            context.read<AddAssetBloc>().add(UpdateQuantity(quantity: quantity));
          },
          size: size,
        ),
        SizedBox(height: size.height * 0.015),
        _buildInput(
          label: 'Birim Fiyat (Opsiyonel)',
          hint: '0.0',
          controller: _purchasePriceController,
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0.0;
            context.read<AddAssetBloc>().add(UpdatePurchasePrice(price: price));
          },
          size: size,
        ),
      ],
    );
  }

  Widget _buildPortfolioSelector(BuildContext context, AddAssetLoaded state, Size size) {
    return GestureDetector(
      onTap: () => _showPortfolioSheet(context, state, size),
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
              color: const Color(0xFF1A0B52).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                state.selectedPortfolio.name,
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
                size: size.width * 0.045,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPortfolioSheet(BuildContext context, AddAssetLoaded state, Size size) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(size.width * 0.06),
          ),
        ),
        constraints: BoxConstraints(
          maxHeight: size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
                    'Portföy Seç',
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

            // Scrollable portföy listesi
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.015,
                ),
                itemCount: state.portfolios.length,
                itemBuilder: (context, index) {
                  final portfolio = state.portfolios[index];
                  final isSelected = portfolio.id == state.selectedPortfolio.id;

                  return Container(
                    margin: EdgeInsets.only(bottom: size.height * 0.012),
                    child: InkWell(
                      onTap: () {
                        context.read<AddAssetBloc>().add(SelectPortfolio(portfolio: portfolio));
                        Navigator.pop(sheetContext);
                      },
                      borderRadius: BorderRadius.circular(size.width * 0.035),
                      child: Container(
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
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.white,
                                size: size.width * 0.055,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Alt padding
            SizedBox(height: size.height * 0.025),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Size size,
    bool isNumeric = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.035,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: size.height * 0.008),
        TextField(
          controller: controller,
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
              : null,
          decoration: InputDecoration(
            hintText: hint,
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
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context, AddAssetLoaded state, Size size) {
    final isValid = state.quantity > 0 &&
        state.purchasePrice > 0 &&
        state.assetName.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid ? () => context.read<AddAssetBloc>().add(SaveAsset()) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A0B52),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.035),
          ),
          elevation: 0,
        ),
        child: Text(
          'Portföye Ekle',
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}