enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { creditCard, bankTransfer, paypal, cash, check }

class Payment {
  final String id;
  final String projectId;
  final String clientId;
  final String userId;
  final double amount;
  final PaymentStatus status;
  final PaymentMethod method;
  final String description;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? paidDate;
  final String? invoiceNumber;
  final String? notes;

  Payment({
    required this.id,
    required this.projectId,
    required this.clientId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.method,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    this.paidDate,
    this.invoiceNumber,
    this.notes,
  });

  // Calculate days until due
  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  // Check if payment is overdue
  bool get isOverdue {
    return status != PaymentStatus.completed && DateTime.now().isAfter(dueDate);
  }

  // Check if payment is due today
  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.day == now.day &&
        dueDate.month == now.month &&
        dueDate.year == now.year;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'clientId': clientId,
      'userId': userId,
      'amount': amount,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'invoiceNumber': invoiceNumber,
      'notes': notes,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      projectId: map['projectId'] as String,
      clientId: map['clientId'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == map['method'],
      ),
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      paidDate: map['paidDate'] != null
          ? DateTime.parse(map['paidDate'] as String)
          : null,
      invoiceNumber: map['invoiceNumber'] as String?,
      notes: map['notes'] as String?,
    );
  }

  Payment copyWith({
    String? id,
    String? projectId,
    String? clientId,
    String? userId,
    double? amount,
    PaymentStatus? status,
    PaymentMethod? method,
    String? description,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? paidDate,
    String? invoiceNumber,
    String? notes,
  }) {
    return Payment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      method: method ?? this.method,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      paidDate: paidDate ?? this.paidDate,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      notes: notes ?? this.notes,
    );
  }
}
