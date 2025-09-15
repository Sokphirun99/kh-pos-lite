import 'package:hive_flutter/hive_flutter.dart';

class KeyValueService {
  static const String _boxName = 'app';
  static Box? _box;

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      // No adapters to register now; placeholder
    }
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static Box _ensure() {
    final b = _box;
    if (b == null || !b.isOpen) {
      throw StateError('KeyValueService not initialized. Call init() first.');
    }
    return b;
  }

  static T? get<T>(String key) => _ensure().get(key) as T?;
  static Future<void> set<T>(String key, T value) => _ensure().put(key, value);
  static Future<void> remove(String key) => _ensure().delete(key);

  static Future<void> clear() async {
    await _ensure().clear();
  }
}
