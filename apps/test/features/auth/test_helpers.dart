import 'dart:io';

import 'package:cashier_app/data/remote/api_client.dart';
import 'package:cashier_app/features/auth/application/auth_service.dart';
import 'package:cashier_app/services/key_value_service.dart';
import 'package:cashier_app/services/token_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class TestAuthService extends AuthService {
  TestAuthService() : super(ApiClient(Dio()));

  bool fail401 = false;
  bool failNetwork = false;
  String tokenToReturn = 'token-123';

  @override
  Future<String> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (fail401) throw AuthException('Invalid email or password');
    if (failNetwork) throw AuthException('Network error, please try again');
    return tokenToReturn;
  }
}

class MemoryTokenStorage extends TokenStorage {
  MemoryTokenStorage() : super(null);
  String? _token;

  @override
  Future<String?> read() async => _token;

  @override
  Future<void> write(String token) async {
    _token = token;
  }

  @override
  Future<void> clear() async {
    _token = null;
  }
}

class MemoryKeyValueBackend implements KeyValueBackend {
  final Map<String, Object?> _store = {};
  bool _open = false;

  @override
  Future<void> init() async {
    _open = true;
  }

  void _check() {
    if (!_open) {
      throw StateError('MemoryKeyValueBackend not initialized');
    }
  }

  @override
  bool get isOpen => _open;

  @override
  T? get<T>(String key) {
    _check();
    return _store[key] as T?;
  }

  @override
  Future<void> put<T>(String key, T value) async {
    _check();
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _check();
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _check();
    _store.clear();
  }
}

bool _storageInitialized = false;
Directory? _storageDir;

Future<void> ensureTestHydratedStorage() async {
  if (_storageInitialized) return;
  TestWidgetsFlutterBinding.ensureInitialized();
  _storageDir = await Directory.systemTemp.createTemp('hydrated_test');
  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: _storageDir!);
  _storageInitialized = true;
}

Future<void> disposeTestHydratedStorage() async {
  if (!_storageInitialized) return;
  await _storageDir?.delete(recursive: true);
  _storageDir = null;
  _storageInitialized = false;
}
