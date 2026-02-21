import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'news_event.dart';
import 'news_state.dart';

class _MockNewsRepository {
  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Prom tempus dapibus nibh. Mauris vestibulum volutpat quam eget vehicula. Praesent non sem et massa ullamcorper volutpat in id tortor. Phasellus porttitor volutpat lacus, ut rutrum and dignissim au. Cras egestas diam eu odio efficitur laoreet. Integer finibus massa at justo consectetur convallis. Fusce vestibulum nulla eget lacus porta, a congue massa interdum. Cras sit amet aliquam ante. Vestibulum sollicitudin urna id ligula tincidunt, et pulvinar at sapien ultrices.\n\nSuspendisse volutpat arcu nec turpis convallis, quis sollicitudin dui elementum. Praesent eget ullamcorper ipsum. Pellentesque lacus nisl, ornare sit amet imperdiet sit amet, auctor nec mauris. Curabitur mollis ante sed odio semandas, quis viverra ex venenatis. Donec faucibus vulputate quam, non finibus tellus maximus sit amet. Sed condimentum nisl at sapien commodo, a vulputate nam porttitor.\n\nİlginizi çekecek diğer haberler için sayfayı kaydırabilirsiniz. Prom euismod fermentum nibh sit amet imperdiet. Cras elit nulla, hendrerit eget mattis vitae, placerat vel tellus.';

  Future<List<NewsArticle>> fetchFeatured() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.generate(
      3,
          (i) => NewsArticle(
        id: 'featured_$i',
        title: 'Haber Başlığı En fazla 3 satır olacak şekilde.',
        category: ['Altın', 'Döviz', 'Ekonomi'][i],
        content: _lorem,
        imageUrl: '',
        publishedAt: DateTime(2026, 1, 15),
        source: 'Cebeci',
      ),
    );
  }

  Future<List<NewsArticle>> fetchSections() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return List.generate(
      8,
          (i) => NewsArticle(
        id: 'section_$i',
        title: 'Haber Haber Haber Haber',
        category: i % 2 == 0 ? 'Altın' : 'Döviz',
        content: _lorem,
        imageUrl: '',
        publishedAt: DateTime(2026, 1, 15),
        source: 'Cebeci',
      ),
    );
  }
}

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final _MockNewsRepository _repo = _MockNewsRepository();

  NewsBloc() : super(const NewsInitial()) {
    on<LoadNews>(_onLoad);
    on<RefreshNews>(_onRefresh);
    on<LoadMoreNews>(_onLoadMore);
  }

  Future<void> _onLoad(LoadNews event, Emitter<NewsState> emit) async {
    emit(const NewsLoading());
    try {
      final results = await Future.wait([
        _repo.fetchFeatured(),
        _repo.fetchSections(),
      ]);
      emit(NewsLoaded(featured: results[0], sections: results[1]));
    } catch (e) {
      emit(NewsError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshNews event, Emitter<NewsState> emit) async {
    try {
      final results = await Future.wait([
        _repo.fetchFeatured(),
        _repo.fetchSections(),
      ]);
      emit(NewsLoaded(featured: results[0], sections: results[1]));
    } catch (e) {
      emit(NewsError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreNews event, Emitter<NewsState> emit) async {
    if (state is! NewsLoaded) return;
    final current = state as NewsLoaded;
    try {
      final more = await _repo.fetchSections();
      emit(current.copyWith(
        sections: [...current.sections, ...more],
        hasMore: false,
      ));
    } catch (_) {}
  }
}