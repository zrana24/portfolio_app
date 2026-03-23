import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/news/news_bloc.dart';
import '../../bloc/news/news_event.dart';
import '../../bloc/news/news_state.dart';
import '../../services/news_service.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';
import '../../widgets/news_shimmer.dart';
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
  static const Color _cardBg = Color(0xFFF3F4F6);

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
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 1),
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
                          const SliverToBoxAdapter(child: NewsShimmer())
                        else if (state is NewsLoaded)
                          ..._buildLoadedContent(context, state, size)
                        else if (state is NewsError)
                            SliverToBoxAdapter(
                                child: _buildError(context, size, state.message)),
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
    if (state.featured.isEmpty && state.sections.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.08),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.article_outlined,
                    size: size.width * 0.2,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: size.height * 0.025),
                  Text(
                    'Henüz Haber Yok',
                    style: TextStyle(
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: size.height * 0.012),
                  Text(
                    'Haberler yakında burada görünecek.\nLütfen daha sonra tekrar kontrol edin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.036,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final Map<String, List<NewsArticle>> grouped = {};
    for (final article in state.sections) {
      grouped.putIfAbsent(article.category, () => []).add(article);
    }

    return [
      if (state.featured.isNotEmpty)
        SliverToBoxAdapter(
          child: SizedBox(
            height: size.height * 0.32,
            child: PageView.builder(
              controller: _pageController,
              itemCount: state.featured.length,
              onPageChanged: (i) => setState(() => _featuredIndex = i),
              itemBuilder: (_, i) =>
                  _newsCard(context, state.featured[i], size),
            ),
          ),
        ),

      if (state.featured.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(
                top: size.height * 0.012, bottom: size.height * 0.025),
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

      ...grouped.entries.map(
            (entry) => _buildSection(context, entry.key, entry.value, size),
      ),

      SliverToBoxAdapter(child: SizedBox(height: size.height * 0.04)),
    ];
  }

  Widget _newsCard(BuildContext context, NewsArticle article, Size size) {
    return GestureDetector(
      onTap: () => _openDetail(context, article),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0),
        child: Container(
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(size.width * 0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: size.height * 0.15,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(size.width * 0.04)),
                  image: article.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(article.imageUrl),
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                    },
                  )
                      : null,
                ),
                width: double.infinity,
                child: article.imageUrl.isEmpty
                    ? Center(
                  child: Icon(Icons.image_outlined,
                      size: size.width * 0.1,
                      color: Colors.grey.shade400),
                )
                    : null,
              ),
              Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.025,
                        vertical: size.height * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(article.categoryColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(size.width * 0.015),
                      ),
                      child: Text(
                        article.categoryLabel,
                        style: TextStyle(
                          fontSize: size.width * 0.028,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(article.categoryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    Text(
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
                  ],
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
    final categoryLabel = articles.first.categoryLabel;

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
              categoryLabel,
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
                  padding: EdgeInsets.only(bottom: size.height * 0.010),
                  child: Row(
                    children: [
                      Expanded(child: _newsCard(context, left, size)),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                          child: right != null
                              ? _newsCard(context, right, size)
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

  Widget _buildError(BuildContext context, Size size, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded,
                size: size.width * 0.15, color: Colors.grey.shade300),
            SizedBox(height: size.height * 0.02),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: size.width * 0.04, color: Colors.black54)),
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

  Color _getCategoryColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF3B82F6);
    }
  }
}