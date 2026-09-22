import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/saint.dart';

class SaintsService {
  List<Saint> _saints = [];
  bool _loaded = false;

  Future<void> loadSaints() async {
    if (_loaded) return;
    final String jsonString = await rootBundle.loadString('assets/saints.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    _saints = jsonList.map((e) => Saint.fromJson(e as Map<String, dynamic>)).toList();
    _loaded = true;
  }

  Saint getTodaySaint() {
    final now = DateTime.now();
    return getSaintByDate(now.month, now.day);
  }

  Saint getSaintByDate(int month, int day) {
    try {
      return _saints.firstWhere((s) => s.month == month && s.day == day);
    } catch (_) {
      return _saints.first;
    }
  }

  Saint getSaintByIndex(int index) {
    final clampedIndex = index % _saints.length;
    return _saints[clampedIndex];
  }

  int getTodayIndex() {
    final now = DateTime.now();
    for (int i = 0; i < _saints.length; i++) {
      if (_saints[i].month == now.month && _saints[i].day == now.day) {
        return i;
      }
    }
    return 0;
  }

  int getIndexByDate(int month, int day) {
    for (int i = 0; i < _saints.length; i++) {
      if (_saints[i].month == month && _saints[i].day == day) {
        return i;
      }
    }
    return 0;
  }

  List<Saint> get allSaints => List.unmodifiable(_saints);
  int get totalSaints => _saints.length;
}
