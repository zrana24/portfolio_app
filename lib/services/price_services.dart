import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_item.dart';
import '../app/apiUrl.dart';

class PriceService {
  final http.Client _client;

  PriceService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PriceItem>> fetchAllPrices() async {

    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.prices),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw PriceServiceException('İstek zaman aşımına uğradı');
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final dynamic data = jsonData['data'];

        if (data == null) {
          throw PriceServiceException('API yanıtında "data" alanı bulunamadı');
        }

        if (data is List) {

          if (data.isEmpty) {
            print('VERİ LİSTESİ BOŞ!');
            return [];
          }


          for (int i = 0; i < data.length; i++) {
            print('\n  ┌─ Item #${i + 1}:');
            print('  │  Raw Data: ${data[i]}');
            print('  │  Type: ${data[i].runtimeType}');
            if (data[i] is Map) {
              print('  │  Keys: ${(data[i] as Map).keys.toList()}');
              print('  │  Values:');
              (data[i] as Map).forEach((key, value) {
                print('  │    • $key: $value (${value.runtimeType})');
              });
            }
          }

          final symbols = await _fetchSymbols();

          final List<PriceItem> items = [];

          for (var i = 0; i < data.length; i++) {
            var priceData = data[i];
            try {
              final symbol = priceData['symbol'] ?? '';
              if (symbol.isEmpty) {
                continue;
              }

              final symbolInfo = symbols[symbol];

              final item = PriceItem(
                symbol: symbol,
                name: symbolInfo?['name'] ?? priceData['name'] ?? symbol,
                buy: (priceData['bid'] ?? 0).toDouble(),
                sell: (priceData['ask'] ?? 0).toDouble(),
                high: (priceData['high'] ?? 0).toDouble(),
                low: (priceData['low'] ?? 0).toDouble(),
                changePct: (priceData['change_percent'] ?? 0).toDouble(),
                timestamp: priceData['timestamp'] ?? 0,
              );

              items.add(item);
            } catch (e) {
              print('   Stack trace: ${StackTrace.current}');
            }
          }

          return items;

        } else if (data is Map<String, dynamic>) {
          if (data.isEmpty) {
            print('VERİ MAP\'İ BOŞ!');
            return [];
          }

          data.forEach((key, value) {
            if (value is Map) {
              print('  │  Fields:');
              value.forEach((k, v) {
                print('  │    • $k: $v (${v.runtimeType})');
              });
            }
          });

          final symbols = await _fetchSymbols();

          final List<PriceItem> items = [];

          data.forEach((symbol, priceData) {
            try {
              final symbolInfo = symbols[symbol];

              final item = PriceItem(
                symbol: symbol,
                name: symbolInfo?['name'] ?? symbol,
                buy: (priceData['bid'] ?? 0).toDouble(),
                sell: (priceData['ask'] ?? 0).toDouble(),
                high: (priceData['high'] ?? 0).toDouble(),
                low: (priceData['low'] ?? 0).toDouble(),
                changePct: (priceData['change_percent'] ?? 0).toDouble(),
                timestamp: priceData['timestamp'] ?? 0,
              );

              items.add(item);
            } catch (e) {
              print('$symbol parse hatası: $e');
            }
          });

          return items;

        } else {
          throw PriceServiceException('API yanıtı beklenmeyen formatta');
        }

      } else if (response.statusCode == 429) {
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        print('Response Body: ${response.body}');
        throw PriceServiceException(
          'Fiyatlar yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } on FormatException catch (e) {
      print('JSON PARSE HATASI: $e');
      throw PriceServiceException('Veri formatı hatalı');
    }
    catch (e) {
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchSymbols() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.symbols),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          return http.Response('{"data": []}', 200);
        },
      );
      print(response.body);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List symbolsList = jsonData['data'] as List? ?? [];

        final Map<String, dynamic> symbolsMap = {};
        for (var i = 0; i < symbolsList.length; i++) {
          var item = symbolsList[i];
          if (item is Map && item['symbol'] != null) {
            symbolsMap[item['symbol']] = {
              'name': item['name'],
              'category': item['category'],
              'has_price': item['has_price'],
            };

          }
        }

        return symbolsMap;
      } else {
        return {};
      }
    } catch (e) {
      print('SYMBOLS HATASI: $e');
      return {};
    }
  }

  Future<PriceItem> fetchPriceBySymbol(String symbol) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.priceDetail(symbol)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final priceData = jsonData['data'];

        return PriceItem(
          symbol: priceData['symbol'] ?? symbol,
          name: null,
          buy: (priceData['bid'] ?? 0).toDouble(),
          sell: (priceData['ask'] ?? 0).toDouble(),
          high: (priceData['high'] ?? 0).toDouble(),
          low: (priceData['low'] ?? 0).toDouble(),
          changePct: (priceData['change_percent'] ?? 0).toDouble(),
          timestamp: priceData['timestamp'] ?? 0,
        );
      } else if (response.statusCode == 404) {
        throw PriceServiceException('Sembol bulunamadı: $symbol');
      } else if (response.statusCode == 429) {
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        throw PriceServiceException(
          'Fiyat yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('HATA: $e');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}

class PriceServiceException implements Exception {
  final String message;

  PriceServiceException(this.message);

  @override
  String toString() => message;
}