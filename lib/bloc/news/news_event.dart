// lib/bloc/news/news_event.dart

import 'package:equatable/equatable.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class NewsArticle {
  final String id;
  final String title;
  final String category;
  final String content;
  final String imageUrl;
  final DateTime publishedAt;
  final String source;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
  });
}

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNews extends NewsEvent {
  const LoadNews();
}

class RefreshNews extends NewsEvent {
  const RefreshNews();
}

class LoadMoreNews extends NewsEvent {
  const LoadMoreNews();
}