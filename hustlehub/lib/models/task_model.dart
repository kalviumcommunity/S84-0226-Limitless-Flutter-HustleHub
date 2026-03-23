enum TaskStatus { pending, inProgress, completed, onHold }

class Task {
  final String id;
  final String projectId;
  final String userId;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int priority; // 1 (low) to 5 (high)
  final List<String> assignedTo; // User IDs assigned to this task

  Task({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.deadline,
    required this.createdAt,
    this.completedAt,
    required this.priority,
    required this.assignedTo,
  });

  // Calculate days until deadline
  int get daysUntilDeadline {
    return deadline.difference(DateTime.now()).inDays;
  }

  // Check if deadline is today
  bool get isDeadlineToday {
    final now = DateTime.now();
    return deadline.day == now.day &&
        deadline.month == now.month &&
        deadline.year == now.year;
  }

  // Check if task is overdue
  bool get isOverdue {
    return status != TaskStatus.completed && DateTime.now().isAfter(deadline);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'deadline': deadline.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
      'assignedTo': assignedTo,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      deadline: DateTime.parse(map['deadline'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'] as String)
          : null,
      priority: map['priority'] as int,
      assignedTo: List<String>.from(map['assignedTo'] as List),
    );
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? deadline,
    DateTime? createdAt,
    DateTime? completedAt,
    int? priority,
    List<String>? assignedTo,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}
