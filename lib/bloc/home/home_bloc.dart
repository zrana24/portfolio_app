import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadHomeData>((event, emit) async {
      emit(HomeLoading());

      await Future.delayed(const Duration(seconds: 2));

      final List<PortfolioItem> mockPortfolios = [
        PortfolioItem(
          name: "EMTİA",
          value: 70198,
          dailyChange: -596,
          dailyChangePct: 0.8,
        ),
        PortfolioItem(
          name: "EMTİA",
          value: 70198,
          dailyChange: -596,
          dailyChangePct: 0.8,
        ),
        PortfolioItem(
          name: "Test",
          value: 70198,
          dailyChange: -596,
          dailyChangePct: 0.8,
        ),
      ];

      if (mockPortfolios.isEmpty) {
        emit(HomeEmpty());
      }
      else {
        emit(HomeLoaded(
          totalValue: 70584,
          percentage: 0.65,
          dailyChange: -596,
          dailyChangePct: 0.8,
          portfolios: mockPortfolios,
        ));
      }
    });
  }
}