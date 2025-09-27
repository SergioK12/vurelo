import 'package:hive_ce_flutter/adapters.dart';

mixin HiveService {
  Future<Box> openBox(String boxName) async {
    return await Hive.openBox(boxName);
  }

  Future<void> save(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await openBox(boxName);
    final value = box.get(key);

    if (value != null) {
      final parsedValue = Map<String, dynamic>.from(value);
      return parsedValue;
    }
    return null;
  }

  Future<void> delete(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  Future<Map<String, dynamic>?> getAll(String boxName) async {
    final box = await openBox(boxName);
    final data = box.toMap();
    
    if (data.isEmpty) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }
}
