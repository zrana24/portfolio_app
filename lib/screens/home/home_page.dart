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

    return BlocProvider(
      create: (context) => HomeBloc()..add(LoadHomeData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 0),
        body: SafeArea(
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
                        SizedBox(height: size.height * 0.025),
                        _buildHeader(size),
                        SizedBox(height: size.height * 0.035),

                        if (state is HomeLoading)
                          _buildSkeletonLoading(size)
                        else if (state is HomeLoaded)
                          _buildMainContent(state, size)
                        else if (state is HomeEmpty)
                            _buildEmptyState(size),

                        SizedBox(height: size.height * 0.05),
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
          "Portfoyum",
          style: TextStyle(
            fontSize: size.width * 0.07,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        Row(
          children: [
            _circularIcon(Icons.currency_lira, size),
            SizedBox(width: size.width * 0.02),
            _circularIcon(Icons.swap_vert, size),
            SizedBox(width: size.width * 0.02),
            _circularIcon(Icons.visibility_outlined, size),
          ],
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
        _buildDonutChartSection(size),
        SizedBox(height: size.height * 0.05),

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
                    "${state.dailyChange}",
                    style: TextStyle(
                      color: Colors.red.shade400,
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
                    "%${state.dailyChangePct.toStringAsFixed(1).replaceAll('.', ',')}  ",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: size.width * 0.03,
                    ),
                  ),
                  Icon(
                    Icons.trending_down,
                    size: size.width * 0.04,
                    color: Colors.red.shade400,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.04),

        _buildSectionTitle("İçerik", size, hasSort: true),
        SizedBox(height: size.height * 0.02),

        ...state.portfolios.map((p) => Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.015),
          child: _contentCard(
            p.name,
            p.value.toStringAsFixed(0),
            "${p.dailyChange}",
            "%${p.dailyChangePct.toStringAsFixed(1).replaceAll('.', ',')}",
            size,
          ),
        )),
      ],
    );
  }

  Widget _buildDonutChartSection(Size size) {
    final chartSize = size.width * 0.55;
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: chartSize,
            height: chartSize,
            child: CustomPaint(painter: DonutChartPainter()),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _legendItem(const Color(0xFFFFD700), "Döviz", "%15,1", size),
              SizedBox(height: size.height * 0.01),
              _legendItem(const Color(0xFF00C4B4), "Emtia", "%84,9", size),
            ],
          ),
        ],
      ),
    );
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
      Size size,
      ) {
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
                  Icon(Icons.keyboard_arrow_down, size: size.width * 0.05),
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
                  color: Colors.red.shade400,
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
    final chartSize = size.width * 0.75;
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
        SizedBox(height: size.height * 0.18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1060),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: size.height * 0.022),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(size.width * 0.08),
              ),
            ),
            child: Text(
              "Hemen Ekle",
              style: TextStyle(
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.bold,
              ),
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
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.15;
    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    final paintEmtia = Paint()
      ..color = const Color(0xFF00C4B4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final paintDoviz = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      rect,
      -math.pi / 2.2,
      2 * math.pi * 0.849,
      false,
      paintEmtia,
    );
    canvas.drawArc(
      rect,
      2 * math.pi * 0.849 - (math.pi / 2.2) + 0.05,
      2 * math.pi * 0.151 - 0.05,
      false,
      paintDoviz,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}