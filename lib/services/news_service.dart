import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/apiUrl.dart';

class NewsArticle {
  final int id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String sourceName;
  final String category;
  final String categoryLabel;
  final String categoryColor;
  final List<String> tags;
  final int readingTime;
  final DateTime publishedAt;
  final String timeAgo;
  final String? sourceUrl;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.sourceName,
    required this.category,
    required this.categoryLabel,
    required this.categoryColor,
    required this.tags,
    required this.readingTime,
    required this.publishedAt,
    required this.timeAgo,
    this.sourceUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      sourceName: json['source_name'] as String? ?? 'NewsAPI',
      category: json['category'] as String? ?? '',
      categoryLabel: json['category_label'] as String? ?? '',
      categoryColor: json['category_color'] as String? ?? '#3B82F6',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      readingTime: json['reading_time'] as int? ?? 0,
      publishedAt: DateTime.parse(json['published_at'] as String),
      timeAgo: json['time_ago'] as String? ?? '',
      sourceUrl: json['source_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'image_url': imageUrl,
      'source_name': sourceName,
      'category': category,
      'category_label': categoryLabel,
      'category_color': categoryColor,
      'tags': tags,
      'reading_time': readingTime,
      'published_at': publishedAt.toIso8601String(),
      'time_ago': timeAgo,
      'source_url': sourceUrl,
    };
  }
}

class NewsResponse {
  final List<NewsArticle> articles;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final DateTime? lastFetchedAt;

  const NewsResponse({
    required this.articles,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.lastFetchedAt,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return NewsResponse(
      articles: data.map((item) => NewsArticle.fromJson(item as Map<String, dynamic>)).toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      perPage: meta['per_page'] as int? ?? 20,
      total: meta['total'] as int? ?? 0,
      lastFetchedAt: meta['last_fetched_at'] != null
          ? DateTime.parse(meta['last_fetched_at'] as String)
          : null,
    );
  }
}

class NewsService {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<NewsResponse> fetchNews({
    int page = 1,
    int perPage = 20,
    String? category,
    String? tag,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (tag != null && tag.isNotEmpty) {
        queryParams['tag'] = tag;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(ApiUrls.mobileNews).replace(queryParameters: queryParams);

      final response = await _client.get(uri).timeout(_timeout);


      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final newsResponse = NewsResponse.fromJson(json);

        return newsResponse;
      } else {
        print('Error response body: ${response.body}');
        throw NewsException(
          'Failed to fetch news: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print('Exception caught: $e');
      print('Stack trace: $stackTrace');
      if (e is NewsException) rethrow;
      throw NewsException('Network error: $e');
    }
  }

  Future<List<NewsArticle>> fetchTrending() async {
    try {
      final uri = Uri.parse(ApiUrls.mobileTrending);

      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

        final data = json['data'] as List<dynamic>? ?? [];

        return data.map((item) => NewsArticle.fromJson(item as Map<String, dynamic>)).toList();
      }
      else {
        throw NewsException(
          '${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print('Trending exception: $e');
      print('Stack trace: $stackTrace');
      if (e is NewsException) rethrow;
      throw NewsException('Network error: $e');
    }
  }

  Future<NewsArticle> fetchNewsDetail(int id) async {
    try {
      final uri = Uri.parse(ApiUrls.mobileNewsDetail(id));

      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final data = json['data'] as Map<String, dynamic>;
        return NewsArticle.fromJson(data);
      } else if (response.statusCode == 404) {
        throw NewsException('Haber bulunamadı', statusCode: 404);
      } else {
        throw NewsException(
          'Failed to fetch news detail: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e, stackTrace) {
      print('Detail exception: $e');
      print('Stack trace: $stackTrace');
      if (e is NewsException) rethrow;
      throw NewsException('Network error: $e');
    }
  }

  Future<List<NewsArticle>> fetchFeatured() async {
    try {
      final trending = await fetchTrending();

      final featured = trending.take(3).toList();

      return featured;
    } catch (e) {

      try {
        final response = await fetchNews(perPage: 3);
        return response.articles;
      } catch (fallbackError) {
        print('Fallback also failed: $fallbackError');
        throw NewsException('Failed to fetch featured news: $e');
      }
    }
  }

  Future<List<NewsArticle>> fetchSections({
    int perPage = 20,
    String? category,
  }) async {
    try {
      final response = await fetchNews(
        perPage: perPage,
        category: category,
      );

      return response.articles;
    } catch (e) {
      print('Sections failed: $e');
      throw NewsException('Failed to fetch news sections: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class NewsException implements Exception {
  final String message;
  final int? statusCode;

  NewsException(this.message, {this.statusCode});

  @override
  String toString() => message;
}