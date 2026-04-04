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
    // Beyaz ekran kalmaması için state'i hemen loading'e çekiyoruz
    emit(const HomeLoading());

    try {
      // ✅ TOKEN KONTROLÜ - Token yoksa API çağrısı yapma
      final isLoggedIn = await AuthService().isLoggedIn();
      if (!isLoggedIn) {
        emit(const HomeEmpty());
        return;
      }

      // Token varsa özet ve grafik verilerini paralel çek
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

      // Grafik verilerini sembol bazlı eşleştirmek için bir map oluştur
      final Map<String, dynamic> symbolCharts = {};
      for (var chartItem in chartDataList) {
        if (chartItem['symbol'] != null) {
          symbolCharts[chartItem['symbol']] = chartItem;
        }
      }

      final List<AssetItem> assetsList = [];
      if (data['all_assets'] != null && data['all_assets'] is List) {
        for (var item in data['all_assets']) {
          print('🔍 ASSET KEYS DEBUG: ${item.keys.toList()}');
          print('🔍 ASSET DATA DEBUG: $item');
          final symbol = item['symbol']?.toString() ?? '';
          
          // ID'yi sırasıyla kontrol et: id, portfolio_asset_id, asset_id
          final assetId = item['id'] ?? item['portfolio_asset_id'] ?? item['asset_id'] ?? 0;
          
          assetsList.add(AssetItem(
            id: _safeToInt(assetId),
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
            chartData: symbolCharts[symbol], // Eşleşen grafik verisini ekle
          ));
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

      emit(HomeLoaded(
        portfolioId: data['portfolio_id'] ?? 0,
        totalValue: _safeToDouble(data['total_current_value']),
        totalProfitLoss: _safeToDouble(data['total_profit_loss']),
        totalPnLPercent: _safeToDouble(data['total_pnl_percent']),
        assets: assetsList,
        categoryDistribution: categoryList,
      ));

    } catch (e, stack) {
      print('DEBUG ERROR: $e');
      print('DEBUG STACK: $stack');

      // Token hatası ise empty state döndür
      if (e.toString().contains('Token') || e.toString().contains('token')) {
        print('DEBUG: Token hatası, empty state döndürülüyor');
        emit(const HomeEmpty());
      } else {
        // Diğer hatalar için error state
        emit(HomeError("Veriler işlenirken hata oluştu: ${e.toString()}"));
      }
    }
  }

  // ✅ En Güvenli Double Dönüştürücü
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