import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/theme_viewmodel.dart';

// Hộp thoại "Chọn màu thanh ứng dụng"
class ColorPickerDialog extends ConsumerWidget {
  const ColorPickerDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appBarColorProvider).value;

    return AlertDialog(
      title: const Text('Chọn màu thanh ứng dụng'),
      content: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: kAppBarColors.map((color) {
          // ignore: deprecated_member_use
          final selected = current?.value == color.value;
          return GestureDetector(
            onTap: () =>
                ref.read(appBarColorProvider.notifier).changeColor(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: Colors.black, width: 3)
                    : null,
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white)
                  : null,
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}
