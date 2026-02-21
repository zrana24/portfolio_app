import 'package:equatable/equatable.dart';
import 'news_event.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {
  const NewsInitial();
}

class NewsLoading extends NewsState {
  const NewsLoading();
}

class NewsLoaded extends NewsState {
  final List<NewsArticle> featured;
  final List<NewsArticle> sections;
  final bool hasMore;

  const NewsLoaded({
    required this.featured,
    required this.sections,
    this.hasMore = false,
  });

  NewsLoaded copyWith({
    List<NewsArticle>? featured,
    List<NewsArticle>? sections,
    bool? hasMore,
  }) {
    return NewsLoaded(
      featured: featured ?? this.featured,
      sections: sections ?? this.sections,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [featured, sections, hasMore];
}

class NewsError extends NewsState {
  final String message;

  const NewsError({required this.message});

  @override
  List<Object?> get props => [message];
}