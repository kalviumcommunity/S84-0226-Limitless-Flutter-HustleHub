import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String userId;
  final String clientId;
  final String title;
  final double amount;
  final String status; // 'Pending', 'Completed', 'Overdue'
  final DateTime dueDate;
  final DateTime? paidDate;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.title,
    required this.amount,
    this.status = 'Pending',
    required this.dueDate,
    this.paidDate,
  });

  factory PaymentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentModel(
      id: documentId,
      userId: map['userId'] ?? '',
      clientId: map['clientId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Pending',
      dueDate: map['dueDate'] != null 
          ? (map['dueDate'] as Timestamp).toDate() 
          : DateTime.now(),
      paidDate: map['paidDate'] != null 
          ? (map['paidDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'title': title,
      'amount': amount,
      'status': status,
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
    };
  }
}
