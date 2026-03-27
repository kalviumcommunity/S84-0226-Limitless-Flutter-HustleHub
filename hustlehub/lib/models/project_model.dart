import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String userId;
  final String clientId;
  final String title;
  final String description;
  final DateTime deadline;
  final String status;
  final double progress;
  final DateTime? createdAt;

  ProjectModel({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.progress,
    this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProjectModel(
      id: docId,
      userId: map['userId'] ?? '',
      clientId: map['clientId'] ?? '',
      title: map['title'] ?? 'Untitled',
      description: map['description'] ?? '',
      deadline: map['deadline'] != null ? (map['deadline'] as Timestamp).toDate() : DateTime.now(),
      status: map['status'] ?? 'In Progress',
      progress: (map['progress'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'status': status,
      'progress': progress,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() => 'ProjectModel(id: $id, title: $title, status: $status)';
}
