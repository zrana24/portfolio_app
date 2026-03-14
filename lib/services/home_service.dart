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

    final response = await http.get(
      Uri.parse(ApiUrls.portfolios),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

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
      final response = await http.get(
        Uri.parse(ApiUrls.portfolioSummary),
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

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
      } else {
        throw Exception('Özet bilgiler yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPortfolioDetail(int portfolioId) async {
    final token = await TokenService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token bulunamadı. Lütfen giriş yapın.');
    }

    final response = await http.get(
      Uri.parse(ApiUrls.portfolioDetail(portfolioId)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Oturum süresi dolmuş. Lütfen tekrar giriş yapın.');
    } else if (response.statusCode == 404) {
      throw Exception('Portföy bulunamadı.');
    } else {
      throw Exception('Portföy detayı yüklenemedi: ${response.statusCode}');
    }
  }
}