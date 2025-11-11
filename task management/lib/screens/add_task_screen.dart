import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/subtask.dart';
import '../database/database_helper.dart';
import '../services/notification_service.dart';
import '../widgets/glass_widgets.dart';
import '../theme/glassmorphism_theme.dart';

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

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: GlassmorphismTheme.neonBlue,
              onPrimary: Colors.white,
              surface: GlassmorphismTheme.darkSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: GlassmorphismTheme.neonBlue,
              onPrimary: Colors.white,
              surface: GlassmorphismTheme.darkSurface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context) => GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Subtask',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Enter subtask title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GlassButton(
                  onPressed: () => Navigator.pop(context),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                  ),
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 12),
                GlassButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Add',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
        SnackBar(
          content: const Text('Please select at least one day for weekly repeat'),
          backgroundColor: GlassmorphismTheme.darkSurface,
        ),
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

      for (final subtask in _subtasks) {
        if (subtask.id == null) {
          await _dbHelper.insertSubtask(subtask.copyWith(taskId: task.id!));
        }
      }

      if (!task.isCompleted) {
        try {
          await _notificationService.updateTaskNotification(task);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Task saved, but notification scheduling failed'),
                backgroundColor: GlassmorphismTheme.darkSurface,
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
          SnackBar(
            content: Text('Error saving task: $e'),
            backgroundColor: GlassmorphismTheme.darkSurface,
          ),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.task == null ? 'Add Task' : 'Edit Task',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(GlassmorphismTheme.neonBlue),
                ),
              ),
            )
          else
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: GlassmorphismTheme.primaryGradient,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              onPressed: _saveTask,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Details',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter task title',
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
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter task description',
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GlassmorphismTheme.glassWhite.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: GlassmorphismTheme.neonBlue),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: GlassmorphismTheme.glassWhite.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: GlassmorphismTheme.neonBlue),
                          const SizedBox(width: 12),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'No time set',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _selectedTime != null ? Colors.white : Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repeat',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRepeatOption('none', 'None'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRepeatOption('daily', 'Daily'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildRepeatOption('weekly', 'Weekly'),
                      ),
                    ],
                  ),
                  if (_repeatType == 'weekly') ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = _selectedDays.contains(day);
                        return InkWell(
                          onTap: () => _toggleDaySelection(day),
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        GlassmorphismTheme.neonBlue.withOpacity(0.3),
                                        GlassmorphismTheme.neonPurple.withOpacity(0.3),
                                      ],
                                    )
                                  : null,
                              border: Border.all(
                                color: isSelected
                                    ? GlassmorphismTheme.neonBlue
                                    : GlassmorphismTheme.glassWhite.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              _weekDays[index],
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: isSelected
                                    ? GlassmorphismTheme.neonBlue
                                    : Colors.white70,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtasks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      GlassButton(
                        onPressed: _addSubtask,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, size: 18, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Add',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_subtasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No subtasks. Tap "Add" to add one.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white38,
                        ),
                      ),
                    )
                  else
                    ..._subtasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final subtask = entry.value;
                      return GlassContainer(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleSubtask(index),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: subtask.isCompleted
                                        ? GlassmorphismTheme.neonBlue
                                        : Colors.white38,
                                    width: 2,
                                  ),
                                  gradient: subtask.isCompleted
                                      ? LinearGradient(
                                          colors: [
                                            GlassmorphismTheme.neonBlue,
                                            GlassmorphismTheme.neonPurple,
                                          ],
                                        )
                                      : null,
                                ),
                                child: subtask.isCompleted
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  decoration: subtask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: subtask.isCompleted ? Colors.white38 : Colors.white,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B), size: 20),
                              onPressed: () => _deleteSubtask(index),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GlassButton(
              onPressed: _saveTask,
              isLoading: _isLoading,
              child: Text(
                widget.task == null ? 'Create Task' : 'Update Task',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatOption(String value, String label) {
    final isSelected = _repeatType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _repeatType = value;
          if (value != 'weekly') {
            _selectedDays.clear();
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    GlassmorphismTheme.neonBlue.withOpacity(0.3),
                    GlassmorphismTheme.neonPurple.withOpacity(0.3),
                  ],
                )
              : null,
          border: Border.all(
            color: isSelected
                ? GlassmorphismTheme.neonBlue
                : GlassmorphismTheme.glassWhite.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isSelected ? GlassmorphismTheme.neonBlue : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

