import 'dart:io';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:dio/dio.dart';

class TelegramService {
  final Dio _dio;
  TelegramService([Dio? dio]) : _dio = dio ?? Dio();

  Future<void> sendDocument({required File file, String? caption}) async {
    final token = KeyValueService.get<String>('tg_bot_token');
    final chatId = KeyValueService.get<String>('tg_chat_id');
    if (token == null || chatId == null || token.isEmpty || chatId.isEmpty) {
      throw StateError('Telegram not configured');
    }
    final url = 'https://api.telegram.org/bot$token/sendDocument';
    final form = FormData.fromMap({
      'chat_id': chatId,
      'caption': caption ?? '',
      'document': await MultipartFile.fromFile(file.path, filename: file.uri.pathSegments.last),
    });
    await _dio.post(url, data: form);
  }
}

