import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object?> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object?> get props => [];
}

class HomeEmpty extends HomeState {
  const HomeEmpty();

  @override
  List<Object?> get props => [];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class HomeLoaded extends HomeState {
  final int portfolioId;
  final double totalValue;
  final double totalProfitLoss;
  final double totalPnLPercent;
  final List<AssetItem> assets;
  final List<CategoryDistribution> categoryDistribution;
  final Map<String, dynamic>? totalChartData; // Opsiyonel: Gelecekte toplam grafik için

  const HomeLoaded({
    required this.portfolioId,
    required this.totalValue,
    required this.totalProfitLoss,
    required this.totalPnLPercent,
    required this.assets,
    required this.categoryDistribution,
    this.totalChartData,
  });

  @override
  List<Object?> get props => [
    portfolioId,
    totalValue,
    totalProfitLoss,
    totalPnLPercent,
    assets,
    categoryDistribution,
    totalChartData,
  ];
}

// Varlık modeli
class AssetItem {
  final int id;
  final int portfolioId; // Yeni: Hangi portföye ait olduğu
  final String? portfolioName; // Yeni: Portföy adı
  final String symbol;
  final String name;
  final double quantity;
  final double purchasePrice;
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
  final double pnlPercent;
  final Map<String, dynamic>? chartData;

  const AssetItem({
    required this.id,
    required this.portfolioId,
    this.portfolioName,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    required this.pnlPercent,
    this.chartData,
  });
}

// Kategori dağılım modeli
class CategoryDistribution {
  final String category;
  final String label;
  final double currentValue;
  final double percentage;

  const CategoryDistribution({
    required this.category,
    required this.label,
    required this.currentValue,
    required this.percentage,
  });
}