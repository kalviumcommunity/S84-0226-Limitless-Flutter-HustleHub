import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../models/task_model.dart';

class TasksProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get _useFirebase => Firebase.apps.isNotEmpty;

  TasksProvider() {
    _initializeMockData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void updateUserId(String? userId) {
    if (_userId == userId) return;
    _userId = userId;

    _subscription?.cancel();
    _error = null;

    if (_userId == null || _userId!.isEmpty) {
      _tasks = [];
      notifyListeners();
      return;
    }

    if (_useFirebase) {
      _isLoading = true;
      notifyListeners();

      _subscription = _firestore
          .collection('tasks')
          .where('userId', isEqualTo: _userId)
          .snapshots()
          .listen(
            (snapshot) {
              _tasks = snapshot.docs.map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return Task.fromMap(data);
              }).toList();
              _isLoading = false;
              notifyListeners();
            },
            onError: (Object e) {
              _isLoading = false;
              _error = 'Failed to stream tasks: $e';
              notifyListeners();
            },
          );
    } else {
      _initializeMockData(userId: _userId!);
      notifyListeners();
    }
  }

  void _initializeMockData({String userId = 'user1'}) {
    _tasks = [
      Task(
        id: '1',
        projectId: 'proj1',
        userId: userId,
        title: 'Design Homepage',
        description: 'Create a responsive homepage design',
        status: TaskStatus.inProgress,
        deadline: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        priority: 5,
        assignedTo: const ['user1'],
      ),
      Task(
        id: '2',
        projectId: 'proj1',
        userId: userId,
        title: 'Setup Database',
        description: 'Configure Firebase Firestore',
        status: TaskStatus.pending,
        deadline: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        priority: 4,
        assignedTo: const ['user1'],
      ),
      Task(
        id: '3',
        projectId: 'proj2',
        userId: userId,
        title: 'API Integration',
        description: 'Integrate payment gateway API',
        status: TaskStatus.completed,
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
        priority: 5,
        assignedTo: const ['user1'],
      ),
    ];
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final normalized = task.copyWith(userId: _userId ?? task.userId);
      if (_useFirebase) {
        await _firestore
            .collection('tasks')
            .doc(normalized.id)
            .set(normalized.toMap());
      } else {
        _tasks.add(normalized);
      }
    } catch (e) {
      _error = 'Failed to add task: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore.collection('tasks').doc(task.id).update(task.toMap());
      } else {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index == -1) throw Exception('Task not found');
        _tasks[index] = task;
      }
    } catch (e) {
      _error = 'Failed to update task: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useFirebase) {
        await _firestore.collection('tasks').doc(taskId).delete();
      } else {
        _tasks.removeWhere((t) => t.id == taskId);
      }
    } catch (e) {
      _error = 'Failed to delete task: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      await updateTask(
        task.copyWith(
          status: newStatus,
          completedAt: newStatus == TaskStatus.completed
              ? DateTime.now()
              : null,
        ),
      );
    } catch (e) {
      _error = 'Failed to update task status: $e';
      notifyListeners();
      rethrow;
    }
  }

  List<Task> getTasksByProject(String projectId) {
    return _tasks.where((task) => task.projectId == projectId).toList();
  }

  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getOverdueTasks() {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  List<Task> getTasksDueToday() {
    return _tasks.where((task) => task.isDeadlineToday).toList();
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (_) {
      return null;
    }
  }

  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    return _tasks
        .where(
          (task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  Future<void> fetchTasks(String userId) async {
    updateUserId(userId);
  }
}
