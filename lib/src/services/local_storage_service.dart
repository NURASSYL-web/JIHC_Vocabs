import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  LocalStorageService._(this._prefs);

  static const String _stateKey = 'lexora.local_state.v1';

  final SharedPreferences _prefs;

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService._(prefs);
  }

  Map<String, dynamic> loadState() {
    final raw = _prefs.getString(_stateKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{};
  }

  Future<void> saveState(Map<String, dynamic> state) async {
    await _prefs.setString(_stateKey, jsonEncode(state));
  }
}
