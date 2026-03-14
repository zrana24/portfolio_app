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
          print('Timeout - 10 saniye içinde yanıt gelmedi');
          throw PriceServiceException('İstek zaman aşımına uğradı');
        },
      );

      print('HTTP Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('JSON decode başarılı');

        final dynamic data = jsonData['data'];

        if (data == null) {
          print('data field null');
          throw PriceServiceException('API yanıtında "data" alanı bulunamadı');
        }

        if (data is List) {
          print('Array formatında ${data.length} item bulundu');

          if (data.isEmpty) {
            print('Veri listesi boş! API henüz fiyat verisi döndürmuyor.');
            return [];
          }

          final symbols = await _fetchSymbols();
          print('${symbols.length} sembol bilgisi çekildi');

          final List<PriceItem> items = [];

          for (var priceData in data) {
            try {
              final symbol = priceData['symbol'] ?? '';
              if (symbol.isEmpty) continue;

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
              print('Item parse edilemedi: $e');
            }
          }

          print('${items.length} fiyat başarıyla parse edildi');
          return items;

        } else if (data is Map<String, dynamic>) {
          print('Map formatında ${data.length} fiyat bulundu');

          if (data.isEmpty) {
            print('Veri map\'i boş!');
            return [];
          }

          final symbols = await _fetchSymbols();
          print('${symbols.length} sembol bilgisi çekildi');

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
              print('$symbol parse edilemedi: $e');
            }
          });

          print('${items.length} fiyat başarıyla parse edildi');
          return items;

        } else {
          print('data field beklenmeyen tipte: ${data.runtimeType}');
          throw PriceServiceException('API yanıtı beklenmeyen formatta');
        }

      } else if (response.statusCode == 429) {
        print('Rate limit aşıldı');
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        print('HTTP ${response.statusCode} hatası');
        print('Response: ${response.body}');
        throw PriceServiceException(
          'Fiyatlar yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('Network hatası: ${e.message}');
      print('Uri: ${e.uri}');
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } on FormatException catch (e) {
      print('JSON parse hatası: $e');
      throw PriceServiceException('Veri formatı hatalı');
    } catch (e) {
      print('Beklenmeyen hata: $e');
      print('Hata tipi: ${e.runtimeType}');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<PriceItem> fetchPriceBySymbol(String symbol) async {
    print('fetchPriceBySymbol başladı: $symbol');

    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.priceDetail(symbol)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('HTTP Status: ${response.statusCode}');

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
        print(' Sembol bulunamadı: $symbol');
        throw PriceServiceException('Sembol bulunamadı: $symbol');
      } else if (response.statusCode == 429) {
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        throw PriceServiceException(
          'Fiyat yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('Bağlantı hatası: ${e.message}');
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } catch (e) {
      print('Beklenmeyen hata: $e');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchSymbols() async {
    print('_fetchSymbols başladı');

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
          print('Symbols timeout - devam ediliyor');
          return http.Response('{"data": []}', 200);
        },
      );

      print('Symbols HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List symbolsList = jsonData['data'] as List? ?? [];

        final Map<String, dynamic> symbolsMap = {};
        for (var item in symbolsList) {
          if (item is Map && item['symbol'] != null) {
            symbolsMap[item['symbol']] = {
              'name': item['name'],
              'category': item['category'],
              'has_price': item['has_price'],
            };
          }
        }

        print('${symbolsMap.length} sembol bilgisi alındı');
        return symbolsMap;
      } else {
        print('Symbols alınamadı, boş map dönüyor');
        return {};
      }
    } catch (e) {
      print('Symbols hatası$e');
      return {};
    }
  }

  void dispose() {
    print('dispose edildi');
    _client.close();
  }
}

class PriceServiceException implements Exception {
  final String message;

  PriceServiceException(this.message);

  @override
  String toString() => message;
}