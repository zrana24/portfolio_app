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
  final List<CategoryDistribution> categoryDistribution;

  HomeLoaded({
    required this.totalValue,
    required this.percentage,
    required this.dailyChange,
    required this.dailyChangePct,
    required this.portfolios,
    required this.categoryDistribution,
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

class CategoryDistribution {
  final String category;
  final String label;
  final double currentValue;
  final double percentage;

  CategoryDistribution({
    required this.category,
    required this.label,
    required this.currentValue,
    required this.percentage,
  });
}