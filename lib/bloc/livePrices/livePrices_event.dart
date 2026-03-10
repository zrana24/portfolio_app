import 'package:equatable/equatable.dart';

enum ViewMode { list, table }

class PriceItem {
  final String code;
  final String name;
  final double buy;
  final double sell;
  final double changePct;

  const PriceItem({
    required this.code,
    required this.name,
    required this.buy,
    required this.sell,
    required this.changePct,
  });

  bool get isPositive => changePct >= 0;

  PriceItem copyWith({
    double? buy,
    double? sell,
    double? changePct,
  }) {
    return PriceItem(
      code: code,
      name: name,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      changePct: changePct ?? this.changePct,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PriceItem && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}


abstract class LivePricesEvent extends Equatable {
  const LivePricesEvent();

  @override
  List<Object?> get props => [];
}

class LoadLivePrices extends LivePricesEvent {
  const LoadLivePrices();
}

class RefreshLivePrices extends LivePricesEvent {
  const RefreshLivePrices();
}

class LivePriceUpdated extends LivePricesEvent {
  final PriceItem updatedItem;

  const LivePriceUpdated(this.updatedItem);

  @override
  List<Object?> get props => [updatedItem];
}

class ToggleViewMode extends LivePricesEvent {
  const ToggleViewMode();
}

class SetViewMode extends LivePricesEvent {
  final ViewMode mode;

  const SetViewMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SearchPrices extends LivePricesEvent {
  final String query;

  const SearchPrices(this.query);

  @override
  List<Object?> get props => [query];
}

class ClockTicked extends LivePricesEvent {
  final DateTime time;

  const ClockTicked(this.time);

  @override
  List<Object?> get props => [time];
}