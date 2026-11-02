import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Mở / tạo database SQLite. Lần đầu tạo bảng sẽ chèn sẵn dữ liệu mẫu như đề bài.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), 'tasks.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            is_done INTEGER NOT NULL DEFAULT 0,
            icon TEXT
          )
        ''');

        // Dữ liệu mẫu giống giao diện đề 1
        final seed = [
          {'title': 'Làm bài tập Flutter', 'description': 'Hoàn thành trước thứ Sáu', 'is_done': 0, 'icon': 'laptop'},
          {'title': 'Ôn tập Riverpod', 'description': 'Xem lại bài giảng MVVM', 'is_done': 0, 'icon': 'book'},
          {'title': 'Chuẩn bị bài thuyết trình', 'description': 'Nhóm 4 - Chủ đề Firebase', 'is_done': 0, 'icon': 'presentation'},
          {'title': 'Viết báo cáo môn học', 'description': 'Nộp trên LMS', 'is_done': 0, 'icon': 'report'},
        ];
        for (final row in seed) {
          await db.insert('tasks', row);
        }
      },
    );
  }
}
