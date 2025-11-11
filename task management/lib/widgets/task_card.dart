import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../widgets/glass_widgets.dart';
import '../theme/glassmorphism_theme.dart';

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

    return AnimatedGlassCard(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox with glass effect
              GestureDetector(
                onTap: widget.onToggleComplete,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.task.isCompleted
                          ? GlassmorphismTheme.neonBlue
                          : Colors.white38,
                      width: 2,
                    ),
                    gradient: widget.task.isCompleted
                        ? LinearGradient(
                            colors: [
                              GlassmorphismTheme.neonBlue,
                              GlassmorphismTheme.neonPurple,
                            ],
                          )
                        : null,
                    boxShadow: widget.task.isCompleted
                        ? [
                            BoxShadow(
                              color: GlassmorphismTheme.neonBlue.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: widget.task.isCompleted
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            decoration: widget.task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: isOverdue
                                ? const Color(0xFFFF6B6B)
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (widget.task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white38,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: GlassmorphismTheme.darkSurface.withOpacity(0.95),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        const Text('Edit'),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      widget.onTap,
                    ),
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: const Color(0xFFFF6B6B), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(color: const Color(0xFFFF6B6B)),
                        ),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      widget.onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.white60),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(widget.task.dueDate),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isOverdue ? const Color(0xFFFF6B6B) : Colors.white60,
                    ),
              ),
              if (widget.task.dueTime != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.access_time, size: 14, color: Colors.white60),
                const SizedBox(width: 6),
                Text(
                  timeFormat.format(widget.task.dueTime!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          if (_isLoadingProgress == false && _progress > 0) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(_progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: GlassmorphismTheme.neonBlue,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Colors.white10,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: LinearGradient(
                          colors: [
                            GlassmorphismTheme.neonBlue,
                            GlassmorphismTheme.neonPurple,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: GlassmorphismTheme.neonBlue.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (widget.task.isRepeated) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    GlassmorphismTheme.neonCyan.withOpacity(0.2),
                    GlassmorphismTheme.neonPurple.withOpacity(0.2),
                  ],
                ),
                border: Border.all(
                  color: GlassmorphismTheme.neonCyan.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                widget.task.repeatType == 'daily' ? 'Daily' : 'Weekly',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: GlassmorphismTheme.neonCyan,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
          if (isOverdue && !widget.task.isCompleted) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
                border: Border.all(
                  color: const Color(0xFFFF6B6B).withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                'Overdue',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFFF6B6B),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
