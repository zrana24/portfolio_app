import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/price_services.dart';
import '../../models/price_item.dart' as api;
import 'livePrices_event.dart';
import 'livePrices_state.dart';

class LivePricesBloc extends Bloc<LivePricesEvent, LivePricesState> {
  final PriceService _priceService;
  Timer? _clockTimer;
  Timer? _pollingTimer;

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

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(const RefreshLivePrices());
    });
    print('🔄 Polling başlatıldı: Her 5 saniyede bir veri çekilecek.');
  }

  Future<void> _onLoad(
      LoadLivePrices event,
      Emitter<LivePricesState> emit,
      ) async {
    print('\n🎬 ═══════════════════════════════════════════════════════════');
    print('📥 BLOC EVENT: LoadLivePrices');
    print('═══════════════════════════════════════════════════════════');

    emit(const LivePricesLoading());
    print('📤 STATE EMIT: LivePricesLoading');

    try {
      final items = await _priceService.fetchAllPrices();

      print('\n📊 SERVICE\'DEN GELEN VERİLER:');
      print('├─ Toplam Item Sayısı: ${items.length}');

      for (var i = 0; i < items.length; i++) {
        var item = items[i];
        print('\n  Item #${i + 1}:');
        print('  ├─ Symbol: ${item.symbol}');
        print('  ├─ Name: ${item.name}');
        print('  ├─ Buy (Alış): ${item.buy}');
        print('  ├─ Sell (Satış): ${item.sell}');
        print('  ├─ High: ${item.high}');
        print('  ├─ Low: ${item.low}');
        print('  ├─ Change %: ${item.changePct}');
        print('  └─ Timestamp: ${item.timestamp}');
      }

      final blocItems = items.map((item) {
        final blocItem = PriceItem(
          code: item.symbol,
          name: item.name ?? item.symbol,
          buy: item.buy,
          sell: item.sell,
          changePct: item.changePct,
        );

        print('\n🔄 API → BLoC Model Dönüşümü:');
        print('├─ Code: ${blocItem.code}');
        print('├─ Name: ${blocItem.name}');
        print('├─ Buy: ${blocItem.buy}');
        print('├─ Sell: ${blocItem.sell}');
        print('└─ Change %: ${blocItem.changePct}');

        return blocItem;
      }).toList();

      print('\n✅ BLOC ITEMS OLUŞTURULDU: ${blocItems.length} adet');

      final loadedState = LivePricesLoaded(
        allItems: blocItems,
        lastUpdated: DateTime.now(),
      );

      emit(loadedState);

      print('\n📤 STATE EMIT: LivePricesLoaded');
      print('├─ Items: ${loadedState.allItems.length}');
      print('├─ ViewMode: ${loadedState.viewMode}');
      print('├─ SearchQuery: "${loadedState.searchQuery}"');
      print('└─ LastUpdated: ${loadedState.lastUpdated}');

      _startClock();
      _startPolling();
      print('⏰ Clock timer başlatıldı');
    }
    on PriceServiceException catch (e) {
      print('\n❌ PRICE SERVICE EXCEPTION: ${e.message}');
      emit(LivePricesError(message: e.message));
      print('📤 STATE EMIT: LivePricesError');
    }
    catch (e) {
      print('\n❌ BEKLENMEYEN HATA: $e');
      print('Stack: ${StackTrace.current}');
      emit(LivePricesError(message: 'Beklenmeyen hata: $e'));
      print('📤 STATE EMIT: LivePricesError');
    } finally {
      print('═══════════════════════════════════════════════════════════\n');
    }
  }

  Future<void> _onRefresh(
      RefreshLivePrices event,
      Emitter<LivePricesState> emit,
      ) async {
    print('\n🔄 ═══════════════════════════════════════════════════════════');
    print('📥 BLOC EVENT: RefreshLivePrices');
    print('═══════════════════════════════════════════════════════════');

    final previous = state is LivePricesLoaded ? state as LivePricesLoaded : null;

    if (previous != null) {
      print('✅ Previous state bulundu: ${previous.allItems.length} items');
      emit(LivePricesRefreshing(
        allItems: previous.allItems,
        lastUpdated: previous.lastUpdated,
        viewMode: previous.viewMode,
        searchQuery: previous.searchQuery,
      ));
      print('📤 STATE EMIT: LivePricesRefreshing');
    } else {
      print('⚠️ Previous state yok, Loading state emit ediliyor');
      emit(const LivePricesLoading());
      print('📤 STATE EMIT: LivePricesLoading');
    }

    try {
      final items = await _priceService.fetchAllPrices();
      print('\n📊 REFRESH - Gelen veri sayısı: ${items.length}');

      final blocItems = items.map((item) => PriceItem(
        code: item.symbol,
        name: item.name ?? item.symbol,
        buy: item.buy,
        sell: item.sell,
        changePct: item.changePct,
      )).toList();

      final now = DateTime.now();
      if (previous != null) {
        final updatedState = previous.copyWith(allItems: blocItems, lastUpdated: now);
        emit(updatedState);
        print('📤 STATE EMIT: LivePricesLoaded (updated from previous)');
        print('└─ Items: ${updatedState.allItems.length}');
      }
      else {
        final newState = LivePricesLoaded(allItems: blocItems, lastUpdated: now);
        emit(newState);
        print('📤 STATE EMIT: LivePricesLoaded (new)');
        print('└─ Items: ${newState.allItems.length}');
      }
    }
    on PriceServiceException catch (e) {
      print('\n❌ REFRESH HATASI: ${e.message}');
      emit(LivePricesError(message: e.message, previousState: previous));
      print('📤 STATE EMIT: LivePricesError (with previous)');
    }
    catch (e) {
      print('\n❌ REFRESH BEKLENMEYEN HATA: $e');
      emit(LivePricesError(
        message: 'Beklenmeyen hata: $e',
        previousState: previous,
      ));
      print('📤 STATE EMIT: LivePricesError');
    } finally {
      print('═══════════════════════════════════════════════════════════\n');
    }
  }

  void _onLivePriceUpdated(
      LivePriceUpdated event,
      Emitter<LivePricesState> emit,
      ) {
    print('\n📝 BLOC EVENT: LivePriceUpdated - ${event.updatedItem.code}');

    if (state is! LivePricesLoaded) {
      print('⚠️ State LivePricesLoaded değil, güncelleme atlanıyor');
      return;
    }

    final current = state as LivePricesLoaded;
    final updated = current.allItems
        .map((e) => e.code == event.updatedItem.code ? event.updatedItem : e)
        .toList();

    emit(current.copyWith(allItems: updated, lastUpdated: DateTime.now()));
    print('📤 STATE EMIT: LivePricesLoaded (price updated)');
  }

  void _onToggleViewMode(
      ToggleViewMode event,
      Emitter<LivePricesState> emit,
      ) {
    print('\n🔀 BLOC EVENT: ToggleViewMode');

    if (state is! LivePricesLoaded) {
      print('⚠️ State LivePricesLoaded değil, toggle atlanıyor');
      return;
    }

    final current = state as LivePricesLoaded;
    final next = current.viewMode == ViewMode.list ? ViewMode.table : ViewMode.list;

    print('├─ Current Mode: ${current.viewMode}');
    print('└─ New Mode: $next');

    emit(current.copyWith(viewMode: next));
    print('📤 STATE EMIT: LivePricesLoaded (view mode toggled)');
  }

  void _onSetViewMode(
      SetViewMode event,
      Emitter<LivePricesState> emit,
      ) {
    print('\n⚙️ BLOC EVENT: SetViewMode - ${event.mode}');

    if (state is! LivePricesLoaded) return;

    final current = state as LivePricesLoaded;
    emit(current.copyWith(viewMode: event.mode));
    print('📤 STATE EMIT: LivePricesLoaded (view mode set)');
  }

  void _onSearch(
      SearchPrices event,
      Emitter<LivePricesState> emit,
      ) {
    print('\n🔍 BLOC EVENT: SearchPrices - "${event.query}"');

    if (state is! LivePricesLoaded) return;

    final current = state as LivePricesLoaded;
    emit(current.copyWith(searchQuery: event.query));
    print('📤 STATE EMIT: LivePricesLoaded (search updated)');
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
    print('⏰ Clock timer started (1 tick/second)');
  }

  @override
  Future<void> close() {
    print('\n🛑 LivePricesBloc CLOSING');
    _clockTimer?.cancel();
    print('├─ Clock timer cancelled');
    _pollingTimer?.cancel();
    _priceService.dispose();
    print('└─ PriceService disposed');
    return super.close();
  }
}