enum ProjectStatus { active, completed, onHold, archived }

class Project {
  final String id;
  final String clientId;
  final String userId;
  final String title;
  final String description;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double amountPaid;
  final DateTime createdAt;
  final List<String> teamMembers; // User IDs

  Project({
    required this.id,
    required this.clientId,
    required this.userId,
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.budget,
    required this.amountPaid,
    required this.createdAt,
    required this.teamMembers,
  });

  // Calculate progress percentage
  double get progressPercentage {
    final total = DateTime.now().difference(startDate).inDays;
    final remaining = endDate.difference(DateTime.now()).inDays;
    if (total <= 0) return 0;
    return ((total - remaining) / total * 100).clamp(0, 100);
  }

  // Days until deadline
  int get daysUntilDeadline {
    return endDate.difference(DateTime.now()).inDays;
  }

  // Is project overdue?
  bool get isOverdue {
    return status != ProjectStatus.completed && DateTime.now().isAfter(endDate);
  }

  // Remaining budget
  double get remainingBudget {
    return budget - amountPaid;
  }

  // Budget percentage used
  double get budgetUsagePercentage {
    if (budget <= 0) return 0;
    return (amountPaid / budget * 100).clamp(0, 100);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'userId': userId,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'budget': budget,
      'amountPaid': amountPaid,
      'createdAt': createdAt.toIso8601String(),
      'teamMembers': teamMembers,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'] as String,
      clientId: map['clientId'] as String,
      userId: map['userId'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      budget: (map['budget'] as num).toDouble(),
      amountPaid: (map['amountPaid'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      teamMembers: List<String>.from(map['teamMembers'] as List),
    );
  }

  Project copyWith({
    String? id,
    String? clientId,
    String? userId,
    String? title,
    String? description,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    double? budget,
    double? amountPaid,
    DateTime? createdAt,
    List<String>? teamMembers,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      budget: budget ?? this.budget,
      amountPaid: amountPaid ?? this.amountPaid,
      createdAt: createdAt ?? this.createdAt,
      teamMembers: teamMembers ?? this.teamMembers,
    );
  }
}
