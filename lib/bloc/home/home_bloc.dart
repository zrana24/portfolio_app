import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portfoy_app/services/home_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());

      try {
        final summaryResponse = await HomeService.getPortfolioSummary();

        if (summaryResponse['data'] == null) {
          emit(HomeEmpty());
          return;
        }

        final data = summaryResponse['data'];

        final portfolioCount = _toInt(data['portfolio_count']);
        final totalAssets = _toInt(data['total_assets']);

        if (portfolioCount == 0 || totalAssets == 0) {
          emit(HomeEmpty());
          return;
        }

        final List<PortfolioItem> portfolioItems = [];
        final List<CategoryDistribution> categoryDistribution = [];

        if (data['portfolios'] != null && data['portfolios'] is List) {
          for (var portfolio in data['portfolios']) {
            final item = PortfolioItem(
              name: portfolio['name']?.toString() ?? 'Portföy',
              value: _toDouble(portfolio['current_value']),
              dailyChange: _toDouble(portfolio['profit_loss']),
              dailyChangePct: _toDouble(portfolio['pnl_percent']),
            );
            portfolioItems.add(item);
          }
        }

        if (data['category_distribution'] != null &&
            data['category_distribution'] is List) {
          for (var category in data['category_distribution']) {
            final cat = CategoryDistribution(
              category: category['category']?.toString() ?? '',
              label: category['label']?.toString() ?? '',
              currentValue: _toDouble(category['current_value']),
              percentage: _toDouble(category['percentage']),
            );
            categoryDistribution.add(cat);
          }
        }

        final totalValue = _toDouble(data['total_current_value']);
        final totalPnL = _toDouble(data['total_profit_loss']);
        final totalPnLPercent = _toDouble(data['total_pnl_percent']);

        emit(HomeLoaded(
          totalValue: totalValue,
          percentage: totalPnLPercent,
          dailyChange: totalPnL,
          dailyChangePct: totalPnLPercent,
          portfolios: portfolioItems,
          categoryDistribution: categoryDistribution,
        ));

      } catch (e, stackTrace) {
        print('Portföy yükleme hatası: $e');

        if (e.toString().contains('Token bulunamadı')) {
          emit(HomeEmpty());
          return;
        }

        if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
          emit(HomeEmpty());
          return;
        }
        else if (e.toString().contains('401')) {
          emit(HomeEmpty());
          return;
        }
      }
    });
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}