import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/price_services.dart';
import '../../models/price_item.dart' as api;
import 'livePrices_event.dart';
import 'livePrices_state.dart';

class LivePricesBloc extends Bloc<LivePricesEvent, LivePricesState> {
  final PriceService _priceService;
  Timer? _clockTimer;

  LivePricesBloc({PriceService? priceService})
      : _priceService = priceService ?? PriceService(),
        super(const LivePricesInitial()) {
    on<LoadLivePrices>(_onLoad);
    on<RefreshLivePrices>(_onRefresh);
    on<LivePriceUpdated>(_onLivePriceUpdated);
    on<ToggleViewMode>(_onToggleViewMode);
    on<SetViewMode>(_onSetViewMode);
    on<SearchPrices>(_onSearch);
    on<ClockTicked>(_onClockTicked);
  }

  Future<void> _onLoad(
      LoadLivePrices event,
      Emitter<LivePricesState> emit,
      ) async {
    emit(const LivePricesLoading());
    try {
      final items = await _priceService.fetchAllPrices();

      final blocItems = items.map((item) => PriceItem(
        code: item.symbol,
        name: item.name ?? item.symbol,
        buy: item.buy,
        sell: item.sell,
        changePct: item.changePct,
      )).toList();

      emit(LivePricesLoaded(
        allItems: blocItems,
        lastUpdated: DateTime.now(),
      ));
      _startClock();
    }
    on PriceServiceException catch (e) {
      emit(LivePricesError(message: e.message));
    }
    catch (e) {
      emit(LivePricesError(message: 'Beklenmeyen hata: $e'));
    }
  }

  Future<void> _onRefresh(
      RefreshLivePrices event,
      Emitter<LivePricesState> emit,
      ) async {
    final previous = state is LivePricesLoaded ? state as LivePricesLoaded : null;

    if (previous != null) {
      emit(LivePricesRefreshing(
        allItems: previous.allItems,
        lastUpdated: previous.lastUpdated,
        viewMode: previous.viewMode,
        searchQuery: previous.searchQuery,
      ));
    } else {
      emit(const LivePricesLoading());
    }

    try {
      final items = await _priceService.fetchAllPrices();

      final blocItems = items.map((item) => PriceItem(
        code: item.symbol,
        name: item.name ?? item.symbol,
        buy: item.buy,
        sell: item.sell,
        changePct: item.changePct,
      )).toList();

      final now = DateTime.now();
      if (previous != null) {
        emit(previous.copyWith(allItems: blocItems, lastUpdated: now));
      }
      else {
        emit(LivePricesLoaded(allItems: blocItems, lastUpdated: now));
      }
    }
    on PriceServiceException catch (e) {
      emit(LivePricesError(message: e.message, previousState: previous));
    }
    catch (e) {
      emit(LivePricesError(
        message: 'Beklenmeyen hata: $e',
        previousState: previous,
      ));
    }
  }

  void _onLivePriceUpdated(
      LivePriceUpdated event,
      Emitter<LivePricesState> emit,
      ) {
    if (state is! LivePricesLoaded) return;
    final current = state as LivePricesLoaded;
    final updated = current.allItems
        .map((e) => e.code == event.updatedItem.code ? event.updatedItem : e)
        .toList();
    emit(current.copyWith(allItems: updated, lastUpdated: DateTime.now()));
  }

  void _onToggleViewMode(
      ToggleViewMode event,
      Emitter<LivePricesState> emit,
      ) {
    if (state is! LivePricesLoaded) return;
    final current = state as LivePricesLoaded;
    final next = current.viewMode == ViewMode.list ? ViewMode.table : ViewMode.list;
    emit(current.copyWith(viewMode: next));
  }

  void _onSetViewMode(
      SetViewMode event,
      Emitter<LivePricesState> emit,
      ) {
    if (state is! LivePricesLoaded) return;
    final current = state as LivePricesLoaded;
    emit(current.copyWith(viewMode: event.mode));
  }

  void _onSearch(
      SearchPrices event,
      Emitter<LivePricesState> emit,
      ) {
    if (state is! LivePricesLoaded) return;
    final current = state as LivePricesLoaded;
    emit(current.copyWith(searchQuery: event.query));
  }

  void _onClockTicked(
      ClockTicked event,
      Emitter<LivePricesState> emit,
      ) {
    if (state is! LivePricesLoaded) return;
    final current = state as LivePricesLoaded;
    emit(current.copyWith(lastUpdated: event.time));
  }

  void _startClock() {
    _clockTimer?.cancel();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(ClockTicked(DateTime.now()));
    });
  }

  @override
  Future<void> close() {
    _clockTimer?.cancel();
    _priceService.dispose();
    return super.close();
  }
}