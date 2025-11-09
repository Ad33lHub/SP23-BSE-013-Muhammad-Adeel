import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _progress = 0.0;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    if (widget.task.id != null) {
      final dbHelper = DatabaseHelper.instance;
      final progress = await dbHelper.getTaskProgress(widget.task.id!);
      setState(() {
        _progress = progress;
        _isLoadingProgress = false;
      });
    } else {
      setState(() {
        _isLoadingProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isOverdue = widget.task.isOverdue && !widget.task.isCompleted;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      color: isOverdue ? Colors.red[50] : null,
      child: ListTile(
        leading: Checkbox(
          value: widget.task.isCompleted,
          onChanged: (_) => widget.onToggleComplete(),
        ),
        title: Text(
          widget.task.title,
          style: TextStyle(
            decoration: widget.task.isCompleted
                ? TextDecoration.lineThrough
                : null,
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.red[900] : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              widget.task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(widget.task.dueDate),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (widget.task.dueTime != null) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    timeFormat.format(widget.task.dueTime!),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (_isLoadingProgress == false && _progress > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.task.isCompleted ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            if (widget.task.isRepeated) ...[
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  widget.task.repeatType == 'daily' ? 'Daily' : 'Weekly',
                  style: const TextStyle(fontSize: 10),
                ),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
            if (isOverdue && !widget.task.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Overdue',
                  style: TextStyle(
                    color: Colors.red[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              widget.onTap();
            } else if (value == 'delete') {
              widget.onDelete();
            }
          },
        ),
        onTap: widget.onTap,
      ),
    );
  }
}

