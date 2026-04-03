import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../app/apiUrl.dart';

class HomeService {
  static const String baseUrl = ApiUrls.baseUrl;

  static Future<Map<String, dynamic>> getPortfolios() async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    print('============================================');
    print('📡 [getPortfolios] API ÇAĞRISI');
    print('============================================');
    print('URL: ${ApiUrls.portfolios}');
    print('Method: GET');
    print('Token: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    print('============================================');

    final response = await http.get(
      Uri.parse(ApiUrls.portfolios),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('📥 [getPortfolios] RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('============================================');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
    } else {
      throw Exception('Portföyler yüklenemedi: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getPortfolioSummary() async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    print('============================================');
    print('🚀 [getPortfolioSummary] BAŞLANGIÇ');
    print('============================================');

    try {
      // İlk önce portföy listesini al
      print('📡 [Step 1] Portföy listesi alınıyor...');
      print('URL: ${ApiUrls.portfolios}');

      final portfoliosResponse = await http.get(
        Uri.parse(ApiUrls.portfolios),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
        },
      );

      print('📥 [Step 1] Portföy Listesi Response');
      print('Status Code: ${portfoliosResponse.statusCode}');
      print('Response Body: ${portfoliosResponse.body}');
      print('--------------------------------------------');

      if (portfoliosResponse.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      }

      if (portfoliosResponse.statusCode != 200) {
        throw Exception('Portföyler yüklenemedi: ${portfoliosResponse.statusCode}');
      }

      final portfoliosData = json.decode(portfoliosResponse.body);

      if (portfoliosData['data'] == null ||
          (portfoliosData['data'] is List && portfoliosData['data'].isEmpty)) {
        print('⚠️ [getPortfolioSummary] Portföy bulunamadı, data null veya boş');
        print('============================================');
        return {'data': null};
      }

      // İlk portföyün detayını al
      final firstPortfolio = portfoliosData['data'][0];
      final portfolioId = firstPortfolio['portfolio_id'] ?? firstPortfolio['id'];

      print('📡 [Step 2] Portföy detayı alınıyor...');
      print('Portfolio ID: $portfolioId');
      print('Portfolio Name: ${firstPortfolio['name']}');
      print('URL: ${ApiUrls.portfolioDetail(portfolioId)}');

      final detailResponse = await http.get(
        Uri.parse(ApiUrls.portfolioDetail(portfolioId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
        },
      );

      print('📥 [Step 2] Portföy Detay Response');
      print('Status Code: ${detailResponse.statusCode}');
      print('Response Body: ${detailResponse.body}');
      print('============================================');

      if (detailResponse.statusCode == 200) {
        final responseData = json.decode(detailResponse.body);

        // Detaylı veri analizi
        if (responseData['data'] != null) {
          final data = responseData['data'];
          print('📊 [VERİ ANALİZİ]');
          print('  - Portfolio ID: ${data['portfolio_id']}');
          print('  - Name: ${data['name']}');
          print('  - Total Invested: ${data['total_invested']}');
          print('  - Total Current Value: ${data['total_current_value']}');
          print('  - Total Profit/Loss: ${data['total_profit_loss']}');
          print('  - Total PnL %: ${data['total_pnl_percent']}');
          print('  - Asset Count: ${data['asset_count']}');

          if (data['assets'] != null && data['assets'] is List) {
            print('  - Assets (${data['assets'].length} adet):');
            for (var asset in data['assets']) {
              print('      * ${asset['symbol']}: ${asset['quantity']} x ${asset['current_price']} = ${asset['current_value']} ₺');
              print('        PnL: ${asset['profit_loss']} (${asset['pnl_percent']}%)');
              print('        Daily Change: ${asset['daily_change']} (${asset['daily_change_percent']}%)');
            }
          }

          if (data['category_distribution'] != null && data['category_distribution'] is List) {
            print('  - Category Distribution:');
            for (var cat in data['category_distribution']) {
              print('      * ${cat['label']}: ${cat['percentage']}% (${cat['current_value']} ₺)');
            }
          }
          print('============================================');
        }

        return responseData;
      } else if (detailResponse.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Portföy detayı yüklenemedi: ${detailResponse.statusCode}');
      }
    } catch (e) {
      print('❌ [getPortfolioSummary] HATA: $e');
      print('============================================');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPortfolioDetail(int portfolioId) async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    print('============================================');
    print('📡 [getPortfolioDetail] API ÇAĞRISI');
    print('============================================');
    print('Portfolio ID: $portfolioId');
    print('URL: ${ApiUrls.portfolioDetail(portfolioId)}');
    print('Method: GET');
    print('Token: Bearer ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    print('============================================');

    final response = await http.get(
      Uri.parse(ApiUrls.portfolioDetail(portfolioId)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('📥 [getPortfolioDetail] RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('============================================');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // Detaylı veri analizi
      if (responseData['data'] != null) {
        final data = responseData['data'];
        print('📊 [VERİ ANALİZİ - getPortfolioDetail]');
        print('  - Portfolio ID: ${data['portfolio_id']}');
        print('  - Name: ${data['name']}');
        print('  - Total Value: ${data['total_current_value']}');
        print('  - Total PnL: ${data['total_profit_loss']}');
        print('  - Total PnL %: ${data['total_pnl_percent']}');
        print('============================================');
      }

      return responseData;
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
    } else if (response.statusCode == 404) {
      throw Exception('Portföy bulunamadı.');
    } else {
      throw Exception('Portföy detayı yüklenemedi: ${response.statusCode}');
    }
  }
}