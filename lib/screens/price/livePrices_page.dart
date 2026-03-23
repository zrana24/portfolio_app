import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/livePrices/livePrices_bloc.dart';
import '../../bloc/livePrices/livePrices_event.dart';
import '../../bloc/livePrices/livePrices_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';

class LivePricesPage extends StatelessWidget {
  const LivePricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LivePricesBloc()..add(const LoadLivePrices()),
      child: const _LivePricesView(),
    );
  }
}

class _LivePricesView extends StatelessWidget {
  const _LivePricesView();

  static const Color _primary  = Color(0xFF1A0B52);
  static const Color _accent   = Color(0xFFE8A020);
  static const Color _negative = Color(0xFFE53935);
  static const Color _positive = Color(0xFF43A047);
  static const Color _cardBg   = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom; // Safe area bottom padding

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 0),
        body: SafeArea(
          bottom: false, // Bottom safe area'yı devre dışı bırak
          child: Column(
            children: [
              const CebeciAppBar(),
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
                                horizontal: size.width * 0.06),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                SizedBox(height: size.height * 0.012),
                                _buildTopBar(context, state, size),
                                SizedBox(height: size.height * 0.018),
                                _buildUpdateRow(state, size),
                                SizedBox(height: size.height * 0.022),
                                _buildBody(context, state, size),
                                SizedBox(height: size.height * 0.025),
                                if (state is LivePricesLoaded ||
                                    state is LivePricesError)
                                  _buildInfoCard(size),
                                // Bottom navigation için boşluk bırak
                                SizedBox(
                                  height: size.height * 0.082 + // Bottom nav yüksekliği
                                      size.height * 0.015 + // Bottom padding
                                      bottomPadding + // Safe area
                                      size.height * 0.02, // Ekstra boşluk
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
      ),
    );
  }

  Widget _buildBody(BuildContext context, LivePricesState state, Size size) {
    if (state is LivePricesLoading) return _buildSkeletonLoading(size);

    if (state is LivePricesError && !state.hasPreviousData) {
      return _buildErrorState(context, state.message, size);
    }

    final loaded = state is LivePricesLoaded
        ? state
        : (state is LivePricesError ? state.previousState : null);

    if (loaded == null) return _buildSkeletonLoading(size);

    final items = loaded.allItems;
    if (items.isEmpty) return _buildEmptyState(size);

    return loaded.viewMode == ViewMode.list
        ? _buildListView(items, size)
        : _buildTableView(items, size);
  }

  Widget _buildTopBar(BuildContext context, LivePricesState state, Size size) {
    final isTable =
        state is LivePricesLoaded && state.viewMode == ViewMode.table;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Canlı Fiyatlar',
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Row(
          children: [
            _circularIcon(Icons.currency_lira, size),
            SizedBox(width: size.width * 0.025),
            GestureDetector(
              onTap: () =>
                  context.read<LivePricesBloc>().add(const ToggleViewMode()),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.width * 0.022,
                ),
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(size.width * 0.06),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isTable
                          ? Icons.format_list_bulleted_rounded
                          : Icons.table_rows_rounded,
                      size: size.width * 0.045,
                      color: Colors.black87,
                    ),
                    SizedBox(width: size.width * 0.015),
                    Text(
                      isTable ? 'Liste' : 'Tablo',
                      style: TextStyle(
                        fontSize: size.width * 0.035,
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

  Widget _buildUpdateRow(LivePricesState state, Size size) {
    String timeStr = '--:--:--';
    bool isRefreshing = false;

    if (state is LivePricesLoaded) {
      timeStr = _formatTime(state.lastUpdated);
      isRefreshing = state is LivePricesRefreshing;
    }

    return Row(
      children: [
        isRefreshing
            ? SizedBox(
          width: size.width * 0.04,
          height: size.width * 0.04,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: _accent),
        )
            : Icon(Icons.access_time_rounded,
            size: size.width * 0.04, color: Colors.black54),
        SizedBox(width: size.width * 0.015),
        Text(
          'Son Güncelleme',
          style: TextStyle(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          timeStr,
          style: TextStyle(
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w700,
            color: _accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<PriceItem> items, Size size) {
    return Column(
      children: items.asMap().entries.map((e) {
        final isLast = e.key == items.length - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.012),
          child: _listCard(e.value, size),
        );
      }).toList(),
    );
  }

  Widget _listCard(PriceItem item, Size size) {
    final changeColor = item.isPositive ? _positive : _negative;
    final abbr = item.code.length > 3 ? item.code.substring(0, 3) : item.code;

    final spreadPercent = item.buy > 0 ? ((item.sell - item.buy) / item.buy) * 100 : 0.0;

    final hasChangePct = item.changePct != 0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.11,
            height: size.width * 0.11,
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                abbr,
                style: TextStyle(
                  fontSize: size.width * 0.028,
                  fontWeight: FontWeight.w800,
                  color: _primary,
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.code,
                  style: TextStyle(
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: size.height * 0.003),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'A',
                    style: TextStyle(
                      fontSize: size.width * 0.024,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.002),
                  Text(
                    _formatNumber(item.buy),
                    style: TextStyle(
                      fontSize: size.width * 0.034,
                      fontWeight: FontWeight.w700,
                      color: _positive,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              SizedBox(width: size.width * 0.03),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'S',
                    style: TextStyle(
                      fontSize: size.width * 0.024,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.002),
                  Text(
                    _formatNumber(item.sell),
                    style: TextStyle(
                      fontSize: size.width * 0.034,
                      fontWeight: FontWeight.w700,
                      color: _negative,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              SizedBox(width: size.width * 0.03),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'F',
                    style: TextStyle(
                      fontSize: size.width * 0.024,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: size.height * 0.002),
                  Text(
                    '${spreadPercent.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: TextStyle(
                      fontSize: size.width * 0.031,
                      fontWeight: FontWeight.w700,
                      color: _accent,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),

              if (hasChangePct) ...[
                SizedBox(width: size.width * 0.03),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '%',
                      style: TextStyle(
                        fontSize: size.width * 0.024,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.002),
                    Text(
                      item.changePct.toStringAsFixed(2).replaceAll('.', ','),
                      style: TextStyle(
                        fontSize: size.width * 0.031,
                        fontWeight: FontWeight.w700,
                        color: changeColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceBox({
    required String label,
    required String value,
    required Color color,
    required Size size,
  }) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(size.width * 0.025),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.026,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: size.height * 0.004),
          Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView(List<PriceItem> items, Size size) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Column(
        children: [
          _tableHeader(size),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          ...items.asMap().entries.map((entry) {
            final isLast = entry.key == items.length - 1;
            return Column(
              children: [
                _tableRow(entry.value, size),
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

  Widget _tableHeader(Size size) {
    final style = TextStyle(
        fontSize: size.width * 0.032,
        fontWeight: FontWeight.w700,
        color: Colors.grey);
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.016),
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

  Widget _tableRow(PriceItem item, Size size) {
    final changeColor = item.isPositive ? _positive : _negative;

    final spreadPercent = item.buy > 0 ? ((item.sell - item.buy) / item.buy) * 100 : 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05, vertical: size.height * 0.016),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item.code,
              style: TextStyle(
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatNumber(item.buy),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w600,
                color: _positive,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatNumber(item.sell),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.032,
                fontWeight: FontWeight.w600,
                color: _negative,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              spreadPercent.toStringAsFixed(2).replaceAll('.', ','),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: size.width * 0.032,
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

  Widget _buildSkeletonLoading(Size size) {
    return Column(
      children: List.generate(
        5,
            (i) => Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.012),
          child: _ShimmerBox(
            width: double.infinity,
            height: size.height * 0.09,
            borderRadius: size.width * 0.05,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: size.width * 0.15, color: Colors.grey.shade300),
            SizedBox(height: size.height * 0.02),
            Text('Veriler yüklenemedi',
                style: TextStyle(
                    fontSize: size.width * 0.04,
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
                    borderRadius: BorderRadius.circular(size.width * 0.06)),
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.018),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.06,
          horizontal: size.width * 0.08,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size.width * 0.24,
              height: size.width * 0.24,
              decoration: BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: size.width * 0.12,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: size.height * 0.025),

            Text(
              'Henüz Canlı Fiyat Verisi Yok',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.05,
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

  Widget _buildInfoCard(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EE),
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.07,
                height: size.width * 0.07,
                decoration: const BoxDecoration(
                    color: _accent, shape: BoxShape.circle),
                child: Icon(Icons.info_outline_rounded,
                    size: size.width * 0.04, color: Colors.white),
              ),
              SizedBox(width: size.width * 0.03),
              Text('Veri Kaynağı',
                  style: TextStyle(
                      fontSize: size.width * 0.04,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A))),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            'Bu sayfada görüntülenen fiyat verileri Meta Data kaynaklarından üretilerek yayınlanmaktadır ve sadece bilgilendirme amaçlıdır. Veriler izin alınmadan paylaşılamaz.',
            style: TextStyle(
                fontSize: size.width * 0.03, color: Colors.black54, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _circularIcon(IconData icon, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration:
      BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
      child: Icon(icon, size: size.width * 0.045, color: Colors.black87),
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