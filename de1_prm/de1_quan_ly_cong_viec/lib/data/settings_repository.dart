import 'package:shared_preferences/shared_preferences.dart';

// Lưu màu AppBar bằng SharedPreferences -> tắt app mở lại vẫn nhớ
class SettingsRepository {
  static const _keyAppBarColor = 'app_bar_color';

  Future<int?> getAppBarColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAppBarColor);
  }

  Future<void> saveAppBarColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAppBarColor, colorValue);
  }
}
