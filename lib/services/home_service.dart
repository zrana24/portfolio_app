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

    try {
      print('📡 [getPortfolioSummary] Yeni mobil özet endpoint çağrılıyor...');
      print('URL: ${ApiUrls.mobilePortfolioSummary}');

      final response = await http.get(
        Uri.parse(ApiUrls.mobilePortfolioSummary),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Özet yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [getPortfolioSummary] HATA: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPortfolioChart({String period = '1d'}) async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    try {
      print('📡 [getPortfolioChart] Yeni mobil grafik endpoint çağrılıyor...');
      print('URL: ${ApiUrls.mobilePortfolioChart}?period=$period');

      final response = await http.get(
        Uri.parse('${ApiUrls.mobilePortfolioChart}?period=$period'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Grafik verisi yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [getPortfolioChart] HATA: $e');
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