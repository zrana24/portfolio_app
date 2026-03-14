import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../app/apiUrl.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse(ApiUrls.getProfile),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      throw responseData['message'] ?? 'Profil bilgileri alınamadı.';
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String name,
    required String phone,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiUrls.updateProfile),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['_method'] = 'PUT';
    request.fields['name'] = name;
    request.fields['phone'] = phone;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else if (response.statusCode == 422) {
      final errors = responseData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw errors.values.first[0];
      }
      throw responseData['message'] ?? 'Profil güncellenemedi.';
    } else {
      throw responseData['message'] ?? 'Sunucu hatası oluştu.';
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiUrls.changePassword),
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['current_password'] = currentPassword;
    request.fields['password'] = newPassword;
    request.fields['password_confirmation'] = confirmPassword;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else if (response.statusCode == 422) {
      final errors = responseData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw errors.values.first[0];
      }
      throw responseData['message'] ?? 'Şifre değiştirilemedi.';
    } else {
      throw responseData['message'] ?? 'Sunucu hatası oluştu.';
    }
  }

  Future<Map<String, dynamic>> deleteAccount({
    required String token,
    required String password,
    required String confirmation,
  }) async {
    final response = await http.delete(
      Uri.parse(ApiUrls.deleteAccount),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'password': password,
        'confirmation': confirmation,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else if (response.statusCode == 422) {
      final errors = responseData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw errors.values.first[0];
      }
      throw responseData['message'] ?? 'Hesap silinemedi.';
    } else if (response.statusCode == 403) {
      throw responseData['message'] ?? 'Şifre yanlış veya onay kodu hatalı.';
    } else {
      throw responseData['message'] ?? 'Sunucu hatası oluştu.';
    }
  }
}