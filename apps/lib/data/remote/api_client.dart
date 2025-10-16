import 'package:dio/dio.dart';
import 'package:cashier_app/services/token_storage.dart';

class ApiClient {
  final Dio dio;
  ApiClient(this.dio);

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    return dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) async {
    return dio.post<T>(path, data: data);
  }
}

ApiClient buildApiClient({
  String? token,
  String baseUrl = 'https://api.example.com',
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.clear();
  final storage = TokenStorage();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? t = token;
        t ??= await storage.read();
        if (t != null && t.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $t';
        }
        handler.next(options);
      },
    ),
  );
  return ApiClient(dio);
}
