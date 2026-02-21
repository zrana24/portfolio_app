import 'package:flutter/material.dart';
import '../../bloc/news/news_event.dart';
import '../../widgets/nav.dart';
import '../../widgets/footer.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticle article;

  const NewsDetailPage({super.key, required this.article});

  static const Color _primary = Color(0xFF1A0B52);
  static const Color _cardBg  = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final related = List.generate(
      2,
          (i) => NewsArticle(
        id: 'related_$i',
        title: 'Haber Haber Haber Haber',
        category: article.category,
        content: article.content,
        imageUrl: '',
        publishedAt: article.publishedAt,
        source: article.source,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CebeciBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.012),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(size.width * 0.025),
                      decoration: BoxDecoration(
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
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.015),

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
                    Text(
                      _formatDate(article.publishedAt),
                      style: TextStyle(
                        fontSize: size.width * 0.032,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    Container(
                      width: double.infinity,
                      height: size.height * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                        BorderRadius.circular(size.width * 0.04),
                      ),
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: size.width * 0.12,
                            color: Colors.grey.shade400),
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),

                    Text(
                      article.content,
                      style: TextStyle(
                        fontSize: size.width * 0.036,
                        color: const Color(0xFF444444),
                        height: 1.65,
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),

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
                            child: _relatedCard(
                                context, e.value, size),
                          ),
                        );
                      }).toList(),
                    ),

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

  Widget _relatedCard(
      BuildContext context, NewsArticle article, Size size) {
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
              ),
              width: double.infinity,
              child: Center(
                child: Icon(Icons.image_outlined,
                    size: size.width * 0.07,
                    color: Colors.grey.shade400),
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

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
          '${['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'][d.month - 1]} '
          '${d.year}';
}