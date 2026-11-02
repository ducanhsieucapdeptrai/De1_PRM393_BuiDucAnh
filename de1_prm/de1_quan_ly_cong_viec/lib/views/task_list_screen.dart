import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/task_viewmodel.dart';
import 'edit_task_screen.dart';
import 'widgets/color_picker_dialog.dart';
import 'widgets/task_card.dart';

// VIEW: màn hình danh sách công việc
class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  bool _searching = false;

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(filteredTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Tìm công việc...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) => ref.read(searchQueryProvider.notifier).set(v),
              )
            : const Text('Quản lý công việc'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) ref.read(searchQueryProvider.notifier).set('');
            },
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const ColorPickerDialog(),
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(child: Text('Không có công việc nào'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (context, i) => TaskCard(
              task: tasks[i],
              onEdit: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditTaskScreen(task: tasks[i]),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditTaskScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
