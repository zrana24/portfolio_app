class PriceItem {
  final String symbol;
  final String? name;
  final double buy;
  final double sell;
  final double high;
  final double low;
  final double changePct;
  final int timestamp;

  const PriceItem({
    required this.symbol,
    this.name,
    required this.buy,
    required this.sell,
    required this.high,
    required this.low,
    required this.changePct,
    required this.timestamp,
  });

  factory PriceItem.fromJson(Map<String, dynamic> json) {
    return PriceItem(
      symbol: json['symbol'] ?? '',
      name: json['name'],
      buy: (json['bid'] ?? 0).toDouble(),
      sell: (json['ask'] ?? 0).toDouble(),
      high: (json['high'] ?? 0).toDouble(),
      low: (json['low'] ?? 0).toDouble(),
      changePct: (json['change_percent'] ?? 0).toDouble(),
      timestamp: json['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'bid': buy,
      'ask': sell,
      'high': high,
      'low': low,
      'change_percent': changePct,
      'timestamp': timestamp,
    };
  }

  bool get isPositive => changePct >= 0;

  PriceItem copyWith({
    String? symbol,
    String? name,
    double? buy,
    double? sell,
    double? high,
    double? low,
    double? changePct,
    int? timestamp,
  }) {
    return PriceItem(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      buy: buy ?? this.buy,
      sell: sell ?? this.sell,
      high: high ?? this.high,
      low: low ?? this.low,
      changePct: changePct ?? this.changePct,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PriceItem &&
              runtimeType == other.runtimeType &&
              symbol == other.symbol;

  @override
  int get hashCode => symbol.hashCode;

  @override
  String toString() {
    return 'PriceItem(symbol: $symbol, name: $name, buy: $buy, sell: $sell, changePct: $changePct%)';
  }
}