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
  // TextEditingController'ları burada tanımla
  final TextEditingController _assetNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _purchasePriceController = TextEditingController();

  @override
  void dispose() {
    // Controller'ları dispose et
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
          print('📱 AddAsset State Değişti: ${state.runtimeType}');

          // State değiştiğinde controller'ları güncelle
          // State değiştiğinde controller'ları sadece değer farklıysa güncelle
          if (state is AddAssetLoaded) {
            if (_assetNameController.text != state.assetName) {
              _assetNameController.text = state.assetName;
            }
            
            // Miktar kontrolü: Sayısal değer aynıysa metni değiştirme (örn: 30 ve 30.0 aynıdır)
            final currentQuantity = double.tryParse(_quantityController.text) ?? 0;
            if (currentQuantity != state.quantity) {
              _quantityController.text = state.quantity == 0 ? '' : state.quantity.toString();
            }

            // Fiyat kontrolü: Sayısal değer aynıysa metni değiştirme
            final currentPrice = double.tryParse(_purchasePriceController.text) ?? 0;
            if (currentPrice != state.purchasePrice) {
              _purchasePriceController.text = state.purchasePrice == 0 ? '' : state.purchasePrice.toString();
            }
          }

          if (state is AddAssetSuccess) {
            print('✅ Success state - Ekran kapatılıyor');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Varlık başarıyla eklendi'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.add,
                  (route) => false,
            );
          } else if (state is AddAssetError) {
            print('❌ Error state: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is AddAssetSaving) {
            print('⏳ Saving state - Loading gösteriliyor');
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: BlocBuilder<AddAssetBloc, AddAssetState>(
              builder: (context, state) {
                if (state is AddAssetLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AddAssetLoaded) {
                  return _buildContent(context, state, size);
                } else if (state is AddAssetSaving) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Kaydediliyor...'),
                      ],
                    ),
                  );
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
        // App Bar
        Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Row(
            children: [
              const BackButtonWidget(),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Text(
                  '${widget.name ?? widget.symbol} Ekle',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: size.width * 0.08),
            ],
          ),
        ),

        // Error Content
        Expanded(
          child: Center(
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
                    'Bir hata oluştu',
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
                      context.read<AddAssetBloc>().add(LoadAssetData());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
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
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, AddAssetLoaded state, Size size) {
    return Column(
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
                  '${state.name} Ekle',
                  style: TextStyle(
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: size.width * 0.08),
            ],
          ),
        ),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGraphSection(state, size),
                SizedBox(height: size.height * 0.025),
                _buildPriceInfo(state, size),
                SizedBox(height: size.height * 0.025),
                _buildInputSection(context, state, size),
                SizedBox(height: size.height * 0.03),
                _buildSaveButton(context, state, size),
                SizedBox(height: size.height * 0.03),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraphSection(AddAssetLoaded state, Size size) {
    final isPositive = state.dailyChange >= 0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size.width * 0.04),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Anlık',
                style: TextStyle(
                  fontSize: size.width * 0.035,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.03,
                  vertical: size.height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(size.width * 0.04),
                ),
                child: Row(
                  children: [
                    Text(
                      'Tarih: Son 7 Gün',
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(width: size.width * 0.01),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: size.width * 0.04,
                      color: Colors.black87,
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
      return const Center(child: Text('Grafik verisi yok'));
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < state.priceHistory.chart.data.length; i++) {
      spots.add(FlSpot(i.toDouble(), state.priceHistory.chart.data[i]));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 0.998,
        maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.002,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                if (index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
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
                  (isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935)).withOpacity(0.2),
                  (isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935)).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(AddAssetLoaded state, Size size) {
    final isPositive = state.dailyChange >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.currentPrice.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
          ),
          style: TextStyle(
            fontSize: size.width * 0.08,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: size.height * 0.01),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.025,
                vertical: size.height * 0.005,
              ),
              decoration: BoxDecoration(
                color: isPositive
                    ? const Color(0xFF4CAF50).withOpacity(0.1)
                    : const Color(0xFFE53935).withOpacity(0.1),
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: Text(
                '${isPositive ? '+' : ''}${state.dailyChange.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
                ),
              ),
            ),
            SizedBox(width: size.width * 0.02),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.025,
                vertical: size.height * 0.005,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(size.width * 0.02),
              ),
              child: Text(
                '%${state.dailyChange.toStringAsFixed(1)}',
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const Spacer(),
            Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
              size: size.width * 0.05,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context, AddAssetLoaded state, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Varlık Bilgileri',
          style: TextStyle(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        SizedBox(height: size.height * 0.015),

        // Portfolio Selector
        _buildPortfolioSelector(context, state, size),
        SizedBox(height: size.height * 0.015),

        // Varlık İsmi Input - Controller kullan
        _buildLabeledInput(
          context,
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

        // Miktar Input - Controller kullan
        _buildLabeledInput(
          context,
          label: 'Miktar',
          hint: '0.0',
          controller: _quantityController,
          onChanged: (value) {
            final quantity = double.tryParse(value) ?? 0.0;
            context.read<AddAssetBloc>().add(UpdateQuantity(quantity: quantity));
          },
          size: size,
          isNumeric: true,
        ),
        SizedBox(height: size.height * 0.015),

        // Birim Fiyat Input - Controller kullan
        _buildLabeledInput(
          context,
          label: 'Birim Fiyat (Opsiyonel)',
          hint: '0.0',
          controller: _purchasePriceController,
          onChanged: (value) {
            final price = double.tryParse(value) ?? 0.0;
            context.read<AddAssetBloc>().add(UpdatePurchasePrice(price: price));
          },
          size: size,
          isNumeric: true,
        ),
        SizedBox(height: size.height * 0.015),

      ],
    );
  }

  Widget _buildPortfolioSelector(BuildContext context, AddAssetLoaded state, Size size) {
    return GestureDetector(
      onTap: () => _showPortfolioSheet(context, state, size),
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
            Text(
              state.selectedPortfolio.name,
              style: TextStyle(
                fontSize: size.width * 0.038,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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

  void _showPortfolioSheet(BuildContext context, AddAssetLoaded state, Size size) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(size.width * 0.05),
        ),
      ),
      builder: (sheetContext) => Container(
        padding: EdgeInsets.all(size.width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Portföy Seç',
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            ...state.portfolios.map((portfolio) {
              final isSelected = portfolio.id == state.selectedPortfolio.id;
              return ListTile(
                title: Text(portfolio.name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: Color(0xFF1A0B52))
                    : null,
                onTap: () {
                  context.read<AddAssetBloc>().add(SelectPortfolio(portfolio: portfolio));
                  Navigator.pop(sheetContext);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledInput(
      BuildContext context, {
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
            color: Colors.grey.shade600,
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
            fillColor: Colors.white,
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
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Size size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.width * 0.1,
        height: size.width * 0.1,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: size.width * 0.05,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, AddAssetLoaded state, Size size) {
    final isValid = state.quantity > 0 &&
        state.purchasePrice > 0 &&
        state.assetName.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isValid
            ? () => context.read<AddAssetBloc>().add(SaveAsset())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A0B52),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(size.width * 0.03),
          ),
          elevation: 0,
        ),
        child: Text(
          'Portföye Ekle',
          style: TextStyle(
            fontSize: size.width * 0.04,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}