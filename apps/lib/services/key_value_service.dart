import 'package:hive_flutter/hive_flutter.dart';

abstract class KeyValueBackend {
  Future<void> init();
  bool get isOpen;
  T? get<T>(String key);
  Future<void> put<T>(String key, T value);
  Future<void> delete(String key);
  Future<void> clear();
}

class _HiveBackend implements KeyValueBackend {
  static const String _boxName = 'app';
  Box? _box;
  bool _initialized = false;

  @override
  Future<void> init() async {
    if (!_initialized) {
      await Hive.initFlutter();
      _initialized = true;
    }
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox(_boxName);
    } else {
      _box = Hive.box(_boxName);
    }
  }

  Box _ensure() {
    final b = _box;
    if (b == null || !b.isOpen) {
      throw StateError('KeyValueService not initialized. Call init() first.');
    }
    return b;
  }

  @override
  bool get isOpen => _box?.isOpen == true;

  @override
  T? get<T>(String key) => _ensure().get(key) as T?;

  @override
  Future<void> put<T>(String key, T value) => _ensure().put(key, value);

  @override
  Future<void> delete(String key) => _ensure().delete(key);

  @override
  Future<void> clear() => _ensure().clear();
}

class KeyValueService {
  static KeyValueBackend _backend = _HiveBackend();

  // Allow tests to inject a fake backend; ignored in release profile by assert.
  static void debugSetBackend(KeyValueBackend backend) {
    assert(() {
      _backend = backend;
      return true;
    }());
  }

  static Future<void> init() => _backend.init();
  static bool get isOpen => _backend.isOpen;
  static T? get<T>(String key) => _backend.get<T>(key);
  static Future<void> set<T>(String key, T value) =>
      _backend.put<T>(key, value);
  static Future<void> remove(String key) => _backend.delete(key);
  static Future<void> clear() => _backend.clear();
}
