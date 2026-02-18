import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/addPortfolio/addportfolio_bloc.dart';
import '../../bloc/addPortfolio/addPortfolio_event.dart';
import '../../bloc/addPortfolio/addPortfolio_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/back_button.dart';
import '../../widgets/footer.dart';

class AddPortfolioPage extends StatelessWidget {
  const AddPortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => AddPortfolioBloc()..add(LoadPortfolioTypes()),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBody: true,
        bottomNavigationBar: const CebeciBottomNav(currentIndex: 1),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildAppBar(context, size),
              Expanded(
                child: BlocBuilder<AddPortfolioBloc, AddPortfolioState>(
                  builder: (context, state) {
                    if (state is AddPortfolioLoading) {
                      return _buildSkeletonLoading(size);
                    } else if (state is AddPortfolioLoaded) {
                      return _buildList(state.portfolioTypes, size);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────

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
            child: BackButtonWidget(),   // ← reusable widget
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

  // ─────────────────────────────────────────────
  // SKELETON LOADING
  // ─────────────────────────────────────────────

  Widget _buildSkeletonLoading(Size size) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        right: size.width * 0.05,
        top: size.height * 0.01,
        bottom: size.height * 0.14,
      ),
      itemCount: 8,
      separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
      itemBuilder: (_, __) => _SkeletonCard(size: size),
    );
  }

  // ─────────────────────────────────────────────
  // LOADED LIST
  // ─────────────────────────────────────────────

  Widget _buildList(List<PortfolioType> types, Size size) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        right: size.width * 0.05,
        top: size.height * 0.01,
        bottom: size.height * 0.14,
      ),
      itemCount: types.length,
      separatorBuilder: (_, __) => SizedBox(height: size.height * 0.012),
      itemBuilder: (_, i) => _PortfolioTypeCard(type: types[i], size: size),
    );
  }
}

// ─────────────────────────────────────────────
// PORTFOLIO TYPE CARD
// ─────────────────────────────────────────────

class _PortfolioTypeCard extends StatelessWidget {
  final PortfolioType type;
  final Size size;

  const _PortfolioTypeCard({required this.type, required this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.018,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Row(
          children: [
            Container(
              width: size.width * 0.11,
              height: size.width * 0.11,
              decoration: BoxDecoration(
                color: type.color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                type.icon,
                color: Colors.white,
                size: size.width * 0.055,
              ),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                type.title,
                style: TextStyle(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.black54,
              size: size.width * 0.055,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SKELETON CARD
// ─────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  final Size size;

  const _SkeletonCard({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(size.width * 0.04),
      ),
      child: Row(
        children: [
          _ShimmerBox(
            width: size.width * 0.11,
            height: size.width * 0.11,
            borderRadius: size.width * 0.055,
          ),
          SizedBox(width: size.width * 0.04),
          _ShimmerBox(
            width: size.width * 0.35,
            height: size.height * 0.022,
            borderRadius: 8,
          ),
          const Spacer(),
          _ShimmerBox(
            width: size.width * 0.05,
            height: size.width * 0.05,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SHIMMER BOX
// ─────────────────────────────────────────────

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