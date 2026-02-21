import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/news/news_bloc.dart';
import '../../bloc/news/news_event.dart';
import '../../bloc/news/news_state.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';
import 'newsDetail_page.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc()..add(const LoadNews()),
      child: const _NewsView(),
    );
  }
}

class _NewsView extends StatefulWidget {
  const _NewsView();

  @override
  State<_NewsView> createState() => _NewsViewState();
}

class _NewsViewState extends State<_NewsView> {
  int _featuredIndex = 0;
  final PageController _pageController = PageController();

  static const Color _primary = Color(0xFF1A0B52);
  static const Color _cardBg  = Color(0xFFF3F4F6);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CebeciAppBar(),
            Expanded(
              child: BlocBuilder<NewsBloc, NewsState>(
                builder: (context, state) {
                  return RefreshIndicator(
                    color: _primary,
                    onRefresh: () async {
                      context.read<NewsBloc>().add(const RefreshNews());
                      await context
                          .read<NewsBloc>()
                          .stream
                          .firstWhere((s) => s is NewsLoaded || s is NewsError);
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.06,
                                vertical: size.height * 0.025),
                            child: Text(
                              'Haberler',
                              style: TextStyle(
                                fontSize: size.width * 0.075,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ),
                        if (state is NewsLoading)
                          SliverToBoxAdapter(child: _buildSkeleton(size))
                        else if (state is NewsLoaded)
                          ..._buildLoadedContent(context, state, size)
                        else if (state is NewsError)
                            SliverToBoxAdapter(
                                child: _buildError(context, size)),
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

  List<Widget> _buildLoadedContent(
      BuildContext context, NewsLoaded state, Size size) {
    final Map<String, List<NewsArticle>> grouped = {};
    for (final a in state.sections) {
      grouped.putIfAbsent(a.category, () => []).add(a);
    }

    return [
      SliverToBoxAdapter(
        child: SizedBox(
          height: size.height * 0.28,
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.featured.length,
            onPageChanged: (i) => setState(() => _featuredIndex = i),
            itemBuilder: (_, i) =>
                _featuredCard(context, state.featured[i], size),
          ),
        ),
      ),

      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.only(top: size.height * 0.012,
              bottom: size.height * 0.025),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(state.featured.length, (i) {
              final active = i == _featuredIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                width: active ? size.width * 0.05 : size.width * 0.02,
                height: size.width * 0.02,
                decoration: BoxDecoration(
                  color: active ? _primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(size.width * 0.01),
                ),
              );
            }),
          ),
        ),
      ),

      ...grouped.entries.map((entry) => _buildSection(
          context, entry.key, entry.value, size)),

      SliverToBoxAdapter(child: SizedBox(height: size.height * 0.04)),
    ];
  }

  Widget _featuredCard(
      BuildContext context, NewsArticle article, Size size) {
    return GestureDetector(
      onTap: () => _openDetail(context, article),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(size.width * 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(size.width * 0.05)),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Icon(Icons.image_outlined,
                        size: size.width * 0.1, color: Colors.grey.shade400),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.04,
                    vertical: size.height * 0.008,
                  ),
                  child: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String category,
      List<NewsArticle> articles, Size size) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
            left: size.width * 0.06,
            right: size.width * 0.06,
            bottom: size.height * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Başlık (${category} Başlığı olabilir)',
              style: TextStyle(
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: size.height * 0.015),
            ...() {
              final pairs = <Widget>[];
              for (int i = 0; i < articles.length; i += 2) {
                final left = articles[i];
                final right = i + 1 < articles.length ? articles[i + 1] : null;
                pairs.add(Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.012),
                  child: Row(
                    children: [
                      Expanded(
                          child: _smallCard(context, left, size)),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                          child: right != null
                              ? _smallCard(context, right, size)
                              : const SizedBox()),
                    ],
                  ),
                ));
              }
              return pairs;
            }(),
          ],
        ),
      ),
    );
  }

  Widget _smallCard(
      BuildContext context, NewsArticle article, Size size) {
    return GestureDetector(
      onTap: () => _openDetail(context, article),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: size.height * 0.12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.04)),
              ),
              width: double.infinity,
              child: Center(
                child: Icon(Icons.image_outlined,
                    size: size.width * 0.07, color: Colors.grey.shade400),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: size.width * 0.032,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1A1A),
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(
                          fontSize: size.width * 0.026,
                          color: Colors.grey,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: size.width * 0.04,
                          color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        children: [
          _ShimmerBox(
              width: double.infinity,
              height: size.height * 0.28,
              borderRadius: size.width * 0.05),
          SizedBox(height: size.height * 0.03),
          _ShimmerBox(
              width: size.width * 0.4,
              height: size.height * 0.025,
              borderRadius: 8),
          SizedBox(height: size.height * 0.015),
          Row(children: [
            Expanded(
                child: _ShimmerBox(
                    width: double.infinity,
                    height: size.height * 0.2,
                    borderRadius: size.width * 0.04)),
            SizedBox(width: size.width * 0.03),
            Expanded(
                child: _ShimmerBox(
                    width: double.infinity,
                    height: size.height * 0.2,
                    borderRadius: size.width * 0.04)),
          ]),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, Size size) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: size.width * 0.15, color: Colors.grey.shade300),
            SizedBox(height: size.height * 0.02),
            Text('Haberler yüklenemedi',
                style: TextStyle(fontSize: size.width * 0.04,
                    color: Colors.black54)),
            SizedBox(height: size.height * 0.025),
            ElevatedButton(
              onPressed: () =>
                  context.read<NewsBloc>().add(const LoadNews()),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(size.width * 0.06)),
              ),
              child: const Text('Tekrar Dene'),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewsDetailPage(article: article),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
          '${['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'][d.month - 1]} '
          '${d.year}';
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const _ShimmerBox(
      {required this.width, required this.height, this.borderRadius = 12});

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