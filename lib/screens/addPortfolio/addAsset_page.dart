import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../bloc/addAsset/addAsset_bloc.dart';
import '../../bloc/addAsset/addAsset_event.dart';
import '../../bloc/addAsset/addAsset_state.dart';
import '../../widgets/back_button.dart';
import '../../widgets/ads_banner_widget.dart';
import '../../services/portfolio_services.dart';
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

  String _selectedPeriod = '1w';
  PriceHistory? _currentPriceHistory;
  bool _isLoadingChart = false;

  @override
  void dispose() {
    _assetNameController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    super.dispose();
  }

  Future<void> _changePeriod(String newPeriod) async {
    if (_selectedPeriod == newPeriod || _isLoadingChart) return;

    setState(() {
      _selectedPeriod = newPeriod;
      _isLoadingChart = true;
    });

    try {
      final portfolioService = PortfolioService();
      final newPriceHistory = await portfolioService.getPriceHistory(
        symbol: widget.symbol,
        period: newPeriod,
      );

      setState(() {
        _currentPriceHistory = newPriceHistory;
      });

      portfolioService.dispose();
    } catch (e) {
      print('Period değiştirme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingChart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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

            if (_currentPriceHistory == null) {
              _currentPriceHistory = state.priceHistory;
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
            bottom: false,
            child: BlocBuilder<AddAssetBloc, AddAssetState>(
              builder: (context, state) {
                if (state is AddAssetLoading) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF1A0B52)));
                } else if (state is AddAssetLoaded) {
                  return _buildContent(context, state, size, bottomPadding);
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

  Widget _buildContent(BuildContext context, AddAssetLoaded state, Size size, double bottomPadding) {
    return Column(
      children: [
        _buildAppBar(context, state.name, size),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(size.width * 0.05),
            child: Column(
              children: [
                const AdsBannerWidget(),
                SizedBox(height: size.height * 0.02),
                _buildPriceSection(state, size),
                SizedBox(height: size.height * 0.02),
                _buildInputSection(context, state, size),
                SizedBox(height: size.height * 0.02),
                _buildSaveButton(context, state, size),
                SizedBox(height: size.height * 0.02),
                const AdsBannerWidget(),
                SizedBox(height: bottomPadding + size.height * 0.02),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection(AddAssetLoaded state, Size size) {
    final isPositive = state.dailyChange >= 0;
    final displayHistory = _currentPriceHistory ?? state.priceHistory;

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  SizedBox(height: size.height * 0.008),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.025,
                      vertical: size.height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(size.width * 0.015),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: size.width * 0.03,
                          color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                        SizedBox(width: size.width * 0.008),
                        Text(
                          '${isPositive ? '+' : ''}${state.dailyChange.toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.w600,
                            color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildPeriodDropdown(size),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          SizedBox(
            height: size.height * 0.25,
            child: _isLoadingChart
                ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1A0B52),
                strokeWidth: 2,
              ),
            )
                : _buildLineChart(displayHistory, size, isPositive),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown(Size size) {
    final periodLabels = {
      '1d': 'Son 1 Gün',
      '1w': 'Son 7 Gün',
      '1m': 'Son 1 Ay',
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.025,
        vertical: size.height * 0.003,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(size.width * 0.02),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPeriod,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: size.width * 0.04,
            color: const Color(0xFF6B7280),
          ),
          elevation: 4,
          style: TextStyle(
            fontSize: size.width * 0.032,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1A1A),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(size.width * 0.03),
          isDense: true,
          onChanged: (String? newValue) {
            if (newValue != null) {
              _changePeriod(newValue);
            }
          },
          items: [
            {'value': '1d', 'label': 'Son 1 Gün'},
            {'value': '1w', 'label': 'Son 7 Gün'},
            {'value': '1m', 'label': 'Son 1 Ay'},
          ].map<DropdownMenuItem<String>>((period) {
            return DropdownMenuItem<String>(
              value: period['value'],
              child: Text(
                period['label']!,
                style: TextStyle(
                  fontSize: size.width * 0.032,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLineChart(PriceHistory priceHistory, Size size, bool isPositive) {
    if (priceHistory.chart.data.isEmpty) {
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
    for (int i = 0; i < priceHistory.chart.data.length; i++) {
      spots.add(FlSpot(i.toDouble(), priceHistory.chart.data[i]));
    }

    final minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final rangeY = maxY - minY;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: rangeY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFE5E7EB),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minY: minY - (rangeY * 0.05),
        maxY: maxY + (rangeY * 0.05),
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
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isPositive ? Colors.green.shade600 : Colors.red.shade600).withOpacity(0.2),
                  (isPositive ? Colors.green.shade600 : Colors.red.shade600).withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => const Color(0xFF1A1A1A).withOpacity(0.9),
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                String timeLabel = '';

                if (index < priceHistory.points.length) {
                  try {
                    final pointTime = DateTime.parse(priceHistory.points[index].time);

                    if (_selectedPeriod == '1d') {
                      timeLabel = '${pointTime.hour.toString().padLeft(2, '0')}:${pointTime.minute.toString().padLeft(2, '0')}';
                    } else if (_selectedPeriod == '1w') {
                      timeLabel = '${pointTime.day}/${pointTime.month} ${pointTime.hour.toString().padLeft(2, '0')}:${pointTime.minute.toString().padLeft(2, '0')}';
                    } else if (_selectedPeriod == '1m' || _selectedPeriod == '3m') {
                      timeLabel = '${pointTime.day}/${pointTime.month}/${pointTime.year}';
                    }
                  } catch (e) {
                    timeLabel = '';
                  }
                }

                return LineTooltipItem(
                  '₺${touchedSpot.y.toStringAsFixed(2)}\n$timeLabel',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: size.width * 0.032,
                  ),
                );
              }).toList();
            },
          ),
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                  strokeWidth: 2,
                  dashArray: [5, 5],
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: Colors.white,
                      strokeWidth: 3,
                      strokeColor: isPositive ? Colors.green.shade600 : Colors.red.shade600,
                    );
                  },
                ),
              );
            }).toList();
          },
        ),
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
            Container(
              margin: EdgeInsets.only(top: size.height * 0.015),
              width: size.width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
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