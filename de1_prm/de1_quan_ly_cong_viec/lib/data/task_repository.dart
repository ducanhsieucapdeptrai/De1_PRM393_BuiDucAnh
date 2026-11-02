import '../models/task.dart';
import 'database_helper.dart';

// REPOSITORY: nơi duy nhất làm việc trực tiếp với SQLite (CRUD)
class TaskRepository {
  final DatabaseHelper _helper;
  TaskRepository(this._helper);

  Future<List<Task>> getAll() async {
    final db = await _helper.database;
    final rows = await db.query('tasks', orderBy: 'id ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<int> insert(Task task) async {
    final db = await _helper.database;
    final map = task.toMap()..remove('id');
    return db.insert('tasks', map);
  }

  Future<int> update(Task task) async {
    final db = await _helper.database;
    return db.update('tasks', task.toMap(),
        where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> delete(int id) async {
    final db = await _helper.database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
