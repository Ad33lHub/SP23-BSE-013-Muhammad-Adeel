class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final DateTime? dueTime;
  final bool isCompleted;
  final DateTime? completedAt;
  final String repeatType; // 'none', 'daily', 'weekly'
  final String? repeatDays; // JSON string of selected days for weekly (e.g., "[1,3,5]" for Mon, Wed, Fri)
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? notificationId;
  final String? notificationSound;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueTime,
    this.isCompleted = false,
    this.completedAt,
    this.repeatType = 'none',
    this.repeatDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notificationId,
    this.notificationSound,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'completedAt': completedAt?.toIso8601String(),
      'repeatType': repeatType,
      'repeatDays': repeatDays,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notificationId': notificationId,
      'notificationSound': notificationSound,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      dueTime: map['dueTime'] != null ? DateTime.parse(map['dueTime'] as String) : null,
      isCompleted: (map['isCompleted'] as int) == 1,
      completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt'] as String) : null,
      repeatType: map['repeatType'] as String? ?? 'none',
      repeatDays: map['repeatDays'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      notificationId: map['notificationId'] as int?,
      notificationSound: map['notificationSound'] as String?,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    bool? isCompleted,
    DateTime? completedAt,
    String? repeatType,
    String? repeatDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? notificationId,
    String? notificationSound,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      notificationId: notificationId ?? this.notificationId,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }

  bool get isRepeated => repeatType != 'none';
  
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isOverdue {
    if (isCompleted) return false;
    final now = DateTime.now();
    final due = dueTime ?? dueDate;
    return due.isBefore(now) && !isDueToday;
  }
}

