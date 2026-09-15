import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalQueue {
  static const key = 'mindweave_sync_queue';

  Future<List<Map<String,dynamic>>> read() async {
    final p=await SharedPreferences.getInstance();
    final raw=p.getStringList(key) ?? [];
    return raw.map((x)=>Map<String,dynamic>.from(jsonDecode(x))).toList();
  }

  Future<void> enqueue(Map<String,dynamic> item) async {
    final p=await SharedPreferences.getInstance();
    final items=p.getStringList(key) ?? [];
    items.add(jsonEncode(item));
    await p.setStringList(key,items);
  }

  Future<void> clear() async {
    final p=await SharedPreferences.getInstance();
    await p.remove(key);
  }
}
