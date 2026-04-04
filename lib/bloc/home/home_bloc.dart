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
        print('DEBUG: Token yok, direkt empty state döndürülüyor');
        emit(const HomeEmpty());
        return;
      }

      // Token varsa API çağrısı yap
      final detailResponse = await HomeService.getPortfolioSummary();

      // Response kontrolü
      if (detailResponse == null || detailResponse['data'] == null) {
        print('DEBUG: API Response veya Data null geldi');
        emit(const HomeEmpty());
        return;
      }

      final data = detailResponse['data'];

      final List<AssetItem> assetsList = [];
      if (data['assets'] != null && data['assets'] is List) {
        for (var item in data['assets']) {
          assetsList.add(AssetItem(
            symbol: item['symbol']?.toString() ?? '---',
            name: item['name']?.toString() ?? item['symbol']?.toString() ?? 'Varlık',
            quantity: _safeToDouble(item['quantity']),
            currentPrice: _safeToDouble(item['current_price']),
            currentValue: _safeToDouble(item['current_value']),
            profitLoss: _safeToDouble(item['profit_loss']),
            pnlPercent: _safeToDouble(item['pnl_percent']),
          ));
        }
      }

      // ✅ KATEGORİLERİ İŞLE
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

      // Başarılı yükleme
      emit(HomeLoaded(
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
}