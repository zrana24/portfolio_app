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
  final int portfolioId;  // ← YENİ: Asset detail için gerekli
  final double totalValue;
  final double totalProfitLoss;
  final double totalPnLPercent;
  final List<AssetItem> assets;
  final List<CategoryDistribution> categoryDistribution;

  const HomeLoaded({
    required this.portfolioId,  // ← YENİ
    required this.totalValue,
    required this.totalProfitLoss,
    required this.totalPnLPercent,
    required this.assets,
    required this.categoryDistribution,
  });

  @override
  List<Object?> get props => [
    portfolioId,  // ← YENİ
    totalValue,
    totalProfitLoss,
    totalPnLPercent,
    assets,
    categoryDistribution,
  ];
}

// Varlık modeli
class AssetItem {
  final int id;  // ← YENİ: Asset detail için gerekli
  final String symbol;
  final String name;
  final double quantity;
  final double purchasePrice;  // ← YENİ: Asset detail için gerekli
  final double currentPrice;
  final double currentValue;
  final double profitLoss;
  final double pnlPercent;

  const AssetItem({
    required this.id,  // ← YENİ
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,  // ← YENİ
    required this.currentPrice,
    required this.currentValue,
    required this.profitLoss,
    required this.pnlPercent,
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