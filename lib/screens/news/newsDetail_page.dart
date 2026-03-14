import 'package:flutter/material.dart';
import '../../services/news_service.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';
import '../../widgets/news_shimmer.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsArticle? article;
  final int? newsId;

  const NewsDetailPage({
    super.key,
    this.article,
    this.newsId,
  }) : assert(article != null || newsId != null,
  'Either article or newsId must be provided');

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final NewsService _newsService = NewsService();
  NewsArticle? _article;
  bool _isLoading = false;
  String? _error;

  static const Color _primary = Color(0xFF1A0B52);
  static const Color _cardBg = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _article = widget.article;
    } else if (widget.newsId != null) {
      _loadNewsDetail();
    }
  }

  Future<void> _loadNewsDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🔄 [NewsDetailPage] Loading news detail for ID: ${widget.newsId}');
      final article = await _newsService.fetchNewsDetail(widget.newsId!);
      print('✅ [NewsDetailPage] Detail loaded successfully');

      setState(() {
        _article = article;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ [NewsDetailPage] Error loading detail: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _newsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_error != null) {
      return _buildErrorState(context, _error!);
    }

    if (_article == null) {
      return _buildErrorState(context, 'Haber bulunamadı');
    }

    return _buildContent(context, _article!);
  }

  Widget _buildLoadingState(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, size),
            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: NewsDetailShimmer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, size),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: size.width * 0.15,
                          color: Colors.grey.shade300),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: size.width * 0.04,
                          color: Colors.black54,
                        ),
                      ),
                      if (widget.newsId != null) ...[
                        SizedBox(height: size.height * 0.025),
                        ElevatedButton(
                          onPressed: _loadNewsDetail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(size.width * 0.06),
                            ),
                          ),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04, vertical: size.height * 0.012),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.025),
              decoration: const BoxDecoration(
                color: _cardBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: size.width * 0.045, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Text(
              'Haber Detay',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.1),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NewsArticle article) {
    final size = MediaQuery.of(context).size;

    final related = <NewsArticle>[];

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, size),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.015),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.03,
                        vertical: size.height * 0.006,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(article.categoryColor)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      child: Text(
                        article.categoryLabel,
                        style: TextStyle(
                          fontSize: size.width * 0.032,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(article.categoryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),

                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),

                    Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            size: size.width * 0.035, color: Colors.grey),
                        SizedBox(width: size.width * 0.015),
                        Text(
                          article.timeAgo,
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(width: size.width * 0.04),
                        Icon(Icons.book_outlined,
                            size: size.width * 0.035, color: Colors.grey),
                        SizedBox(width: size.width * 0.015),
                        Text(
                          '${article.readingTime} dk okuma',
                          style: TextStyle(
                            fontSize: size.width * 0.032,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(size.width * 0.04),
                        image: article.imageUrl.isNotEmpty
                            ? DecorationImage(
                          image: NetworkImage(article.imageUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: article.imageUrl.isEmpty
                          ? Center(
                        child: Icon(Icons.image_outlined,
                            size: size.width * 0.12,
                            color: Colors.grey.shade400),
                      )
                          : null,
                    ),
                    SizedBox(height: size.height * 0.02),

                    if (article.sourceName.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.015),
                        child: Row(
                          children: [
                            Icon(Icons.article_outlined,
                                size: size.width * 0.035, color: Colors.grey),
                            SizedBox(width: size.width * 0.015),
                            Text(
                              'Kaynak: ${article.sourceName}',
                              style: TextStyle(
                                fontSize: size.width * 0.03,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (article.tags.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                        child: Wrap(
                          spacing: size.width * 0.02,
                          runSpacing: size.height * 0.008,
                          children: article.tags.map((tag) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.025,
                                vertical: size.height * 0.004,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius:
                                BorderRadius.circular(size.width * 0.015),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: size.width * 0.028,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                    Text(
                      article.content.isNotEmpty
                          ? article.content
                          : article.summary,
                      style: TextStyle(
                        fontSize: size.width * 0.036,
                        color: const Color(0xFF444444),
                        height: 1.65,
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),

                    if (article.sourceUrl != null &&
                        article.sourceUrl!.isNotEmpty)
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // launch(article.sourceUrl!);
                          },
                          icon: Icon(Icons.open_in_new_rounded,
                              size: size.width * 0.04),
                          label: const Text('Kaynağı Görüntüle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primary,
                            side: BorderSide(color: _primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(size.width * 0.06),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.06,
                              vertical: size.height * 0.015,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(height: size.height * 0.04),

                    if (related.isNotEmpty) ...[
                      Text(
                        'İlginizi Çekecek Diğer Haberler',
                        style: TextStyle(
                          fontSize: size.width * 0.042,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: size.height * 0.015),
                      Row(
                        children: related.asMap().entries.map((e) {
                          final isLast = e.key == related.length - 1;
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  right: isLast ? 0 : size.width * 0.03),
                              child: _relatedCard(context, e.value, size),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _relatedCard(BuildContext context, NewsArticle article, Size size) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => NewsDetailPage(article: article),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(size.width * 0.04),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: size.height * 0.1,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(size.width * 0.04)),
                image: article.imageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(article.imageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              width: double.infinity,
              child: article.imageUrl.isEmpty
                  ? Center(
                child: Icon(Icons.image_outlined,
                    size: size.width * 0.07,
                    color: Colors.grey.shade400),
              )
                  : null,
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
                        article.timeAgo,
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

  Color _getCategoryColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF3B82F6);
    }
  }
}