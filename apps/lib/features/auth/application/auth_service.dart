import 'dart:async';
import 'package:cashier_app/data/remote/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _api;
  const AuthService(this._api);

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Malformed response');
      }
      return token;
    } on DioException catch (e) {
      final res = e.response;
      final code = res?.statusCode ?? 0;
      String serverMessage = '';
      final data = res?.data;
      if (data is Map && data['message'] is String) {
        serverMessage = data['message'] as String;
      } else if (data is Map && data['error'] is String) {
        serverMessage = data['error'] as String;
      }
      if (code == 401) throw AuthException('Invalid email or password');
      if (code == 429) throw AuthException('Too many attempts, try later');
      if (code >= 400 && code < 500) {
        throw AuthException(
          serverMessage.isNotEmpty ? serverMessage : 'Unable to sign in',
        );
      }
      if (code >= 500) throw AuthException('Server error, please try again');
      throw AuthException('Network error, please try again');
    } catch (_) {
      throw AuthException('Network error, please try again');
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
