import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_item.dart';
import '../app/apiUrl.dart';

class PriceService {
  final http.Client _client;

  PriceService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PriceItem>> fetchAllPrices() async {
    print('🔵 [PriceService] fetchAllPrices başladı');
    print('🔵 [PriceService] URL: ${ApiUrls.prices}');

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
          print('❌ [PriceService] Timeout - 10 saniye içinde yanıt gelmedi');
          throw PriceServiceException('İstek zaman aşımına uğradı');
        },
      );

      print('🔵 [PriceService] HTTP Status: ${response.statusCode}');
      print('🔵 [PriceService] Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🔵 [PriceService] JSON decode başarılı');

        final dynamic data = jsonData['data'];

        if (data == null) {
          print('❌ [PriceService] data field null');
          throw PriceServiceException('API yanıtında "data" alanı bulunamadı');
        }

        if (data is List) {
          print('🔵 [PriceService] Array formatında ${data.length} item bulundu');

          if (data.isEmpty) {
            print('⚠️ [PriceService] Veri listesi boş! API henüz fiyat verisi döndürmuyor.');
            return [];
          }

          final symbols = await _fetchSymbols();
          print('🔵 [PriceService] ${symbols.length} sembol bilgisi çekildi');

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
              print('⚠️ [PriceService] Item parse edilemedi: $e');
            }
          }

          print('✅ [PriceService] ${items.length} fiyat başarıyla parse edildi');
          return items;

        } else if (data is Map<String, dynamic>) {
          print('🔵 [PriceService] Map formatında ${data.length} fiyat bulundu');

          if (data.isEmpty) {
            print('⚠️ [PriceService] Veri map\'i boş!');
            return [];
          }

          final symbols = await _fetchSymbols();
          print('🔵 [PriceService] ${symbols.length} sembol bilgisi çekildi');

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
              print('⚠️ [PriceService] $symbol parse edilemedi: $e');
            }
          });

          print('✅ [PriceService] ${items.length} fiyat başarıyla parse edildi');
          return items;

        } else {
          print('❌ [PriceService] data field beklenmeyen tipte: ${data.runtimeType}');
          throw PriceServiceException('API yanıtı beklenmeyen formatta');
        }

      } else if (response.statusCode == 429) {
        print('❌ [PriceService] Rate limit aşıldı');
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        print('❌ [PriceService] HTTP ${response.statusCode} hatası');
        print('❌ [PriceService] Response: ${response.body}');
        throw PriceServiceException(
          'Fiyatlar yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('❌ [PriceService] Network hatası: ${e.message}');
      print('❌ [PriceService] Uri: ${e.uri}');
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } on FormatException catch (e) {
      print('❌ [PriceService] JSON parse hatası: $e');
      throw PriceServiceException('Veri formatı hatalı');
    } catch (e) {
      print('❌ [PriceService] Beklenmeyen hata: $e');
      print('❌ [PriceService] Hata tipi: ${e.runtimeType}');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<PriceItem> fetchPriceBySymbol(String symbol) async {
    print('🔵 [PriceService] fetchPriceBySymbol başladı: $symbol');

    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.priceDetail(symbol)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔵 [PriceService] HTTP Status: ${response.statusCode}');

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
        print('❌ [PriceService] Sembol bulunamadı: $symbol');
        throw PriceServiceException('Sembol bulunamadı: $symbol');
      } else if (response.statusCode == 429) {
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        throw PriceServiceException(
          'Fiyat yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('❌ [PriceService] Bağlantı hatası: ${e.message}');
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } catch (e) {
      print('❌ [PriceService] Beklenmeyen hata: $e');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchSymbols() async {
    print('🔵 [PriceService] _fetchSymbols başladı');

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
          print('⚠️ [PriceService] Symbols timeout - devam ediliyor');
          return http.Response('{"data": []}', 200);
        },
      );

      print('🔵 [PriceService] Symbols HTTP Status: ${response.statusCode}');

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

        print('✅ [PriceService] ${symbolsMap.length} sembol bilgisi alındı');
        return symbolsMap;
      } else {
        print('⚠️ [PriceService] Symbols alınamadı, boş map dönüyor');
        return {};
      }
    } catch (e) {
      print('⚠️ [PriceService] Symbols hatası (görmezden geliniyor): $e');
      return {};
    }
  }

  void dispose() {
    print('🔵 [PriceService] dispose edildi');
    _client.close();
  }
}

class PriceServiceException implements Exception {
  final String message;

  PriceServiceException(this.message);

  @override
  String toString() => message;
}