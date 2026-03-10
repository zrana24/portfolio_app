import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/apiUrl.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String deviceName = "Mobile Device",
  }) async {
    final response = await http.post(
      Uri.parse(ApiUrls.login),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': deviceName,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    }
    else {
      throw responseData['message'] ?? 'Giriş yapılamadı.';
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse(ApiUrls.register),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': confirmPassword,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return responseData;
    } else if (response.statusCode == 422) {
      final errors = responseData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw errors.values.first[0];
      }
      throw responseData['message'] ?? 'Kayıt başarısız.';
    }
    else {
      throw responseData['message'] ?? 'Sunucu hatası oluştu.';
    }
  }

  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse(ApiUrls.logout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw 'Çıkış yapılırken bir hata oluştu.';
    }
  }
}