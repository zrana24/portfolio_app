import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';
import '../../app/apiUrl.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const Duration _timeout = Duration(seconds: 10);

  Future<bool> isLoggedIn() async {
    final token = await TokenService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await TokenService.getToken();
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String deviceName = "Mobile Device",
  }) async {
    try {
      final response = await http
          .post(
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
      )
          .timeout(
        _timeout,
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else if (response.statusCode == 401) {
        throw responseData['message'] ?? 'Email veya şifre hatalı.';
      } else if (response.statusCode == 422) {
        final errors = responseData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw errors.values.first[0];
        }
        throw responseData['message'] ?? 'Giriş bilgileri hatalı.';
      } else {
        throw responseData['message'] ?? 'Giriş yapılamadı.';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw 'İnternet bağlantınızı kontrol edin.';
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .post(
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
      )
          .timeout(
        _timeout,
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.');
        },
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
      } else if (response.statusCode == 409) {
        throw 'Bu email adresi zaten kullanılıyor.';
      } else {
        throw responseData['message'] ?? 'Sunucu hatası oluştu.';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw 'İnternet bağlantınızı kontrol edin.';
      }
      rethrow;
    }
  }

  Future<void> logout(String token) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiUrls.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(
        _timeout,
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı.');
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final responseData = jsonDecode(response.body);
        throw responseData['message'] ?? 'Çıkış yapılırken bir hata oluştu.';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw 'İnternet bağlantınızı kontrol edin.';
      }
      rethrow;
    }
  }

  Future<void> deleteAccount({
    required String token,
    required String password,
  }) async {
    try {
      final response = await http
          .delete(
        Uri.parse(ApiUrls.deleteAccount),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'password': password,
          'confirmation': 'DELETE',
        }),
      )
          .timeout(
        _timeout,
        onTimeout: () {
          throw Exception('İstek zaman aşımına uğradı.');
        },
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw 'Şifre hatalı.';
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw errors.values.first[0];
        }
        throw responseData['message'] ?? 'Hesap silinirken bir hata oluştu.';
      } else {
        final responseData = jsonDecode(response.body);
        throw responseData['message'] ?? 'Hesap silinirken bir hata oluştu.';
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw 'İnternet bağlantınızı kontrol edin.';
      }
      rethrow;
    }
  }
}