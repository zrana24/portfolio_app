import '../../services/portfolio_services.dart';

abstract class AddAssetState {}

class AddAssetInitial extends AddAssetState {}

class AddAssetLoading extends AddAssetState {}

class AddAssetLoaded extends AddAssetState {
  final String symbol;
  final String name;
  final double currentPrice;
  final double askPrice;
  final double dailyChange;
  final List<Portfolio> portfolios;
  final Portfolio selectedPortfolio;
  final PriceHistory priceHistory;
  final double quantity;
  final double purchasePrice;
  final String notes;

  AddAssetLoaded({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.askPrice,
    required this.dailyChange,
    required this.portfolios,
    required this.selectedPortfolio,
    required this.priceHistory,
    required this.quantity,
    required this.purchasePrice,
    required this.notes,
  });

  double get totalCost => quantity * purchasePrice;

  AddAssetLoaded copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? askPrice,
    double? dailyChange,
    List<Portfolio>? portfolios,
    Portfolio? selectedPortfolio,
    PriceHistory? priceHistory,
    double? quantity,
    double? purchasePrice,
    String? notes,
  }) {
    return AddAssetLoaded(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      askPrice: askPrice ?? this.askPrice,
      dailyChange: dailyChange ?? this.dailyChange,
      portfolios: portfolios ?? this.portfolios,
      selectedPortfolio: selectedPortfolio ?? this.selectedPortfolio,
      priceHistory: priceHistory ?? this.priceHistory,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      notes: notes ?? this.notes,
    );
  }
}

class AddAssetSaving extends AddAssetState {}

class AddAssetSuccess extends AddAssetState {}

class AddAssetError extends AddAssetState {
  final String message;

  AddAssetError({required this.message});
}