import 'package:equatable/equatable.dart';
import 'livePrices_event.dart';

abstract class LivePricesState extends Equatable {
  const LivePricesState();

  @override
  List<Object?> get props => [];
}

class LivePricesInitial extends LivePricesState {
  const LivePricesInitial();
}

class LivePricesLoading extends LivePricesState {
  const LivePricesLoading();
}

class LivePricesLoaded extends LivePricesState {
  final List<PriceItem> allItems;
  final ViewMode viewMode;
  final String searchQuery;
  final DateTime lastUpdated;

  const LivePricesLoaded({
    required this.allItems,
    required this.lastUpdated,
    this.viewMode = ViewMode.table,
    this.searchQuery = '',
  });

  List<PriceItem> get displayedItems {
    if (searchQuery.isEmpty) return allItems;
    final q = searchQuery.toLowerCase();
    return allItems
        .where((item) =>
    item.code.toLowerCase().contains(q) ||
        item.name.toLowerCase().contains(q))
        .toList();
  }

  LivePricesLoaded copyWith({
    List<PriceItem>? allItems,
    ViewMode? viewMode,
    String? searchQuery,
    DateTime? lastUpdated,
  }) {
    return LivePricesLoaded(
      allItems: allItems ?? this.allItems,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [allItems, viewMode, searchQuery, lastUpdated];
}

class LivePricesRefreshing extends LivePricesLoaded {
  const LivePricesRefreshing({
    required super.allItems,
    required super.lastUpdated,
    super.viewMode,
    super.searchQuery,
  });
}

class LivePricesError extends LivePricesState {
  final String message;
  final LivePricesLoaded? previousState;

  const LivePricesError({required this.message, this.previousState});

  bool get hasPreviousData => previousState != null;

  @override
  List<Object?> get props => [message, previousState];
}