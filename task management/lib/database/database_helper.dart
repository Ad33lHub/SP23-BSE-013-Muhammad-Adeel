import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/subtask.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const intTypeNullable = 'INTEGER';

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textType,
        dueDate $textType,
        dueTime $textTypeNullable,
        isCompleted $intType DEFAULT 0,
        completedAt $textTypeNullable,
        repeatType $textType DEFAULT 'none',
        repeatDays $textTypeNullable,
        createdAt $textType,
        updatedAt $textType,
        notificationId $intTypeNullable,
        notificationSound $textTypeNullable
      )
    ''');

    // Subtasks table
    await db.execute('''
      CREATE TABLE subtasks (
        id $idType,
        taskId $intType,
        title $textType,
        isCompleted $intType DEFAULT 0,
        createdAt $textType,
        updatedAt $textType,
        FOREIGN KEY (taskId) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');
  }

  // Task CRUD operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final result = await db.query('tasks', orderBy: 'dueDate ASC, dueTime ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await db.query(
      'tasks',
      where: "dueDate LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'dueTime ASC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getTodayTasks() async {
    final db = await database;
    final now = DateTime.now();
    
    // Get all non-completed tasks (both due today and repeated tasks)
    final result = await db.query(
      'tasks',
      where: 'isCompleted = 0',
      orderBy: 'dueTime ASC',
    );
    
    // Filter to only include tasks that are due today
    final allTasks = result.map((map) => Task.fromMap(map)).toList();
    final todayTasks = <Task>[];
    
    for (final task in allTasks) {
      if (task.isDueToday) {
        // Task is directly due today
        todayTasks.add(task);
      } else if (task.isRepeated) {
        // For repeated tasks, check if they should appear today
        if (task.repeatType == 'daily') {
          // Daily tasks always appear
          todayTasks.add(task);
        } else if (task.repeatType == 'weekly' && task.repeatDays != null) {
          // Weekly tasks appear if today's weekday is in the repeat days
          final days = _parseRepeatDays(task.repeatDays!);
          if (days.contains(now.weekday)) {
            todayTasks.add(task);
          }
        }
      }
    }
    
    return todayTasks;
  }

  List<int> _parseRepeatDays(String repeatDays) {
    try {
      final cleaned = repeatDays.replaceAll('[', '').replaceAll(']', '');
      return cleaned.split(',').map((e) => int.parse(e.trim())).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completedAt DESC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<List<Task>> getRepeatedTasks() async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'repeatType != ?',
      whereArgs: ['none'],
      orderBy: 'dueDate ASC',
    );
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<Task?> getTask(int id) async {
    final db = await database;
    final result = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Task.fromMap(result.first);
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    // Delete subtasks first (CASCADE should handle this, but being explicit)
    await db.delete('subtasks', where: 'taskId = ?', whereArgs: [id]);
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> completeTask(int id) async {
    final task = await getTask(id);
    if (task == null) return 0;
    return await updateTask(task.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    ));
  }

  Future<int> uncompleteTask(int id) async {
    final task = await getTask(id);
    if (task == null) return 0;
    return await updateTask(task.copyWith(
      isCompleted: false,
      completedAt: null,
    ));
  }

  // Subtask CRUD operations
  Future<int> insertSubtask(Subtask subtask) async {
    final db = await database;
    return await db.insert('subtasks', subtask.toMap());
  }

  Future<List<Subtask>> getSubtasksByTaskId(int taskId) async {
    final db = await database;
    final result = await db.query(
      'subtasks',
      where: 'taskId = ?',
      whereArgs: [taskId],
      orderBy: 'createdAt ASC',
    );
    return result.map((map) => Subtask.fromMap(map)).toList();
  }

  Future<Subtask?> getSubtask(int id) async {
    final db = await database;
    final result = await db.query(
      'subtasks',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Subtask.fromMap(result.first);
  }

  Future<int> updateSubtask(Subtask subtask) async {
    final db = await database;
    return await db.update(
      'subtasks',
      subtask.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [subtask.id],
    );
  }

  Future<int> deleteSubtask(int id) async {
    final db = await database;
    return await db.delete('subtasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> toggleSubtask(int id) async {
    final subtask = await getSubtask(id);
    if (subtask == null) return 0;
    return await updateSubtask(subtask.copyWith(isCompleted: !subtask.isCompleted));
  }

  // Progress calculation
  Future<double> getTaskProgress(int taskId) async {
    final subtasks = await getSubtasksByTaskId(taskId);
    if (subtasks.isEmpty) return 0.0;
    final completedCount = subtasks.where((s) => s.isCompleted).length;
    return completedCount / subtasks.length;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

