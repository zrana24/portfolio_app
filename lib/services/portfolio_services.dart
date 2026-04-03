import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/apiUrl.dart';
import 'token_service.dart';

class PortfolioService {
  final http.Client _client;

  PortfolioService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Portfolio>> getPortfolios() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw PortfolioServiceException('Token bulunamadı');
      }

      final response = await _client.get(
        Uri.parse(ApiUrls.portfolios),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'] as List? ?? [];

        return data.map((item) => Portfolio.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw PortfolioServiceException('Giriş yapmanız gerekiyor');
      } else {
        throw PortfolioServiceException('Portföyler yüklenemedi');
      }
    } catch (e) {
      if (e is PortfolioServiceException) rethrow;
      throw PortfolioServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<Portfolio> createPortfolio({
    required String name,
    String? description,
    String currency = 'TRY',
    bool isDefault = false,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw PortfolioServiceException('Token bulunamadı');
      }

      final response = await _client.post(
        Uri.parse(ApiUrls.portfolios),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          if (description != null) 'description': description,
          'currency': currency,
          'is_default': isDefault,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Portfolio.fromJson(jsonData['data']);
      } else if (response.statusCode == 422) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw errors.values.first[0];
        }
        throw PortfolioServiceException('Portföy oluşturulamadı');
      } else {
        throw PortfolioServiceException('Portföy oluşturulamadı');
      }
    } catch (e) {
      if (e is PortfolioServiceException) rethrow;
      throw PortfolioServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<void> addAssetToPortfolio({
    required int portfolioId,
    required String symbol,
    required double quantity,
    required double purchasePrice,
    String? purchaseDate,
    String? notes,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw PortfolioServiceException('Token bulunamadı');
      }

      final response = await _client.post(
        Uri.parse(ApiUrls.portfolioAssets(portfolioId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'symbol': symbol,
          'quantity': quantity,
          'purchase_price': purchasePrice,
          if (purchaseDate != null) 'purchase_date': purchaseDate,
          if (notes != null) 'notes': notes,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 201) {
        return;
      } else if (response.statusCode == 422) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw errors.values.first[0];
        }
        throw PortfolioServiceException('Varlık eklenemedi');
      } else if (response.statusCode == 404) {
        throw PortfolioServiceException('Portföy bulunamadı');
      } else {
        throw PortfolioServiceException('Varlık eklenemedi');
      }
    } catch (e) {
      if (e is PortfolioServiceException) rethrow;
      throw PortfolioServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<PriceHistory> getPriceHistory({
    required String symbol,
    String period = '1d',
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiUrls.priceHistory(symbol)}?period=$period'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return PriceHistory.fromJson(jsonData['data']);
      } else {
        throw PortfolioServiceException('Fiyat geçmişi yüklenemedi');
      }
    } catch (e) {
      if (e is PortfolioServiceException) rethrow;
      throw PortfolioServiceException('Beklenmeyen hata: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class Portfolio {
  final int id;
  final String name;
  final String? description;
  final String currency;
  final bool isDefault;

  Portfolio({
    required this.id,
    required this.name,
    this.description,
    required this.currency,
    required this.isDefault,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] ?? json['portfolio_id'],
      name: json['name'] ?? '',
      description: json['description'],
      currency: json['currency'] ?? 'TRY',
      isDefault: json['is_default'] ?? false,
    );
  }
}

class PriceHistory {
  final String symbol;
  final String period;
  final ChartData chart;
  final List<PricePoint> points;

  PriceHistory({
    required this.symbol,
    required this.period,
    required this.chart,
    required this.points,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      symbol: json['symbol'] ?? '',
      period: json['period'] ?? '1d',
      chart: ChartData.fromJson(json['chart'] ?? {}),
      points: (json['points'] as List?)
          ?.map((p) => PricePoint.fromJson(p))
          .toList() ??
          [],
    );
  }
}

class ChartData {
  final List<String> labels;
  final List<double> data;

  ChartData({
    required this.labels,
    required this.data,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    final datasets = json['datasets'] as List? ?? [];
    final firstDataset = datasets.isNotEmpty ? datasets[0] : {};

    return ChartData(
      labels: (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      data: (firstDataset['data'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
    );
  }
}

class PricePoint {
  final String time;
  final double ask;
  final double bid;

  PricePoint({
    required this.time,
    required this.ask,
    required this.bid,
  });

  factory PricePoint.fromJson(Map<String, dynamic> json) {
    return PricePoint(
      time: json['time'] ?? '',
      ask: (json['ask'] ?? 0).toDouble(),
      bid: (json['bid'] ?? 0).toDouble(),
    );
  }
}

class PortfolioServiceException implements Exception {
  final String message;

  PortfolioServiceException(this.message);

  @override
  String toString() => message;
}