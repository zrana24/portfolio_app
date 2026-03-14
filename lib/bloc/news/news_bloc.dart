import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'news_event.dart';
import 'news_state.dart';
import '../../services/news_service.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsService _newsService;

  NewsBloc({NewsService? newsService})
      : _newsService = newsService ?? NewsService(),
        super(const NewsInitial()) {
    on<LoadNews>(_onLoad);
    on<RefreshNews>(_onRefresh);
    on<LoadMoreNews>(_onLoadMore);
  }

  Future<void> _onLoad(LoadNews event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());

    try {
      final results = await Future.wait([
        _newsService.fetchFeatured(),
        _newsService.fetchSections(perPage: 20),
      ]);

      final featured = results[0] as List<NewsArticle>;
      final sections = results[1] as List<NewsArticle>;

      emit(NewsLoaded(
        featured: featured,
        sections: sections,
        hasMore: sections.length >= 20,
      ));
    } catch (e, stackTrace) {
      print('Load failed: $e');
      print('Stack trace: $stackTrace');
      emit(NewsError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onRefresh(RefreshNews event, Emitter<NewsState> emit) async {
    try {
      final results = await Future.wait([
        _newsService.fetchFeatured(),
        _newsService.fetchSections(perPage: 20),
      ]);

      final featured = results[0] as List<NewsArticle>;
      final sections = results[1] as List<NewsArticle>;

      print('Refresh complete - Featured: ${featured.length}, Sections: ${sections.length}');

      emit(NewsLoaded(
        featured: featured,
        sections: sections,
        hasMore: true,
      ));
    } catch (e, stackTrace) {
      print('Refresh failed: $e');
      print('Stack trace: $stackTrace');
      emit(NewsError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onLoadMore(LoadMoreNews event, Emitter<NewsState> emit) async {
    if (state is! NewsLoaded) return;
    final current = state as NewsLoaded;

    if (!current.hasMore) return;

    try {
      final currentPage = (current.sections.length / 20).ceil();
      final nextPage = currentPage + 1;

      final moreNews = await _newsService.fetchSections(
        perPage: 20,
        category: event.category,
      );

      if (moreNews.isEmpty) {
        emit(current.copyWith(hasMore: false));
        return;
      }

      emit(current.copyWith(
        sections: [...current.sections, ...moreNews],
        hasMore: moreNews.length >= 20,
      ));
    } catch (e) {
      emit(current.copyWith(hasMore: false));
    }
  }

  String _getErrorMessage(Object error) {
    if (error is NewsException) {
      return error.message;
    }
    return 'Haberler yüklenirken bir hata oluştu';
  }

  @override
  Future<void> close() {
    _newsService.dispose();
    return super.close();
  }
}