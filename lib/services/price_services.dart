import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/price_item.dart';
import '../app/apiUrl.dart';

class PriceService {
  final http.Client _client;

  PriceService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<PriceItem>> fetchAllPrices() async {
    print('═══════════════════════════════════════════════════════════');
    print('🚀 fetchAllPrices BAŞLADI');
    print('═══════════════════════════════════════════════════════════');

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
          print('⏱️ TIMEOUT - 10 saniye içinde yanıt gelmedi');
          throw PriceServiceException('İstek zaman aşımına uğradı');
        },
      );

      print('\n📊 HTTP RESPONSE DETAYLARI:');
      print('├─ Status Code: ${response.statusCode}');
      print('├─ Content-Type: ${response.headers['content-type']}');
      print('├─ Content-Length: ${response.headers['content-length']}');
      print('└─ Response Body Length: ${response.body.length} karakter');

      print('\n📄 HAM RESPONSE BODY:');
      print('┌─────────────────────────────────────────────────────────');
      print(response.body);
      print('└─────────────────────────────────────────────────────────');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('\n✅ JSON DECODE BAŞARILI');

        print('\n🔍 JSON YAPISI:');
        print('├─ Type: ${jsonData.runtimeType}');
        print('├─ Keys: ${jsonData.keys.toList()}');
        print('└─ Full JSON:');
        print(JsonEncoder.withIndent('  ').convert(jsonData));

        final dynamic data = jsonData['data'];

        if (data == null) {
          print('\n❌ ERROR: data field null');
          throw PriceServiceException('API yanıtında "data" alanı bulunamadı');
        }

        print('\n📦 DATA FIELD DETAYLARI:');
        print('├─ Type: ${data.runtimeType}');

        if (data is List) {
          print('├─ Format: ARRAY');
          print('├─ Item Count: ${data.length}');
          print('└─ Array Items:');

          if (data.isEmpty) {
            print('\n⚠️ VERİ LİSTESİ BOŞ!');
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
            print('  └─────────────────────────────────────────────');
          }

          final symbols = await _fetchSymbols();
          print('\n📚 SEMBOL BİLGİLERİ ALINDI: ${symbols.length} adet');

          final List<PriceItem> items = [];

          for (var i = 0; i < data.length; i++) {
            var priceData = data[i];
            try {
              final symbol = priceData['symbol'] ?? '';
              if (symbol.isEmpty) {
                print('\n⚠️ Item #${i + 1} atlandı: symbol boş');
                continue;
              }

              final symbolInfo = symbols[symbol];

              print('\n🔨 PARSE EDİLİYOR - Item #${i + 1}:');
              print('├─ Symbol: $symbol');
              print('├─ Name (API): ${priceData['name']}');
              print('├─ Name (Symbols): ${symbolInfo?['name']}');
              print('├─ Bid (Alış): ${priceData['bid']}');
              print('├─ Ask (Satış): ${priceData['ask']}');
              print('├─ High: ${priceData['high']}');
              print('├─ Low: ${priceData['low']}');
              print('├─ Change %: ${priceData['change_percent']}');
              print('└─ Timestamp: ${priceData['timestamp']}');

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

              print('✅ PriceItem oluşturuldu:');
              print('   └─ ${item.symbol} - ${item.name}: Buy=${item.buy}, Sell=${item.sell}, Change=${item.changePct}%');

              items.add(item);
            } catch (e) {
              print('\n❌ Item #${i + 1} parse hatası: $e');
              print('   Stack trace: ${StackTrace.current}');
            }
          }

          print('\n✅ TOPLAM ${items.length} FİYAT BAŞARIYLA PARSE EDİLDİ');
          return items;

        } else if (data is Map<String, dynamic>) {
          print('├─ Format: MAP');
          print('├─ Item Count: ${data.length}');
          print('└─ Map Keys: ${data.keys.toList()}');

          if (data.isEmpty) {
            print('\n⚠️ VERİ MAP\'İ BOŞ!');
            return [];
          }


          data.forEach((key, value) {
            print('\n  ┌─ Key: $key');
            print('  │  Value: $value');
            print('  │  Type: ${value.runtimeType}');
            if (value is Map) {
              print('  │  Fields:');
              value.forEach((k, v) {
                print('  │    • $k: $v (${v.runtimeType})');
              });
            }
            print('  └─────────────────────────────────────────────');
          });

          final symbols = await _fetchSymbols();
          print('\n📚 SEMBOL BİLGİLERİ ALINDI: ${symbols.length} adet');

          final List<PriceItem> items = [];

          data.forEach((symbol, priceData) {
            try {
              final symbolInfo = symbols[symbol];

              print('\n🔨 PARSE EDİLİYOR - $symbol:');
              print('├─ Name (Symbols): ${symbolInfo?['name']}');
              print('├─ Bid (Alış): ${priceData['bid']}');
              print('├─ Ask (Satış): ${priceData['ask']}');
              print('├─ High: ${priceData['high']}');
              print('├─ Low: ${priceData['low']}');
              print('├─ Change %: ${priceData['change_percent']}');
              print('└─ Timestamp: ${priceData['timestamp']}');

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

              print('✅ PriceItem oluşturuldu: ${item.symbol} - ${item.name}');
              items.add(item);
            } catch (e) {
              print('\n❌ $symbol parse hatası: $e');
            }
          });

          print('\n✅ TOPLAM ${items.length} FİYAT BAŞARIYLA PARSE EDİLDİ');
          return items;

        } else {
          print('\n❌ BEKLENMEYEN VERİ TİPİ: ${data.runtimeType}');
          throw PriceServiceException('API yanıtı beklenmeyen formatta');
        }

      } else if (response.statusCode == 429) {
        print('\n⚠️ RATE LIMIT AŞILDI');
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        print('\n❌ HTTP HATASI: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw PriceServiceException(
          'Fiyatlar yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } on http.ClientException catch (e) {
      print('\n❌ NETWORK HATASI:');
      print('├─ Message: ${e.message}');
      print('└─ Uri: ${e.uri}');
      throw PriceServiceException('Bağlantı hatası: ${e.message}');
    } on FormatException catch (e) {
      print('\n❌ JSON PARSE HATASI: $e');
      throw PriceServiceException('Veri formatı hatalı');
    } catch (e) {
      print('\n❌ BEKLENMEYEN HATA:');
      print('├─ Error: $e');
      print('├─ Type: ${e.runtimeType}');
      print('└─ Stack: ${StackTrace.current}');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    } finally {
      print('\n═══════════════════════════════════════════════════════════');
      print('🏁 fetchAllPrices TAMAMLANDI');
      print('═══════════════════════════════════════════════════════════\n');
    }
  }

  Future<Map<String, dynamic>> _fetchSymbols() async {
    print('\n┌─────────────────────────────────────────────────────────');
    print('│ 📚 _fetchSymbols BAŞLADI');
    print('└─────────────────────────────────────────────────────────');

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
          print('⏱️ Symbols timeout - boş data ile devam ediliyor');
          return http.Response('{"data": []}', 200);
        },
      );

      print('\n📊 SYMBOLS HTTP RESPONSE:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body Length: ${response.body.length}');

      print('\n📄 SYMBOLS RAW RESPONSE:');
      print(response.body);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List symbolsList = jsonData['data'] as List? ?? [];

        print('\n✅ SYMBOLS PARSE BAŞARILI:');
        print('├─ Total Symbols: ${symbolsList.length}');

        final Map<String, dynamic> symbolsMap = {};
        for (var i = 0; i < symbolsList.length; i++) {
          var item = symbolsList[i];
          print('\n  Symbol #${i + 1}:');
          print('  ├─ Raw: $item');

          if (item is Map && item['symbol'] != null) {
            symbolsMap[item['symbol']] = {
              'name': item['name'],
              'category': item['category'],
              'has_price': item['has_price'],
            };
            print('  ├─ Symbol: ${item['symbol']}');
            print('  ├─ Name: ${item['name']}');
            print('  ├─ Category: ${item['category']}');
            print('  └─ Has Price: ${item['has_price']}');
          }
        }

        print('\n✅ ${symbolsMap.length} SEMBOL BİLGİSİ ALINDI');
        return symbolsMap;
      } else {
        print('\n⚠️ Symbols alınamadı (Status: ${response.statusCode}), boş map dönüyor');
        return {};
      }
    } catch (e) {
      print('\n❌ SYMBOLS HATASI: $e');
      return {};
    } finally {
      print('└─────────────────────────────────────────────────────────\n');
    }
  }

  Future<PriceItem> fetchPriceBySymbol(String symbol) async {
    print('\n═══════════════════════════════════════════════════════════');
    print('🔍 fetchPriceBySymbol BAŞLADI: $symbol');
    print('═══════════════════════════════════════════════════════════');

    try {
      final response = await _client.get(
        Uri.parse(ApiUrls.priceDetail(symbol)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('\n📊 HTTP Response Status: ${response.statusCode}');
      print('📄 Response Body:\n${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final priceData = jsonData['data'];

        print('\n✅ Parse edilen veri:');
        print('├─ Symbol: ${priceData['symbol']}');
        print('├─ Bid: ${priceData['bid']}');
        print('├─ Ask: ${priceData['ask']}');
        print('├─ High: ${priceData['high']}');
        print('├─ Low: ${priceData['low']}');
        print('├─ Change %: ${priceData['change_percent']}');
        print('└─ Timestamp: ${priceData['timestamp']}');

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
        print('\n❌ Sembol bulunamadı: $symbol');
        throw PriceServiceException('Sembol bulunamadı: $symbol');
      } else if (response.statusCode == 429) {
        throw PriceServiceException('Rate limit aşıldı. Lütfen bekleyin.');
      } else {
        throw PriceServiceException(
          'Fiyat yüklenemedi. HTTP ${response.statusCode}',
        );
      }
    } catch (e) {
      print('\n❌ HATA: $e');
      if (e is PriceServiceException) rethrow;
      throw PriceServiceException('Beklenmeyen hata: $e');
    } finally {
      print('═══════════════════════════════════════════════════════════\n');
    }
  }

  void dispose() {
    print('🗑️ PriceService dispose edildi');
    _client.close();
  }
}

class PriceServiceException implements Exception {
  final String message;

  PriceServiceException(this.message);

  @override
  String toString() => message;
}