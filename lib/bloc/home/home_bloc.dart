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
        final data = summaryResponse['data'];

        if (data['portfolio_count'] == 0 || data['total_assets'] == 0) {
          emit(HomeEmpty());
          return;
        }

        final List<PortfolioItem> portfolioItems = [];

        if (data['portfolios'] != null) {
          for (var portfolio in data['portfolios']) {
            portfolioItems.add(PortfolioItem(
              name: portfolio['name'] ?? 'Portföy',
              value: (portfolio['current_value'] ?? 0.0).toDouble(),
              dailyChange: (portfolio['profit_loss'] ?? 0.0).toDouble(),
              dailyChangePct: (portfolio['pnl_percent'] ?? 0.0).toDouble(),
            ));
          }
        }

        emit(HomeLoaded(
          totalValue: (data['total_current_value'] ?? 0.0).toDouble(),
          percentage: (data['total_pnl_percent'] ?? 0.0).toDouble(),
          dailyChange: (data['total_profit_loss'] ?? 0.0).toDouble(),
          dailyChangePct: (data['total_pnl_percent'] ?? 0.0).toDouble(),
          portfolios: portfolioItems,
        ));
      }
      catch (e) {
        String errorMessage = 'Bir hata oluştu. Lütfen daha sonra tekrar deneyin.';

        if (e.toString().contains('Token bulunamadı')) {
          errorMessage = 'Oturum açmanız gerekiyor. Lütfen giriş yapın.';
        }
        else if (e.toString().contains('Oturum süresi dolmuş')) {
          errorMessage = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
        }
        else if (e.toString().contains('SocketException') ||
            e.toString().contains('Failed host lookup')) {
          errorMessage = 'İnternet bağlantınızı kontrol edin.';
        }

        print('Portföy yükleme hatası: $e');
        emit(HomeError(errorMessage));
      }
    });
  }
}