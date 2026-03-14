import 'package:equatable/equatable.dart';

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
  final String? category;

  const LoadMoreNews({this.category});

  @override
  List<Object?> get props => [category];
}