import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/settings_repository.dart';

part 'theme_viewmodel.g.dart';

// Các màu cho phép chọn (đề yêu cầu: xanh dương, xanh lá, tím).
// Giao diện mẫu có 8 ô, nên thêm vài màu nữa; muốn đúng 3 màu thì xóa bớt.
const List<Color> kAppBarColors = [
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.indigo,
  Colors.teal,
  Colors.deepPurple,
  Colors.lightGreen,
  Colors.blueGrey,
];

@Riverpod(keepAlive: true)
SettingsRepository settingsRepository(Ref ref) => SettingsRepository();

// VIEWMODEL: màu AppBar hiện tại, đọc/ghi SharedPreferences
@Riverpod(keepAlive: true)
class AppBarColor extends _$AppBarColor {
  @override
  Future<Color> build() async {
    final saved = await ref.read(settingsRepositoryProvider).getAppBarColor();
    return saved != null ? Color(saved) : Colors.blue;
  }

  Future<void> changeColor(Color color) async {
    state = AsyncData(color); // đổi ngay trên giao diện
    // ignore: deprecated_member_use
    await ref.read(settingsRepositoryProvider).saveAppBarColor(color.value);
  }
}
