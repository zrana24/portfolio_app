import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/livePrices/livePrices_bloc.dart';
import '../../bloc/livePrices/livePrices_event.dart';
import '../../bloc/livePrices/livePrices_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';
import '../../widgets/ads_banner_widget.dart';

class LivePricesPage extends StatefulWidget {
  const LivePricesPage({super.key});

  @override
  State<LivePricesPage> createState() => _LivePricesPageState();
}

class _LivePricesPageState extends State<LivePricesPage> {
  bool _showTopAd = false;
  bool _showBottomAd = false;

  void _onTopAdLoadStateChanged(bool isLoaded) {
    debugPrint('Üst Reklam yükleme durumu değişti: $isLoaded');
    if (mounted) {
      setState(() {
        _showTopAd = isLoaded;
      });
    }
  }

  void _onBottomAdLoadStateChanged(bool isLoaded) {
    debugPrint('Alt Reklam yükleme durumu değişti: $isLoaded');
    if (mounted) {
      setState(() {
        _showBottomAd = isLoaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LivePricesBloc()..add(const LoadLivePrices()),
      child: _LivePricesView(
        onTopAdLoadStateChanged: _onTopAdLoadStateChanged,
        onBottomAdLoadStateChanged: _onBottomAdLoadStateChanged,
      ),
    );
  }
}

class _LivePricesView extends StatelessWidget {
  final Function(bool) onTopAdLoadStateChanged;
  final Function(bool) onBottomAdLoadStateChanged;

  const _LivePricesView({
    required this.onTopAdLoadStateChanged,
    required this.onBottomAdLoadStateChanged,
  });

  static const Color _primary  = Color(0xFF1A0B52);
  static const Color _accent   = Color(0xFFE8A020);
  static const Color _negative = Color(0xFFE53935);
  static const Color _positive = Color(0xFF43A047);
  static const Color _cardBg   = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isTablet = size.width > 600;
    final isDesktop = size.width > 900;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 0),
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: const CebeciAppBar(),
            ),
            Expanded(
              child: BlocConsumer<LivePricesBloc, LivePricesState>(
                listener: (context, state) {},
                builder: (context, state) {
                  return RefreshIndicator(
                    color: _primary,
                    onRefresh: () async {
                      context
                          .read<LivePricesBloc>()
                          .add(const RefreshLivePrices());
                      await context
                          .read<LivePricesBloc>()
                          .stream
                          .firstWhere((s) =>
                      s is LivePricesLoaded || s is LivePricesError);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 80 : (isTablet ? 40 : size.width * 0.06)),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              SizedBox(height: size.height * 0.006),
                              _buildTopBar(context, state, size, isTablet, isDesktop),
                              SizedBox(height: size.height * 0.018),
                              _buildUpdateRow(state, size, isTablet, isDesktop),

                              SizedBox(height: size.height * 0.012),
                              AdsBannerWidget(
                                onAdLoadStateChanged: onTopAdLoadStateChanged,
                              ),
                              SizedBox(height: size.height * 0.012),

                              _buildBody(context, state, size, isTablet, isDesktop),
                              SizedBox(height: size.height * 0.018),

                              if (state is LivePricesLoaded ||
                                  state is LivePricesError)
                                _buildInfoCard(size, isTablet, isDesktop),

                              SizedBox(height: size.height * 0.012),
                              AdsBannerWidget(
                                onAdLoadStateChanged: onBottomAdLoadStateChanged,
                              ),

                              SizedBox(
                                height: size.height * 0.082 +
                                    size.height * 0.015 +
                                    bottomPadding +
                                    size.height * 0.02 + 30,
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LivePricesState state, Size size, bool isTablet, bool isDesktop) {
    if (state is LivePricesLoading) return _buildSkeletonLoading(size, isTablet, isDesktop);

    if (state is LivePricesError && !state.hasPreviousData) {
      return _buildErrorState(context, state.message, size, isTablet, isDesktop);
    }

    final loaded = state is LivePricesLoaded
        ? state
        : (state is LivePricesError ? state.previousState : null);

    if (loaded == null) return _buildSkeletonLoading(size, isTablet, isDesktop);

    final items = loaded.allItems;
    if (items.isEmpty) return _buildEmptyState(size, isTablet, isDesktop);

    return loaded.viewMode == ViewMode.list
        ? _buildListView(items, size, isTablet, isDesktop)
        : _buildTableView(items, size, isTablet, isDesktop);
  }

  Widget _buildTopBar(BuildContext context, LivePricesState state, Size size, bool isTablet, bool isDesktop) {
    bool isTable = true;

    if (state is LivePricesLoaded) {
      isTable = state.viewMode == ViewMode.table;
    }

    final fontSize = isDesktop ? 32.0 : (isTablet ? 28.0 : size.width * 0.07);
    final buttonPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : size.width * 0.04);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Canlı Fiyatlar',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Row(
          children: [
            SizedBox(width: size.width * 0.025),
            GestureDetector(
              onTap: () =>
                  context.read<LivePricesBloc>().add(const ToggleViewMode()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: buttonPadding,
                  vertical: buttonPadding * 0.55,
                ),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(isDesktop ? 12 : (isTablet ? 10 : size.width * 0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTable
                          ? Icons.format_list_bulleted_rounded
                          : Icons.table_rows_rounded,
                      size: isDesktop ? 20 : (isTablet ? 18 : size.width * 0.045),
                      color: Colors.black87,
                    ),
                    SizedBox(width: isDesktop ? 8 : (isTablet ? 6 : size.width * 0.015)),
                    Text(
                      isTable ? 'Liste' : 'Tablo',
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : (isTablet ? 14 : size.width * 0.035),
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUpdateRow(LivePricesState state, Size size, bool isTablet, bool isDesktop) {
    String timeStr = '--:--:--';

    if (state is LivePricesLoaded) {
      timeStr = _formatTime(state.lastUpdated);
    }

    final iconSize = isDesktop ? 18.0 : (isTablet ? 16.0 : size.width * 0.04);
    final fontSize = isDesktop ? 16.0 : (isTablet ? 15.0 : size.width * 0.038);

    return Row(
      children: [
        Icon(Icons.access_time_rounded,
            size: iconSize, color: Colors.black54),
        SizedBox(width: isDesktop ? 8 : (isTablet ? 6 : size.width * 0.015)),
        Text(
          'Son Güncelleme',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          timeStr,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: _accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<PriceItem> items, Size size, bool isTablet, bool isDesktop) {
    return Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.012),
          child: _listCard(e.value, size, isTablet, isDesktop),
        );
      }).toList(),
    );
  }

  Widget _listCard(PriceItem item, Size size, bool isTablet, bool isDesktop) {
    final changeColor = item.isPositive ? _positive : _negative;
    final abbr = item.code.length > 3 ? item.code.substring(0, 3) : item.code;

    final spreadPercent = item.buy > 0 ? ((item.sell - item.buy) / item.buy) * 100 : 0.0;

    final hasChangePct = item.changePct != 0;

    final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : size.width * 0.05);
    final verticalPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : size.height * 0.018);
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : size.width * 0.05);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        children: [
          Container(
            width: isDesktop ? 48 : (isTablet ? 44 : size.width * 0.11),
            height: isDesktop ? 48 : (isTablet ? 44 : size.width * 0.11),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                abbr,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : (isTablet ? 12 : size.width * 0.028),
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : size.width * 0.035)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : (isTablet ? 16 : size.width * 0.042),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: size.height * 0.003),
                Text(
                  item.code,
                  style: TextStyle(
                    fontSize: isDesktop ? 13 : (isTablet ? 12 : size.width * 0.03),
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _priceColumn(
                'Alış',
                '₺${_formatNumber(item.buy)}',
                _positive,
                size,
                isTablet,
                isDesktop,
              ),
              SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : size.width * 0.03)),

              _priceColumn(
                'Satış',
                '₺${_formatNumber(item.sell)}',
                _negative,
                size,
                isTablet,
                isDesktop,
              ),
              SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : size.width * 0.03)),

              _priceColumn(
                'Fark',
                '%${spreadPercent.toStringAsFixed(2).replaceAll('.', ',')}',
                _accent,
                size,
                isTablet,
                isDesktop,
              ),

              if (hasChangePct) ...[
                SizedBox(width: isDesktop ? 16 : (isTablet ? 14 : size.width * 0.03)),
                _priceColumn(
                  'Değişim',
                  '%${item.changePct.toStringAsFixed(2).replaceAll('.', ',')}',
                  changeColor,
                  size,
                  isTablet,
                  isDesktop,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceColumn(String label, String value, Color color, Size size, bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 11 : (isTablet ? 10 : size.width * 0.024),
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        SizedBox(height: size.height * 0.002),
        Text(
          value,
          style: TextStyle(
            fontSize: isDesktop ? 15 : (isTablet ? 14 : size.width * 0.034),
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildTableView(List<PriceItem> items, Size size, bool isTablet, bool isDesktop) {
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : size.width * 0.05);

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          _tableHeader(size, isTablet, isDesktop),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                _tableRow(entry.value, size, isTablet, isDesktop),
                if (!isLast)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Color(0xFFE5E7EB),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeader(Size size, bool isTablet, bool isDesktop) {
    final fontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : size.width * 0.032);
    final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : size.width * 0.05);
    final verticalPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : size.height * 0.016);

    final style = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: Colors.grey);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Birim', style: style)),
          Expanded(flex: 3, child: Text('Alış', style: style, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Satış', style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Fark', style: style, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _tableRow(PriceItem item, Size size, bool isTablet, bool isDesktop) {
    final changeColor = item.isPositive ? _positive : _negative;

    final spreadPercent = item.buy > 0 ? ((item.sell - item.buy) / item.buy) * 100 : 0.0;

    final fontSize = isDesktop ? 14.0 : (isTablet ? 13.0 : size.width * 0.032);
    final horizontalPadding = isDesktop ? 24.0 : (isTablet ? 20.0 : size.width * 0.05);
    final verticalPadding = isDesktop ? 16.0 : (isTablet ? 14.0 : size.height * 0.016);

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  item.code,
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '₺${_formatNumber(item.buy)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: _positive,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '₺${_formatNumber(item.sell)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: _negative,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '%${spreadPercent.toStringAsFixed(2).replaceAll('.', ',')}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: _accent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoading(Size size, bool isTablet, bool isDesktop) {
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : size.width * 0.05);
    final height = isDesktop ? 80.0 : (isTablet ? 75.0 : size.height * 0.09);

    return Column(
      children: List.generate(
        5,
            (i) => Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.012),
          child: _ShimmerBox(
            width: double.infinity,
            height: height,
            borderRadius: borderRadius,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, Size size, bool isTablet, bool isDesktop) {
    final iconSize = isDesktop ? 60.0 : (isTablet ? 55.0 : size.width * 0.15);
    final fontSize = isDesktop ? 18.0 : (isTablet ? 16.0 : size.width * 0.04);
    final borderRadius = isDesktop ? 12.0 : (isTablet ? 10.0 : size.width * 0.06);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: iconSize, color: Colors.grey.shade300),
            SizedBox(height: size.height * 0.02),
            Text('Veriler yüklenemedi',
                style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54)),
            SizedBox(height: size.height * 0.025),
            ElevatedButton(
              onPressed: () =>
                  context.read<LivePricesBloc>().add(const LoadLivePrices()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius)),
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32 : (isTablet ? 28 : size.width * 0.08),
                    vertical: isDesktop ? 14 : (isTablet ? 12 : size.height * 0.018)),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size, bool isTablet, bool isDesktop) {
    final circleSize = isDesktop ? 100.0 : (isTablet ? 90.0 : size.width * 0.24);
    final iconSize = isDesktop ? 50.0 : (isTablet ? 45.0 : size.width * 0.12);
    final titleSize = isDesktop ? 22.0 : (isTablet ? 20.0 : size.width * 0.05);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.06,
          horizontal: isDesktop ? 100 : (isTablet ? 80 : size.width * 0.08),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: iconSize,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: size.height * 0.025),

            Text(
              'Henüz Canlı Fiyat Verisi Yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: size.height * 0.012),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Size size, bool isTablet, bool isDesktop) {
    final padding = isDesktop ? 24.0 : (isTablet ? 20.0 : size.width * 0.05);
    final borderRadius = isDesktop ? 16.0 : (isTablet ? 14.0 : size.width * 0.05);
    final circleSize = isDesktop ? 32.0 : (isTablet ? 30.0 : size.width * 0.07);
    final iconSize = isDesktop ? 18.0 : (isTablet ? 16.0 : size.width * 0.04);
    final titleSize = isDesktop ? 18.0 : (isTablet ? 16.0 : size.width * 0.04);
    final textSize = isDesktop ? 14.0 : (isTablet ? 13.0 : size.width * 0.03);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                    color: _accent, shape: BoxShape.circle),
                child: Icon(Icons.info_outline_rounded,
                    size: iconSize, color: Colors.white),
              ),
              SizedBox(width: isDesktop ? 12 : (isTablet ? 10 : size.width * 0.03)),
              Text('Veri Kaynağı',
                  style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A))),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            'Bu sayfada görüntülenen fiyat verileri Meta Data kaynaklarından üretilerek yayınlanmaktadır ve sadece bilgilendirme amaçlıdır. Veriler izin alınmadan paylaşılamaz.',
            style: TextStyle(
                fontSize: textSize, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
          '${t.minute.toString().padLeft(2, '0')}:'
          '${t.second.toString().padLeft(2, '0')}';

  String _formatNumber(double value) => value
      .toInt()
      .toString()
      .replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
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
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );
  }
}