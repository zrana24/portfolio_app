import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../services/home_service.dart';
import '../../services/auth_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());

    try {
      final isLoggedIn = await AuthService().isLoggedIn();
      if (!isLoggedIn) {
        emit(const HomeEmpty());
        return;
      }

      final responses = await Future.wait([
        HomeService.getPortfolioSummary(),
        HomeService.getPortfolioChart(),
      ]);

      final summaryResponse = responses[0];
      final chartResponse = responses[1];

      if (summaryResponse == null || summaryResponse['data'] == null) {
        emit(const HomeEmpty());
        return;
      }

      final data = summaryResponse['data'];
      final List<dynamic> chartDataList = chartResponse['data'] is List ? chartResponse['data'] : [];

      final Map<String, dynamic> symbolCharts = {};
      for (var chartItem in chartDataList) {
        if (chartItem['symbol'] != null) {
          symbolCharts[chartItem['symbol']] = chartItem;
        }
      }

      final List<AssetItem> assetsList = [];
      if (data['all_assets'] != null && data['all_assets'] is List) {
        for (var item in data['all_assets']) {
          print('🔍 ASSET RAW DATA: $item');

          final symbol = item['symbol']?.toString() ?? '';

          // ÖNCE asset_id'yi kontrol et (API'den gelen primary key)
          int assetId = 0;
          if (item['asset_id'] != null) {
            assetId = _safeToInt(item['asset_id']);
            print('✅ asset_id kullanılıyor: $assetId');
          } else if (item['id'] != null) {
            assetId = _safeToInt(item['id']);
            print('⚠️ id kullanılıyor (fallback): $assetId');
          } else if (item['portfolio_asset_id'] != null) {
            assetId = _safeToInt(item['portfolio_asset_id']);
            print('⚠️ portfolio_asset_id kullanılıyor (fallback): $assetId');
          }

          if (assetId == 0) {
            print('❌ UYARI: Asset ID bulunamadı! Item: $item');
            continue; // Bu asset'i atla
          }

          assetsList.add(AssetItem(
            id: assetId, // API'den gelen doğru asset_id
            portfolioId: _safeToInt(item['portfolio_id']),
            portfolioName: item['portfolio_name']?.toString(),
            symbol: symbol,
            name: item['name']?.toString() ?? symbol ?? 'Varlık',
            quantity: _safeToDouble(item['quantity']),
            purchasePrice: _safeToDouble(item['purchase_price']),
            currentPrice: _safeToDouble(item['current_price']),
            currentValue: _safeToDouble(item['current_value']),
            profitLoss: _safeToDouble(item['profit_loss']),
            pnlPercent: _safeToDouble(item['pnl_percent']),
            chartData: symbolCharts[symbol],
          ));

          print('✅ Asset eklendi - ID: $assetId, Name: ${item['name']}');
        }
      }

      final List<CategoryDistribution> categoryList = [];
      if (data['category_distribution'] != null && data['category_distribution'] is List) {
        for (var cat in data['category_distribution']) {
          categoryList.add(CategoryDistribution(
            category: cat['category']?.toString() ?? '',
            label: cat['label']?.toString() ?? 'Diğer',
            currentValue: _safeToDouble(cat['current_value']),
            percentage: _safeToDouble(cat['percentage']),
          ));
        }
      }

      print('📊 TOPLAM ASSET SAYISI: ${assetsList.length}');
      print('📊 CATEGORY SAYISI: ${categoryList.length}');

      emit(HomeLoaded(
        portfolioId: data['portfolio_id'] ?? 0,
        totalValue: _safeToDouble(data['total_current_value']),
        totalProfitLoss: _safeToDouble(data['total_profit_loss']),
        totalPnLPercent: _safeToDouble(data['total_pnl_percent']),
        assets: assetsList,
        categoryDistribution: categoryList,
      ));

    } catch (e, stack) {
      print('❌ ERROR: $e');
      print('❌ STACK: $stack');

      if (e.toString().contains('Token') || e.toString().contains('token')) {
        print('⚠️ Token hatası, empty state döndürülüyor');
        emit(const HomeEmpty());
      } else {
        emit(HomeError("Veriler işlenirken hata oluştu: ${e.toString()}"));
      }
    }
  }

  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  int _safeToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}