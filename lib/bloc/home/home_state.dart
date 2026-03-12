abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeEmpty extends HomeState {}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

class HomeLoaded extends HomeState {
  final double totalValue;
  final double percentage;
  final double dailyChange;
  final double dailyChangePct;
  final List<PortfolioItem> portfolios;

  HomeLoaded({
    required this.totalValue,
    required this.percentage,
    required this.dailyChange,
    required this.dailyChangePct,
    required this.portfolios,
  });
}

class PortfolioItem {
  final String name;
  final double value;
  final double dailyChange;
  final double dailyChangePct;

  PortfolioItem({
    required this.name,
    required this.value,
    required this.dailyChange,
    required this.dailyChangePct,
  });
}