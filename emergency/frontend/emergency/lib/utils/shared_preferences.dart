// utils/share_preferences.dart

import 'package:shared_preferences/shared_preferences.dart';

// Save user ID in SharedPreferences
Future<void> saveUserId(String id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('id', id);
}

// Get stored user ID from SharedPreferences
Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('id');
}

// Remove user ID from SharedPreferences (for logout)
Future<void> removeUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('id');
}
