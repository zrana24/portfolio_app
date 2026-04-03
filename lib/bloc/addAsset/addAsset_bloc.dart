import 'package:flutter_bloc/flutter_bloc.dart';
import 'addAsset_event.dart';
import 'addAsset_state.dart';
import '../../services/portfolio_services.dart';
import '../../services/commodity_services.dart';

class AddAssetBloc extends Bloc<AddAssetEvent, AddAssetState> {
  final PortfolioService _portfolioService;
  final CommodityService _commodityService;
  final String symbol;

  AddAssetBloc({
    required this.symbol,
    PortfolioService? portfolioService,
    CommodityService? commodityService,
  })  : _portfolioService = portfolioService ?? PortfolioService(),
        _commodityService = commodityService ?? CommodityService(),
        super(AddAssetInitial()) {
    on<LoadAssetData>(_onLoadAssetData);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<UpdatePurchasePrice>(_onUpdatePurchasePrice);
    on<UpdateNotes>(_onUpdateNotes);
    on<SelectPortfolio>(_onSelectPortfolio);
    on<SaveAsset>(_onSaveAsset);
  }

  Future<void> _onLoadAssetData(
      LoadAssetData event,
      Emitter<AddAssetState> emit,
      ) async {
    emit(AddAssetLoading());

    try {
      // Paralel olarak tüm verileri yükle
      final results = await Future.wait([
        _portfolioService.getPortfolios(),
        _commodityService.fetchCommodities(), // Tüm commodity listesini çek
        _portfolioService.getPriceHistory(symbol: symbol, period: '1d'),
      ]);

      var portfolios = results[0] as List<Portfolio>;
      final commodities = results[1] as List<CommodityItem>;
      final priceHistory = results[2] as PriceHistory;

      // Symbol'e göre commodity bul
      CommodityItem? commodity;
      try {
        commodity = commodities.firstWhere((c) => c.symbol == symbol);
      } catch (e) {
        emit(AddAssetError(message: 'Sembol bulunamadı: $symbol'));
        return;
      }

      // Portföy yoksa otomatik oluştur
      if (portfolios.isEmpty) {
        await _portfolioService.createPortfolio(
          name: 'Ana Portföyüm',
          currency: 'TRY',
          isDefault: true,
        );
        portfolios = await _portfolioService.getPortfolios();
      }

      // Varsayılan portföyü seç
      Portfolio defaultPortfolio;
      try {
        defaultPortfolio = portfolios.firstWhere((p) => p.isDefault);
      } catch (e) {
        defaultPortfolio = portfolios.first;
      }

      emit(AddAssetLoaded(
        symbol: symbol,
        name: commodity.name,
        currentPrice: commodity.bid,
        askPrice: commodity.ask,
        dailyChange: commodity.dailyChangePercent,
        portfolios: portfolios,
        selectedPortfolio: defaultPortfolio,
        priceHistory: priceHistory,
        quantity: 0,
        purchasePrice: commodity.bid,
        notes: '',
      ));
    } catch (e) {
      emit(AddAssetError(message: e.toString()));
    }
  }

  void _onUpdateQuantity(
      UpdateQuantity event,
      Emitter<AddAssetState> emit,
      ) {
    if (state is AddAssetLoaded) {
      final currentState = state as AddAssetLoaded;
      emit(currentState.copyWith(quantity: event.quantity));
    }
  }

  void _onUpdatePurchasePrice(
      UpdatePurchasePrice event,
      Emitter<AddAssetState> emit,
      ) {
    if (state is AddAssetLoaded) {
      final currentState = state as AddAssetLoaded;
      emit(currentState.copyWith(purchasePrice: event.price));
    }
  }

  void _onUpdateNotes(
      UpdateNotes event,
      Emitter<AddAssetState> emit,
      ) {
    if (state is AddAssetLoaded) {
      final currentState = state as AddAssetLoaded;
      emit(currentState.copyWith(notes: event.notes));
    }
  }

  void _onSelectPortfolio(
      SelectPortfolio event,
      Emitter<AddAssetState> emit,
      ) {
    if (state is AddAssetLoaded) {
      final currentState = state as AddAssetLoaded;
      emit(currentState.copyWith(selectedPortfolio: event.portfolio));
    }
  }

  Future<void> _onSaveAsset(
      SaveAsset event,
      Emitter<AddAssetState> emit,
      ) async {
    if (state is! AddAssetLoaded) return;

    final currentState = state as AddAssetLoaded;

    // Validasyon
    if (currentState.quantity <= 0) {
      emit(AddAssetError(message: 'Miktar 0\'dan büyük olmalıdır'));
      emit(currentState);
      return;
    }

    if (currentState.purchasePrice <= 0) {
      emit(AddAssetError(message: 'Alış fiyatı 0\'dan büyük olmalıdır'));
      emit(currentState);
      return;
    }

    emit(AddAssetSaving());

    try {
      await _portfolioService.addAssetToPortfolio(
        portfolioId: currentState.selectedPortfolio.id,
        symbol: symbol,
        quantity: currentState.quantity,
        purchasePrice: currentState.purchasePrice,
        notes: currentState.notes.isEmpty ? null : currentState.notes,
      );

      emit(AddAssetSuccess());
    } catch (e) {
      emit(AddAssetError(message: e.toString()));
      emit(currentState);
    }
  }

  @override
  Future<void> close() {
    _portfolioService.dispose();
    _commodityService.dispose();
    return super.close();
  }
}