import 'dart:convert';
import 'package:http/http.dart' as http;
import '../app/apiUrl.dart';

class CommodityService {
  final http.Client _client;

  CommodityService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 10);

  Future<List<CommodityItem>> fetchCommodities() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.commodities),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        _timeout,
        onTimeout: () {
          throw CommodityServiceException('İstek zaman aşımına uğradı');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List data = jsonData['data'] as List? ?? [];

        if (data.isEmpty) {
          return [];
        }

        final List<CommodityItem> items = [];

        for (var item in data) {
          try {
            items.add(CommodityItem.fromJson(item));
          } catch (e) {
            print('Commodity parse hatası: $e');
            continue;
          }
        }

        return items;
      } else if (response.statusCode == 429) {
        throw CommodityServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        throw CommodityServiceException(
          'Veriler yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw CommodityServiceException('Bağlantı hatası: ${e.message}');
    } on FormatException catch (e) {
      print('JSON PARSE HATASI: $e');
      throw CommodityServiceException('Veri formatı hatalı');
    } catch (e) {
      if (e is CommodityServiceException) rethrow;
      throw CommodityServiceException('Beklenmeyen hata: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class CommodityItem {
  final String symbol;
  final String name;
  final String category;
  final double bid;
  final double ask;
  final double dailyChange;
  final double dailyChangePercent;

  CommodityItem({
    required this.symbol,
    required this.name,
    required this.category,
    required this.bid,
    required this.ask,
    required this.dailyChange,
    required this.dailyChangePercent,
  });

  factory CommodityItem.fromJson(Map<String, dynamic> json) {
    return CommodityItem(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      bid: (json['bid'] ?? 0).toDouble(),
      ask: (json['ask'] ?? 0).toDouble(),
      dailyChange: (json['daily_change'] ?? 0).toDouble(),
      dailyChangePercent: (json['daily_change_percent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'category': category,
      'bid': bid,
      'ask': ask,
      'daily_change': dailyChange,
      'daily_change_percent': dailyChangePercent,
    };
  }
}

class CommodityServiceException implements Exception {
  final String message;

  CommodityServiceException(this.message);

  @override
  String toString() => message;
}