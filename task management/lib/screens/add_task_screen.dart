import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../widgets/subtask_list.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final NotificationService _notificationService = NotificationService.instance;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  String _repeatType = 'none';
  List<int> _selectedDays = [];
  List<Subtask> _subtasks = [];
  bool _isLoading = false;

  final List<String> _weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.dueDate;
      _selectedTime = widget.task!.dueTime != null
          ? TimeOfDay.fromDateTime(widget.task!.dueTime!)
          : null;
      _repeatType = widget.task!.repeatType;
      if (widget.task!.repeatDays != null) {
        _selectedDays = _parseRepeatDays(widget.task!.repeatDays!);
      }
      _loadSubtasks();
    }
  }

  Future<void> _loadSubtasks() async {
    if (widget.task?.id != null) {
      final subtasks = await _dbHelper.getSubtasksByTaskId(widget.task!.id!);
      setState(() {
        _subtasks = subtasks;
      });
    }
  }

  List<int> _parseRepeatDays(String repeatDays) {
    try {
      final cleaned = repeatDays.replaceAll('[', '').replaceAll(']', '');
      return cleaned.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      return [];
    }
  }

  String _encodeRepeatDays(List<int> days) {
    return jsonEncode(days);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDaySelection(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
        _selectedDays.sort();
      }
    });
  }

  Future<void> _addSubtask() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Subtask title',
            hintText: 'Enter subtask title',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      final subtask = Subtask(
        taskId: widget.task?.id ?? 0,
        title: result,
      );
      
      if (widget.task?.id != null) {
        final id = await _dbHelper.insertSubtask(subtask);
        setState(() {
          _subtasks.add(subtask.copyWith(id: id));
        });
      } else {
        setState(() {
          _subtasks.add(subtask);
        });
      }
    }
  }

  Future<void> _toggleSubtask(int index) async {
    final subtask = _subtasks[index];
    if (subtask.id != null) {
      await _dbHelper.toggleSubtask(subtask.id!);
    }
    setState(() {
      _subtasks[index] = subtask.copyWith(isCompleted: !subtask.isCompleted);
    });
  }

  Future<void> _deleteSubtask(int index) async {
    final subtask = _subtasks[index];
    if (subtask.id != null) {
      await _dbHelper.deleteSubtask(subtask.id!);
    }
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_repeatType == 'weekly' && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day for weekly repeat')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dueDateTime = _selectedTime != null
          ? DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime!.hour,
              _selectedTime!.minute,
            )
          : null;

      Task task;
      if (widget.task != null) {
        // Update existing task
        task = widget.task!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDate,
          dueTime: dueDateTime,
          repeatType: _repeatType,
          repeatDays: _repeatType == 'weekly' && _selectedDays.isNotEmpty
              ? _encodeRepeatDays(_selectedDays)
              : null,
        );
        await _dbHelper.updateTask(task);
      } else {
        // Create new task
        task = Task(
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDate,
          dueTime: dueDateTime,
          repeatType: _repeatType,
          repeatDays: _repeatType == 'weekly' && _selectedDays.isNotEmpty
              ? _encodeRepeatDays(_selectedDays)
              : null,
        );
        final id = await _dbHelper.insertTask(task);
        task = task.copyWith(id: id);
      }

      // Save subtasks
      for (final subtask in _subtasks) {
        if (subtask.id == null) {
          await _dbHelper.insertSubtask(subtask.copyWith(taskId: task.id!));
        }
      }

      // Schedule notification (don't fail task save if notification fails)
      if (!task.isCompleted) {
        try {
          await _notificationService.updateTaskNotification(task);
        } catch (e) {
          // Log error but don't prevent task from being saved
          print('Warning: Failed to schedule notification: $e');
          // Optionally show a non-blocking message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task saved, but notification scheduling failed'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter task title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter task description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Due Date'),
              subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            ListTile(
              title: const Text('Due Time (Optional)'),
              subtitle: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'No time set',
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
            const Divider(),
            const Text(
              'Repeat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'none', label: Text('None')),
                ButtonSegment(value: 'daily', label: Text('Daily')),
                ButtonSegment(value: 'weekly', label: Text('Weekly')),
              ],
              selected: {_repeatType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _repeatType = selection.first;
                  if (_repeatType != 'weekly') {
                    _selectedDays.clear();
                  }
                });
              },
            ),
            if (_repeatType == 'weekly') ...[
              const SizedBox(height: 16),
              const Text('Select Days:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final isSelected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(_weekDays[index]),
                    selected: isSelected,
                    onSelected: (_) => _toggleDaySelection(day),
                  );
                }),
              ),
            ],
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtasks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addSubtask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Subtask'),
                ),
              ],
            ),
            if (_subtasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No subtasks. Tap "Add Subtask" to add one.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SubtaskList(
                subtasks: _subtasks,
                onToggle: _toggleSubtask,
                onDelete: _deleteSubtask,
              ),
          ],
        ),
      ),
    );
  }
}

