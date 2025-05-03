import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virtual_career/features/auth/model/user_model.dart';

class SharedPrefs {
  static final SharedPrefs _instance = SharedPrefs._internal();
  late SharedPreferences _prefs;

  SharedPrefs._internal();

  static SharedPrefs get instance => _instance;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Example Getters and Setters
  String? getString(String key) => _prefs.getString(key);
  Future<void> setString(String key, String value) async => await _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);
  Future<void> setBool(String key, bool value) async => await _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);
  Future<void> setInt(String key, int value) async => await _prefs.setInt(key, value);

  UserModel? getUser() {
    final userString = _prefs.getString('user');
    if (userString == null) return null;
    final userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap, userMap['id']);
  }

  Future<void> setUser(UserModel user) async {
    final userString = jsonEncode(user.toJson());
    debugPrint("User String: $userString");
    await _prefs.setString('user', userString);
  }

  // remove user
  Future<void> removeUser() async {
    await _prefs.remove('user');
  }

  Future<void> remove(String key) async => await _prefs.remove(key);
  Future<void> clear() async => await _prefs.clear();
}
