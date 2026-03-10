import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'livePrices_event.dart';
import 'livePrices_state.dart';

class _MockPricesRepository {
  Future<List<PriceItem>> fetchAll() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const PriceItem(code: 'ALTIN (GRAM)',        name: 'Gram Altın',           buy: 51808, sell: 51950, changePct: 0.0),
      const PriceItem(code: 'CUMHURİYET ALTINI',  name: 'Cumhuriyet Altını',    buy: 51808, sell: 52100, changePct: 0.2),
      const PriceItem(code: 'KULPLU REŞAT ALTIN', name: 'Kulplu Reşat Altın',  buy: 51808, sell: 51980, changePct: -0.1),
      const PriceItem(code: 'ÇEYREK ALTIN',        name: 'Çeyrek Altın',         buy: 51808, sell: 51960, changePct: 0.0),
      const PriceItem(code: 'YARIM ALTIN',         name: 'Yarım Altın',          buy: 51808, sell: 51970, changePct: 0.3),
      const PriceItem(code: 'TAM ALTIN',           name: 'Tam Altın',            buy: 51808, sell: 51990, changePct: -0.2),
      const PriceItem(code: 'ATA ALTIN',           name: 'Ata Altın',            buy: 51808, sell: 52050, changePct: 0.0),
      const PriceItem(code: 'USD',                 name: 'Amerikan Doları',      buy: 43709, sell: 43850, changePct: -0.1),
      const PriceItem(code: 'EUR',                 name: 'Avro',                 buy: 43709, sell: 43900, changePct: -0.1),
      const PriceItem(code: 'GBP',                 name: 'İngiliz Poundu',       buy: 43709, sell: 43950, changePct: 0.0),
      const PriceItem(code: 'CHF',                 name: 'İsviçre Frangı',       buy: 43709, sell: 43880, changePct: 0.1),
      const PriceItem(code: 'AED',                 name: 'BAE Dirhemi',          buy: 43709, sell: 43820, changePct: 0.0),
      const PriceItem(code: 'SAR',                 name: 'Suudi Riyali',         buy: 43709, sell: 43810, changePct: 0.2),
      const PriceItem(code: 'JPY',                 name: 'Japon Yeni',           buy: 43709, sell: 43760, changePct: -0.3),
    ];
  }
}

class LivePricesBloc extends Bloc<LivePricesEvent, LivePricesState> {
  final _MockPricesRepository _repo = _MockPricesRepository();
  Timer? _clockTimer;

  LivePricesBloc() : super(const LivePricesInitial()) {
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
      final items = await _repo.fetchAll();
      emit(LivePricesLoaded(allItems: items, lastUpdated: DateTime.now()));
      _startClock();
    } catch (e) {
      emit(LivePricesError(message: e.toString()));
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
      final items = await _repo.fetchAll();
      final now = DateTime.now();
      if (previous != null) {
        emit(previous.copyWith(allItems: items, lastUpdated: now));
      } else {
        emit(LivePricesLoaded(allItems: items, lastUpdated: now));
      }
    } catch (e) {
      emit(LivePricesError(message: e.toString(), previousState: previous));
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
    return super.close();
  }
}