class Task {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime? dueDate;
  final bool completed;
  final bool isPinned;
  final DateTime createdAt;
  final String repeatType; // 'none', 'daily', 'weekly', 'monthly', 'yearly'
  final int repeatInterval; // e.g., every 2 days

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dueDate,
    required this.completed,
    required this.isPinned,
    required this.createdAt,
    this.repeatType = 'none',
    this.repeatInterval = 1,
  });

  bool get isOverdue =>
      dueDate != null && !completed && dueDate!.isBefore(DateTime.now());

  String get dueDateLabel {
    if (dueDate == null) return 'Sem prazo';
    final local = dueDate!.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['created_at'];
    final createdAt = createdAtValue is String
        ? DateTime.parse(createdAtValue)
        : createdAtValue as DateTime;

    final dueDateValue = map['due_date'];
    DateTime? dueDate;
    if (dueDateValue is String && dueDateValue.isNotEmpty) {
      dueDate = DateTime.parse(dueDateValue);
    } else if (dueDateValue is DateTime) {
      dueDate = dueDateValue;
    }

    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      dueDate: dueDate,
      completed: map['completed'] as bool? ?? false,
      isPinned: map['is_pinned'] as bool? ?? false,
      createdAt: createdAt,
      repeatType: map['repeat_type'] as String? ?? 'none',
      repeatInterval: map['repeat_interval'] as int? ?? 1,
    );
  }
}

