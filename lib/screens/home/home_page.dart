import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 2),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<HomeBloc, HomeState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: CebeciAppBar()),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        SizedBox(height: size.height * 0.012),
                        _buildHeader(size),
                        SizedBox(height: size.height * 0.035),

                        if (state is HomeLoading)
                          _buildSkeletonLoading(size)
                        else if (state is HomeLoaded)
                          _buildMainContent(state, size)
                        else if (state is HomeEmpty)
                            _buildEmptyState(size)
                          else if (state is HomeError)
                              _buildErrorState(state.message, context, size),


                        SizedBox(
                          height: size.height * 0.082 +
                              size.height * 0.015 +
                              bottomPadding +
                              size.height * 0.02,
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Portföyüm",
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonLoading(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _ShimmerBox(
            width: size.width * 0.55,
            height: size.width * 0.55,
            borderRadius: size.width * 0.275,
          ),
        ),
        SizedBox(height: size.height * 0.05),

        _ShimmerBox(width: size.width * 0.4, height: size.height * 0.02),
        SizedBox(height: size.height * 0.015),

        _ShimmerBox(width: size.width * 0.55, height: size.height * 0.045),
        SizedBox(height: size.height * 0.015),

        Row(
          children: [
            _ShimmerBox(
              width: size.width * 0.38,
              height: size.height * 0.04,
              borderRadius: size.width * 0.05,
            ),
            SizedBox(width: size.width * 0.02),
            _ShimmerBox(
              width: size.width * 0.22,
              height: size.height * 0.04,
              borderRadius: size.width * 0.05,
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),

        _ShimmerBox(width: size.width * 0.2, height: size.height * 0.02),
        SizedBox(height: size.height * 0.02),

        ...List.generate(
          3,
              (i) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: _ShimmerBox(
              width: double.infinity,
              height: size.height * 0.1,
              borderRadius: size.width * 0.06,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent(HomeLoaded state, Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.categoryDistribution.isNotEmpty) ...[
          _buildDonutChartSection(state, size),
          SizedBox(height: size.height * 0.05),
        ],

        _buildSectionTitle("Portföyler Toplamı", size, hasArrows: true),
        Text(
          "${state.totalValue.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₺",
          style: TextStyle(
            fontSize: size.width * 0.09,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: size.height * 0.015),

        Wrap(
          spacing: size.width * 0.02,
          runSpacing: size.height * 0.01,
          children: [
            _badge(
              size: size,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Günlük Değişim ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                  Text(
                    "${state.dailyChange >= 0 ? '+' : ''}${state.dailyChange.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: state.dailyChange >= 0
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                ],
              ),
            ),
            _badge(
              size: size,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${state.dailyChangePct >= 0 ? '+' : ''}%${state.dailyChangePct.toStringAsFixed(1).replaceAll('.', ',')}  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                  Icon(
                    state.dailyChangePct >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    size: size.width * 0.04,
                    color: state.dailyChangePct >= 0
                        ? Colors.green.shade400
                        : Colors.red.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),
        if (state.portfolios.isNotEmpty) ...[
          _buildSectionTitle("İçerik", size, hasSort: true),
          SizedBox(height: size.height * 0.02),

          ...state.portfolios.map((p) => Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: _contentCard(
              p.name,
              p.value.toStringAsFixed(0),
              "${p.dailyChange >= 0 ? '+' : ''}${p.dailyChange.toStringAsFixed(0)}",
              "${p.dailyChangePct >= 0 ? '+' : ''}%${p.dailyChangePct.toStringAsFixed(1).replaceAll('.', ',')}",
              p.dailyChangePct,
              size,
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildDonutChartSection(HomeLoaded state, Size size) {
    final chartSize = size.width * 0.55;

    if (state.categoryDistribution.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(
              painter: DonutChartPainter(
                categories: state.categoryDistribution,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: state.categoryDistribution.map((cat) {
              return Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.01),
                child: _legendItem(
                  _getCategoryColor(cat.category),
                  cat.label,
                  "%${cat.percentage.toStringAsFixed(1).replaceAll('.', ',')}",
                  size,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'doviz':
        return const Color(0xFFFFD700);
      case 'emtia':
        return const Color(0xFF00C4B4);
      case 'hisse':
        return const Color(0xFF6366F1);
      case 'kripto':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  Widget _legendItem(Color color, String label, String value, Size size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size.width * 0.02,
          height: size.width * 0.02,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: size.width * 0.02),
        Text(
          label,
          style: TextStyle(
            fontSize: size.width * 0.03,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: size.width * 0.01),
        Text(
          value,
          style: TextStyle(
            fontSize: size.width * 0.03,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(
      String title,
      Size size, {
        bool hasArrows = false,
        bool hasSort = false,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF35238A),
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.05,
            ),
          ),
          if (hasArrows)
            Row(
              children: [
                Icon(Icons.chevron_left,
                    color: Colors.grey.shade300, size: size.width * 0.06),
                Icon(Icons.chevron_right,
                    color: Colors.black87, size: size.width * 0.06),
              ],
            ),
          if (hasSort) _circularIcon(Icons.swap_vert, size),
        ],
      ),
    );
  }

  Widget _contentCard(
      String title,
      String value,
      String diff,
      String perc,
      double percValue,
      Size size,
      ) {
    final isPositive = percValue >= 0;

    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.06),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  fontSize: size.width * 0.035,
                ),
              ),
              Row(
                children: [
                  Text(
                    "$value ₺",
                    style: TextStyle(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Icon(
                    isPositive
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: size.width * 0.05,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                diff,
                style: TextStyle(
                  color: isPositive
                      ? Colors.green.shade400
                      : Colors.red.shade400,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * 0.035,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Text(
                perc,
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * 0.035,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Size size) {
    final chartSize = size.width * 0.65;
    return Column(
      children: [
        SizedBox(height: size.height * 0.05),
        Center(
          child: SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(painter: EmptyDonutPainter()),
          ),
        ),
        SizedBox(height: size.height * 0.05),
      ],
    );
  }

  Widget _buildErrorState(String message, BuildContext context, Size size) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.1),
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
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.035,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(height: size.height * 0.04),
        ElevatedButton.icon(
          onPressed: () {
            context.read<HomeBloc>().add(LoadHomeData());
          },
          icon: const Icon(Icons.refresh),
          label: const Text("Tekrar Dene"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1060),
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
    );
  }

  Widget _badge({required Widget child, required Size size}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(size.width * 0.05),
      ),
      child: child,
    );
  }

  Widget _circularIcon(IconData icon, Size size) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.025),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size.width * 0.045, color: Colors.black87),
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

class EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.15;

    final paint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, size.width / 2 - strokeWidth / 2, paint);

    const textStyle = TextStyle(
      color: Color(0xFF9CA3AF),
      fontSize: 14,
    );
    const span = TextSpan(
      text: "Şu anda gösterilecek\nbir şey yok.",
      style: textStyle,
    );
    final tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: size.width * 0.55);
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryDistribution> categories;

  DonutChartPainter({required this.categories});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.15;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    double startAngle = -math.pi / 2;

    for (var category in categories) {
      final paint = Paint()
        ..color = _getCategoryColor(category.category)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * (category.percentage / 100);

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - 0.02,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'doviz':
        return const Color(0xFFFFD700);
      case 'emtia':
        return const Color(0xFF00C4B4);
      case 'hisse':
        return const Color(0xFF6366F1);
      case 'kripto':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}