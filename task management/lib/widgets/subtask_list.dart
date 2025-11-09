import 'package:flutter/material.dart';
import '../models/subtask.dart';

class SubtaskList extends StatelessWidget {
  final List<Subtask> subtasks;
  final Function(int) onToggle;
  final Function(int) onDelete;

  const SubtaskList({
    super.key,
    required this.subtasks,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: subtasks.length,
      itemBuilder: (context, index) {
        final subtask = subtasks[index];
        return ListTile(
          leading: Checkbox(
            value: subtask.isCompleted,
            onChanged: (_) => onToggle(index),
          ),
          title: Text(
            subtask.title,
            style: TextStyle(
              decoration: subtask.isCompleted
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(index),
          ),
        );
      },
    );
  }
}

